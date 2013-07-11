using SQLHeavy;
using Grss;

namespace Fido {

enum Blog {
	STEVES_FOOD,
	FRIEND_TOM,
	WORK_STUFF,
	TIME_WASTE
}
    
public class Database {

    private SQLHeavy.Database db;
    public Database () throws SQLHeavy.Error {
		this.db = new SQLHeavy.Database ("foo.db");
    }

    public void create_tables () throws SQLHeavy.Error {
		this.db.execute ("""
            CREATE TABLE IF NOT EXISTS `items` (
                item_id                  INTEGER PRIMARY KEY,
                item_guid                TEXT,
                item_title               TEXT,
                item_content             TEXT,
                item_posted              INTEGER,
                item_updated             INTEGER,
                item_is_read             INTEGER DEFAULT 0,
                item_mute                INTEGER,
                feed_id                  INTEGER NOT NULL
            )""");
        this.db.execute ("""
            CREATE TABLE IF NOT EXISTS `feeds` (
                feed_id                  INTEGER PRIMARY KEY,
                feed_title               TEXT,
                feed_source              TEXT,
                feed_metadata            TEXT,
                feed_priority            INTEGER DEFAULT 0,
                feed_mute                INTEGER
            )""");
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

	public void create_examples () throws SQLHeavy.Error {
		var steve_channel = new Grss.FeedChannel.with_source ("http://foo.org/steves_food/");
		steve_channel.set_title ("Steve's Food");
		var steve_id = this.add_feed (steve_channel);
		stdout.printf (@"Steve's id: $steve_id\n");

		var sandwich = new Grss.FeedItem (steve_channel);
		sandwich.set_title ("Sandwich!");
		var datetime = new DateTime.utc (2012, 11, 01, 13, 37, 00);
		sandwich.set_publish_time ((long) datetime.to_unix ());
		var sandwich_id = this.add_item (sandwich);
		stdout.printf (@"Sandwich id: $sandwich_id\n");
	}

/*
	// This is just for testing
	struct FeedEntry {
		string title;
		int64 id;
		int64 prio;
	}
	const FeedEntry[] entries = {
		{ "Steve's Food",   Blog.STEVES_FOOD,    0},
		{ "Friend Tom",     Blog.FRIEND_TOM,     2},
		{ "Work Stuff",     Blog.WORK_STUFF,     1},
		{ "Time Waste",     Blog.TIME_WASTE,     0}};

    public void create_feeds () throws SQLHeavy.Error {
		var trans = this.db.begin_transaction ();

		foreach (FeedEntry entry in entries) {
			trans.execute ("""
                INSERT INTO `feeds` (
                    feed_title, 
                    feed_id,
                    feed_priority)
                VALUES (:title, :id, :prio)""",
			   ":title", typeof(string), entry.title,
			   ":id", typeof(int64), entry.id,
			   ":prio", typeof(int64), entry.prio);
		};
		trans.commit ();
    }

	struct ItemEntry {
		string title;
		int64 feed_id;
		bool is_read;
		int64 updated;
	}
    public void create_items () {
		ItemEntry[] entries = {
			ItemEntry() {
				title = 
  }
*/

    public void show_first_item () {

    }

	public static void main (string[] args) {
		try {
			var db = new Fido.Database();
			db.create_tables ();
			db.create_examples ();
		} catch (SQLHeavy.Error e) {
			stdout.printf ("Error: %s\n", e.message);
		}
	}
}

}