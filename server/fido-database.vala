/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using SQLHeavy;
using Grss;
using Fido.Logging;

namespace Fido {

    public errordomain DatabaseError {
        FILE_NOT_FOUND,
        CREATE_TABLE,
        INSERT,
        UPDATE,
        SELECT
    }

    public class Database {

        private SQLHeavy.Database db;

        /**
         * Constructor.
         *
         * @filename: if null, use in-memory database
         */
        public Database (string? filename = null) throws DatabaseError {
            var schemas = GLib.Path.build_filename (Config.PATH_PACKAGE_DATA,
                                                    "sqlite-schemas");

            if (filename == null)
                Logging.message (Flag.DATABASE, @"Connecting to SQLite database in memory");
            else
                Logging.message (Flag.DATABASE, @"Connecting to SQLite database: $filename");
            try {
                this.db = new SQLHeavy.VersionedDatabase (filename, schemas);
            } catch (SQLHeavy.Error e) {
                // This is the "SQL error or missing database" error, which in this
                // case has to be the latter. (FIXME: Hmm no, we're not checking the error type.)
                throw new DatabaseError.FILE_NOT_FOUND(@"File not found: $filename");
            }
            //create_tables ();
        }

        /** Update a feed already in database and its items */
        public void update_feed (Feed feed) throws DatabaseError 
                requires (feed.id > 0) 
                requires (feed.source != null) {
            try {
                var query = this.db.prepare("""
                    UPDATE `feeds` SET
                        `feed_source`   = :source,
                        `feed_title`    = :title,
                        `feed_priority` = :priority,
                        `feed_updated`  = :updated
                    WHERE `feed_id`     = :id
                """);
                query[":source"] = feed.source;
                query[":title"] = feed.title;
                query[":priority"] = feed.priority;
                query[":updated"] = feed.updated_time;
                query[":id"] = feed.id;
                query.execute();
            } catch (SQLHeavy.Error e) {
                throw new DatabaseError.UPDATE(@"Error writing info for feed $(feed.id) [$(feed.source)] to database");
            }
            foreach (var item in feed.items) 
                add_or_update_item (feed, item);
        }

        public void add_or_update_item (Feed feed, Item item) throws DatabaseError
                requires (feed.id > 0)
                requires (item.guid != null) {

            // Try INSERT, if that fails because it already exists, do UPDATE.
            // I wish I could just do that in one SQL command but can't fgure out
            // how.  INSERT OR REPLACE creates a new row and doesn't copy the
            // fields I'm not updating... :/

            try {
                var query = this.db.prepare("""
                    INSERT OR ABORT INTO `items` (
                        feed_id,
                        item_guid,
                        item_title,
                        item_content,
                        item_posted,
                        item_updated,
                        item_author
                    ) VALUES (:feed_id, :guid, :title, :content, :posted, :updated, :author)
                """);
                query[":feed_id"] = feed.id;
                query[":guid"] = item.guid;
                query[":title"] = item.title;
                query[":content"] = item.description;
                query[":posted"] = item.publish_time;
                query[":updated"] = item.update_time == 0 ? item.publish_time : item.update_time;
                query[":author"] = item.author;
                query.execute();
            } catch (SQLHeavy.Error e) {
                if (e is SQLHeavy.Error.CONSTRAINT) {
                    Logging.message(Flag.DATABASE, @"Item $(item.guid) already existed; updating it instead");
                    update_item (feed, item);
                } else {
                    throw new DatabaseError.UPDATE(@"Error adding item with guid $(item.guid) to database: $(e.message)");
                }
            }
        }

        public void update_item (Feed feed, Item item) throws DatabaseError
                requires (feed.id > 0)
                requires (item.guid != null) {
            try {    
                var query = this.db.prepare("""
                    UPDATE `items` SET
                        item_title   = :title,
                        item_content = :content,
                        item_posted  = :posted,
                        item_updated = :updated,
                        item_author  = :author
                    WHERE feed_id    = :feed_id 
                      AND item_guid =  :guid
                """);
                query[":feed_id"] = feed.id;
                query[":guid"] = item.guid;
                query[":title"] = item.title;
                query[":content"] = item.description;
                query[":posted"] = item.publish_time;
                query[":updated"] = item.update_time == 0 ? item.publish_time : item.update_time;
                query[":author"] = item.author;
                query.execute();
            } catch (SQLHeavy.Error e) {
                throw new DatabaseError.UPDATE(@"Error updating item with guid $(item.guid): $(e.message)");
            }
        }
        
