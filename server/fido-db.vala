using SQLHeavy;

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
            CREATE TABLE IF NOT EXISTS items (
                item_title               TEXT,
                item_content             TEXT,
                item_posted              INTEGER,
                item_updated             INTEGER,
                item_is_read             INTEGER DEFAULT 0,
                item_mute                INTEGER,
                feed_id                  INTEGER NOT NULL
            )""");
        this.db.execute ("""
            CREATE TABLE IF NOT EXISTS feeds (
                feed_id                  INTEGER PRIMARY KEY,
                feed_title               TEXT,
                feed_metadata            TEXT,
                feed_priority            INTEGER DEFAULT 0,
                feed_mute                INTEGER
            )""");
    }

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
/*
		ItemEntry[] entries = {
			ItemEntry() {
				title = 
*/  
  }

    public void show_first_item () {

    }

	public static void main (string[] args) {
		try {
			var db = new Fido.Database();
			db.create_tables ();
			db.create_feeds ();
			db.create_items ();
		} catch (SQLHeavy.Error e) {
			stdout.printf ("Error: %s\n", e.message);
		}
	}
}

}