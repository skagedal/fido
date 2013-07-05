using Gtk;
using WebKit;

namespace Fido {

/*
 * Model
 */
 
 public class Item : GLib.Object {
    public string title = "Foo Item";
 }
 
 public class Feed : GLib.Object {
    public string title = "Foo Feed";
 }


/*
 * View for showing the current item
 */
public class ItemView : WebView {
    public ItemView () {
	load_string ("<html><body><h1>Showing an item</h1><p>Hello, World</p></html>",
		     "text/html",
		     "utf-8",
		     "");
    }
}

public delegate void ItemActionCallback (Item i);
public delegate void FeedActionCallback (Feed f);

public class ItemAction : Bin {
    private ItemActionCallback callback;
    
    public ItemAction (string text, ItemActionCallback cb) {
		var button = new Button.with_label (text);
		add (button);
		this.callback = cb;
    }
}

public class FeedAction : Bin {
    private FeedActionCallback callback;
    
    public FeedAction (string text, FeedActionCallback cb) {
		var button = new Button.with_label (text);
		add (button);
		this.callback = cb;
    }
}

/*
 * View for item actions and feed actions
 */
public class ActionView : Box {
    public ActionView () {
		this.orientation = Orientation.VERTICAL;

		var item_label = new Label("Item actions");
		var mark_action = new ItemAction("Mark", (item) => {
				stdout.printf ("Marking item %s as read.\n", 
							   item.title);
			});
		var later_action = new ItemAction("Later", (item) => {
				stdout.printf ("Lowering priority of item %s.\n", 
							   item.title);
			});
	
		var feed_label = new Label("Feed actions");
		var raise_feed_action = new FeedAction ("Raise priority", (feed) => {
				stdout.printf ("Raising priority of feed %s.\n", 
							   feed.title);
			});
		var lower_feed_action = new FeedAction ("Lower priority", (feed) => {
				stdout.printf ("Lowering priority of feed %s.\n", 
							   feed.title);
			}); 
		var unsubscribe_feed_action = new FeedAction ("Unsubscribe", (feed) => {
				stdout.printf ("Unsubscribing feed %s.\n", feed.title);
			}); 

		pack_start (item_label, false, true, 0);
		pack_start (mark_action, false, true, 0);
		pack_start (later_action, false, true, 0);
	
		pack_start (feed_label, false, true, 0);
		pack_start (raise_feed_action, false, true, 0);
		pack_start (lower_feed_action, false, true, 0);
		pack_start (unsubscribe_feed_action, false, true, 0);
    }
}

/* 
 * The main window
 */
public class AppWindow : Window {
    private ItemView item_view;
    private ActionView action_view;
    
    public AppWindow () {
		this.title = "Fido News Reader";
        this.window_position = WindowPosition.CENTER;
        set_default_size (400, 300);

        var toolbar = new Toolbar ();
        toolbar.get_style_context ().add_class (STYLE_CLASS_PRIMARY_TOOLBAR);

        var open_button = new ToolButton.from_stock (Stock.OPEN);  	// should be Subscribe...
        open_button.is_important = true;				// what does this do?
        toolbar.add (open_button);
        open_button.clicked.connect (on_subscribe_clicked);

		this.item_view = new ItemView ();
		this.action_view = new ActionView ();
		
		var hpaned = new Paned (Orientation.HORIZONTAL);
		hpaned.pack1 (item_view, true, true);
		hpaned.pack2 (action_view, false, true);
	
        var vbox = new Box (Orientation.VERTICAL, 0);
        vbox.pack_start (toolbar, false, true, 0);
        vbox.pack_start (hpaned, true, true, 0);
        add (vbox);
    }

    private void on_subscribe_clicked () {
        // This code should go away
        var file_chooser = new FileChooserDialog ("Open File", this,
                                      FileChooserAction.OPEN,
                                      Stock.CANCEL, ResponseType.CANCEL,
                                      Stock.OPEN, ResponseType.ACCEPT);
        if (file_chooser.run () == ResponseType.ACCEPT) {
            stdout.printf (file_chooser.get_filename ());
        }
        file_chooser.destroy ();
    }


    public static int main (string [] args) {
	Gtk.init (ref args);
	
	var window = new AppWindow ();
	window.destroy.connect (Gtk.main_quit);
	window.show_all ();
	
	Gtk.main ();
	return 0;
    }
}

}