        public Gee.List<Fido.Feed> get_all_feeds () throws DatabaseError {
            Gee.List<Fido.Feed> feeds = new Gee.LinkedList<Fido.Feed> ();
            try {
                var query = this.db.prepare("""
                    SELECT `feed_id`, `feed_title`, `feed_source`
                    FROM `feeds`""");
                for (var r = query.execute (); !r.finished; r.next ()) {
                    var feed = new Fido.Feed.with_id (r.fetch_int (0));
                    feed.title = r.fetch_string (1) ?? "";
                    feed.source = r.fetch_string (2) ?? "";
                    feeds.add (feed);
                }
            } catch (SQLHeavy.Error e) {
                throw new DatabaseError.SELECT("Error getting feeds: $(e.message)");
            }
            return feeds;
        }

        public Gee.List<Feed> get_feeds_not_updated_since (DateTime d) {
            int64 t = d.to_unix ();
            Gee.List<Fido.Feed> feeds = new Gee.LinkedList<Fido.Feed> ();
            
            try {
                var query = this.db.prepare("""
                    SELECT `feed_id`, `feed_title`, `feed_source`
                    FROM `feeds`
                    WHERE `feed_updated` < :time""");
                query[":time"] = t;
                for (var r = query.execute (); !r.finished; r.next ()) {
                    var feed = new Fido.Feed.with_id (r.fetch_int (0));
                    feed.title = r.fetch_string (1) ?? "";
                    feed.source = r.fetch_string (2) ?? "";
                    feeds.add (feed);
                }
            } catch (SQLHeavy.Error e) {
                Logging.critical (Flag.DATABASE, "get_feeds_not_updated_since() got SQL error: %s\n", e.message);
            }
            return feeds;
        }

        public Item? get_first_item () throws DatabaseError {
            try {
                var query = this.db.prepare("""
                    SELECT
                        feed_id, 
                        feed_title,
                        feed_source,
                        item_id,
                        item_guid, 
                        item_title, 
                        item_content, 
                        item_posted,
                        item_updated,
                        item_author
                    FROM `items`, `feeds` USING (`feed_id`)
                    WHERE item_read_time < item_updated
                      AND item_updated < (strftime('%s'))
                    ORDER BY feed_priority DESC, item_updated
                """);
                var r = query.execute();
                if (r.finished)
                    return null;
                int c = 0;
                var feed = new Feed.with_id (r.fetch_int    (c++));
                feed.title =                 r.fetch_string (c++) ?? "";
                feed.source =                r.fetch_string (c++) ?? "";
                var item = new Item(feed);
                item.id =                    r.fetch_int    (c++);
                item.guid =                  r.fetch_string (c++);
                item.title =                 r.fetch_string (c++);
                item.description =           r.fetch_string (c++);
                item.publish_time =          r.fetch_int64  (c++);
                item.update_time =           r.fetch_int64  (c++);
                item.author =                r.fetch_string (c++);
                return item;
            } catch (SQLHeavy.Error e) {
                throw new DatabaseError.SELECT(@"Error while fetching item: $(e.message)");
            }
        }

        public void remove_feed (int id) throws DatabaseError {
            Logging.critical (Flag.DATABASE, "remove_feed: IMPLEMENT ME");
        }

        public Feed get_feed (int id) throws DatabaseError {
            Logging.critical (Flag.DATABASE, "get_feed: IMPLEMENT ME");
            return new Feed();
        }

        /**
         * @id: item row id
         * @time: if 0, set to current time
         */
        public void set_item_read_time (int id, int64 time = 0) throws DatabaseError {
            string timestring;
            if (time == 0)
                timestring = "(strftime('%s'))";
            else
                timestring = time.to_string();
                
            // Logging.critical (Flag.DATABASE, "set_item_read_time: IMPLEMENT ME");
            try {
                var query = this.db.prepare ("""
                    UPDATE `items` SET
                        item_read_time = %s
                    WHERE
                        item_id = :id
                """.printf(timestring));
                query[":id"] = id;
                query.execute ();
                // FIXME: if it couldn't find this id it silently fails... check sqlite3_changes, whatever
                // this is in sqlheavy?
            } catch (SQLHeavy.Error e) {
                throw new DatabaseError.UPDATE(@"Error setting read time of item: $(e.message)");
            }

        }

        /** 
         * Adds a feed to the database.
         *
         * @source: The feed's URI
         *
         * Return value: Database row ID of the added feed, or 0 if it was already there.
         */
        public int64 add_feed (string source) throws DatabaseError {
            try {
                var query = this.db.prepare ("""
                    INSERT INTO `feeds` (
                        `feed_source`
                    ) VALUES (:source)
                """);
                query[":source"] = source;
                return query.execute_insert ();
            } catch (SQLHeavy.Error e) {
                if (e is SQLHeavy.Error.CONSTRAINT) {
                    return 0;
                }
                throw new DatabaseError.INSERT(@"Error adding feed: $(e.message)");
            }
        }
    }
}
