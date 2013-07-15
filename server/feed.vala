/**
 * The Feed class is used on both the client and the server.
 *
 * On the server it can have two main states:
 *  - No id set, means it has just been created and does not have a database
 *    connection
 *  - Id is set 
 */
 
using Fido.Logging;

namespace Fido {

public class Feed : Object {
	private Grss.FeedChannel grss;
	private Gee.Set<Item> items;
	
	public Feed.with_id (int id) {
		this._id = id;
		grss = new Grss.FeedChannel ();
		items = new Gee.HashSet<Item> ();
	}
	public Feed.from_grss (Grss.FeedChannel channel) {
        grss = channel;
        items = new Gee.HashSet<Item> ();
	    }

    /** row id from database - null means this feed isn't connected to a database row, a new feed */
    public int id { get; set; }

    public int priority { get; set; }
    public int64 updated_time { get; set; }

    /** URL for feed. Must be unique. */
	public string source { 
	    get { return grss.get_source (); }
	    set { grss.set_source (value); }
	}

    // The following are just plain Grss wrappers

	public string title { 
	    get { return grss.get_title (); }
	    set { grss.set_title (value); }
	}
	public string description { 
	    get { return grss.get_description (); }
	    set { grss.set_description (value); }
	}
	public string category { 
	    get { return grss.get_category (); }
	    set { grss.set_category (value); }
	}
	public string webmaster { 
	    get { return grss.get_webmaster (); }
	    set { grss.set_webmaster (value); }
	}
	public string copyright { 
	    get { return grss.get_copyright (); }
	    set { grss.set_copyright (value); }
	}
	public string editor { 
	    get { return grss.get_editor (); }
	    set { grss.set_editor (value); }
	}
	public string format { 
	    get { return grss.get_format (); }
	    set { grss.set_format (value); }
	}
	public string generator { 
	    get { return grss.get_generator (); }
	    set { grss.set_generator (value); }
	}
	public string homepage { 
	    get { return grss.get_homepage (); }
	    set { grss.set_homepage (value); }
	}
	public string icon { 
	    get { return grss.get_icon (); }
	    set { grss.set_icon (value); }
	}
	public string image { 
	    get { return grss.get_image (); }
	    set { grss.set_image (value); }
	}
	public string language { 
	    get { return grss.get_language (); }
	    set { grss.set_language (value); }
	}
    // FIXME: do we lose data here, converting from int64 to long?
	public int64 publish_time { 
	    get { return (int64) grss.get_publish_time (); }
	    set { grss.set_publish_time ((long) value); }
	}
	public int64 update_time { 
	    get { return (int64) grss.get_update_time (); }
	    set { grss.set_update_time ((long) value); }
	}

/*
Grss to wrap:
	public unowned GLib.List<string> get_contributors ();
*/


    public void parse (string body) {
        try {
            var grss_feed = new Grss.FeedChannel.with_source (this.source);
            var parser = new Grss.FeedParser ();
            var grss_items = parser.parse_from_string (grss_feed, body);

            this.grss = grss_feed;
            this.items.clear ();
            foreach (var grss_item in grss_items) {
                stdout.printf (" - %s\n", grss_item.get_title ());
                this.items.add (new Item.from_grss (this, grss_item));
            }
        } catch (Error e) {
            Logging.warning (Flag.UPDATER, "Parse error: %s", e.message);
        }        
    }

}

} // namespace Fido
