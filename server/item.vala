namespace Fido {

public class Item : Object {
	private Grss.FeedItem grss;

    public Item (Feed parent) {
        this._parent = parent;
    }

	public Item.from_grss (Feed parent, Grss.FeedItem item) {
        this._parent = parent;
		this.grss = item;
	}
	
	public Feed parent { get; private set; }

    /**
     * Some feeds do not give guids to items.  In that case we fake it, using 
     * item's publishing time if exists or otherwise, item's title.  
     * (However, publishing time is not (yet) exposed by grss...)
     * I'm not sure how well this works for real-world feeds.  There will be
     * testing.
     * 
     * While guids should be globally unique, we don't trust feeds to do this
     * since we don't want to risk feed A overwriting feed B:s items. 
     * Therefore items are identified in the database with feed_id + guid.
     * A problem here is what we want to do with duplicates in planets.
     * But let's wait with that. 
     */
    public string guid {
        get {
            unowned string id = this.grss.get_id ();
            if (id != null && id != "")
                return id;
            // publishing time from feed isn't exposed by libgrss...
            return this.grss.get_title ();
        }
    }

    public string author {
	    get { return grss.get_author (); }
	    set { grss.set_author (value); }
	}
    public string description {
	    get { return grss.get_description (); }
	    set { grss.set_description (value); }
	}
    public string source {
	    get { return grss.get_source (); }
	    set { grss.set_source (value); }
	}
    public string title {
	    get { return grss.get_title (); }
	    set { grss.set_title (value); }
	}
    // Sorry for year 2038 bug, should fix libgrss...
    public int64 publish_time {
	    get { return (int64) grss.get_publish_time (); }
	    set { grss.set_publish_time ((long) value); }
	}

    // grss to possibly wrap:
/*
		public unowned GLib.List<string> get_categories ();
		public unowned string get_comments_url ();
		public unowned GLib.List<string> get_contributors ();
		public unowned string get_copyright ();
		public unowned GLib.List<Grss.FeedEnclosure> get_enclosures ();
        // These two should be fixed in .gir/.vapi to mark as output parameters
		public bool get_geo_point (double latitude, double longitude);
		public void get_real_source (string realsource, string title);
*/

}

}
