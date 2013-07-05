using SQLHeavy;

namespace Fido {
    
enum {
    STEVES_FOOD,
    FRIEND_TOM,
    WORK_STUFF,
    TIME_WASTE
};

public class Database {
    private db;
    public Database {
	this.db = new SQLHeavy.Database (":memory:",
					 FileMode.READ |
					 FileMode.WRITE |
					 FileMode.CREATE);
	
    }

    public create_tables () {
	this.db.execute ("""
            CREATE TABLE items (
                item_title               TEXT,
                item_content             TEXT,
                item_posted              INTEGER,
                item_updated             INTEGER,
                item_is_read             INTEGER DEFAULT 0,
                item_mute                INTEGER,
                feed_id                  INTEGER NOT NULL
            )""");
        this.db.execute ("""
            CREATE TABLE feeds (
                feed_id                  INTEGER PRIMARY KEY,
                feed_title               TEXT,
                feed_metadata            TEXT,
                feed_priority            INTEGER DEFAULT 0,
                feed_mute                INTEGER
            )""");
    }

    public create_feeds () {
	var trans = this.db.begin_transaction ();
	// can you do this?
	void insert (string title, int64 feed, int64 prio) {
	    trans.execute ("""
                INSERT INTO `feeds` (
                    feed_title, 
                    feed_id,
                    feed_priority)
                VALUES (:title, :id, :prio)""",
			   ":title", typeof(string), title,
			   ":feed", typeof(int64), feed,
			   ":prio", typeof(int64), prio);
	};
	insert ("Steve's Food",   STEVES_FOOD,    0);
        insert ('Friend Tom',     FRIEND_TOM,     2);
        insert ('Work Stuff',     WORK_STUFF,     1);
        insert ('Time Waste',     TIME_WASTE,     0);
	trans.commit ();
    }

    public create_items () {
    }

    public show_first_item () {

    }
}
