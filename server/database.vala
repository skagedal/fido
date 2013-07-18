using SQLHeavy;
using Grss;
using Fido.Logging;

namespace Fido {

public errordomain DatabaseError {
    FILE_NOT_FOUND,
    CREATE_TABLE,
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
    public Database (string? filename = null) throws DatabaseError, SQLHeavy.Error {
        if (filename == null)
            Logging.message (Flag.DATABASE, @"Connecting to SQLite database in memory");
        else
            Logging.message (Flag.DATABASE, @"Connecting to SQLite database: $filename");
        try {
    		this.db = new SQLHeavy.Database (filename);
    	} catch (SQLHeavy.Error e) {
            // This is the "SQL error or missing database" error, which in this
            // case has to be the latter.
            throw new DatabaseError.FILE_NOT_FOUND(@"File not found: $filename");
    	}
		create_tables ();
//		create_examples ();
    }

	public void create_examples () throws SQLHeavy.Error {
		var my_channel = new Grss.FeedChannel.with_source ("http://localhost/simon/example.xml");
		var my_id = add_feed (my_channel);
		stdout.printf (@"Channel id: $my_id\n");
		
		var sandwich = new Grss.FeedItem (my_channel);
		sandwich.set_title ("Sandwich!");
		var datetime = new DateTime.utc (2012, 11, 01, 13, 37, 00);
		sandwich.set_publish_time ((long) datetime.to_unix ());
		var sandwich_id = add_item (sandwich);
		stdout.printf (@"Sandwich id: $sandwich_id\n");
	}


    public void create_tables () throws DatabaseError {
        try {
		    this.db.execute ("""
                CREATE TABLE IF NOT EXISTS `items` (
                    item_id                  INTEGER PRIMARY KEY,
                    item_guid                TEXT NOT NULL,
                    item_title               TEXT,
                    item_content             TEXT,
                    item_posted              INTEGER,
                    item_updated             INTEGER,
                    item_read_time           INTEGER DEFAULT 0,
                    item_mute                INTEGER,
                    item_stored              INTEGER DEFAULT (strftime('%s')),
                    feed_id                  INTEGER NOT NULL,
                    
                    UNIQUE (feed_id, item_guid)
                )
                """);
        } catch (SQLHeavy.Error e) {
            throw new DatabaseError.CREATE_TABLE(@"Error creating table 'items': $(e.message)");
        }
        try {
            this.db.execute ("""
                CREATE TABLE IF NOT EXISTS `feeds` (
                    feed_id                  INTEGER PRIMARY KEY,
                    feed_title               TEXT,
                    feed_source              TEXT UNIQUE NOT NULL,
                    feed_metadata            TEXT,
                    feed_priority            INTEGER DEFAULT 0,
                    feed_mute                INTEGER,
                    feed_updated             INTEGER DEFAULT 0
                )""");
        } catch (SQLHeavy.Error e) {
            throw new DatabaseError.CREATE_TABLE("Error creating table 'feeds'");
        }
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
                    item_updated
                ) VALUES (:feed_id, :guid, :title, :content, :posted, :updated)
            """);
            query[":feed_id"] = feed.id;
            query[":guid"] = item.guid;
            query[":title"] = item.title;
            query[":content"] = item.description;
            query[":posted"] = item.publish_time;
            query[":updated"] = item.publish_time;
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
                    item_updated = :updated
                WHERE feed_id    = :feed_id 
                  AND item_guid =  :guid
            """);
            query[":feed_id"] = feed.id;
            query[":guid"] = item.guid;
            query[":title"] = item.title;
            query[":content"] = item.description;
            query[":posted"] = item.publish_time;
            query[":updated"] = item.publish_time;
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
                    item_updated
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
            // FIXME: updated time not supported in libgrss yet
            return item;
        } catch (SQLHeavy.Error e) {
            throw new DatabaseError.SELECT(@"Error while fetching item: $(e.message)");
        }
    }

    public void show_first_item () {

		// SELECT to get unread items should have:
		// WHERE read_time < updated_time AND updated_time < now
		// (possibly using BETWEEN)
		// 
		// This correctly handles items that get updated after being read
		// while not choking on the corner case of items with update time
		// in the future.

    }

    // The following methods should be rewritten to use Fido.Feed/Item.

    // This one is replace above with get_all_feeds.
/*
	public Fido.DBus.Feed[] get_feeds () {
		var feedlist = new Fido.DBus.Feed[0]; 
		try {
			var results = this.db.execute ("""
                SELECT `feed_title`, `feed_source`
                FROM `feeds`""");

			for (int record = 0; !results.finished; record++, results.next ()) {
				var feed = Fido.DBus.Feed ();
				feed.title = results.fetch_string (0) ?? "";
				feed.url = results.fetch_string (1) ?? "";
				feedlist += feed;
			}
		} catch (SQLHeavy.Error e) {
			stderr.printf ("get_feeds() got SQL error: %s\n", e.message);
		}
		return feedlist;
	}
*/
	public int64 add_item (Grss.FeedItem item) throws SQLHeavy.Error {
		var feed_id = item.get_parent().get_data<int64> ("sqlid");
		var id = this.db.execute_insert ("""
            INSERT INTO `items` (
                item_guid,
                item_title,
                item_content,
                item_posted,
                item_updated,
                feed_id
            ) VALUES (:guid, :title, :content, :posted, :updated, :feed_id)""",
										 ":guid", typeof(string), item.get_id(),
										 ":title", typeof(string), item.get_title(),
										 ":content", typeof(string), item.get_description(),
										 ":posted", typeof(int64), (int64)item.get_publish_time(),
										 ":updated", typeof(int64), (int64)item.get_publish_time(),
										 ":feed_id", typeof(int64), feed_id);
		item.set_data<int64> ("sqlid", id);
		return id;
 	}

	public int64 add_feed (Grss.FeedChannel channel) throws SQLHeavy.Error {
		var id = this.db.execute_insert ("""
            INSERT INTO `feeds` (
                feed_title,
                feed_source
            ) VALUES (:title, :source)""",
										 ":title", typeof(string), channel.get_title(),
										 ":source", typeof(string), channel.get_source());
		channel.set_data<int64> ("sqlid", id);
		return id;
	}


}

}