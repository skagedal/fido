/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Gtk;
using WebKit;

namespace Fido {

    /* 
     * The main window
     */
    public class AppWindow : Gtk.ApplicationWindow {
        Gtk.Button mark_button;
        /*
        Gtk.Button later_button;
        Gtk.Button open_in_browser_button;
        Gtk.Button raise_feed_button;
        Gtk.Button lower_feed_button;
        Gtk.Button unsubscribe_feed_button;
        */
        WebView item_view;
        Fido.Application app;
        Item current_item;
        
        private Gtk.Box create_action_view () {
            var box = new Gtk.Box(Orientation.VERTICAL, 8);
            
            var item_label = new Label(_("Item actions"));
            mark_button = new Button.with_label(_("Mark as read"));
            mark_button.clicked.connect(() => {
                stdout.printf ("Marking item as read.\n");
                this.app.server.mark_item_as_read(this.current_item.id);
                load_current_item();
            });
            
            /*
            later_button = new Button.with_label(_("Read later"));
            later_button.clicked.connect(() => {
                stdout.printf ("Lowering priority of item\n");
            });
            open_in_browser_button = new Button.with_label(_("Open in browser"));
            open_in_browser_button.clicked.connect(() => {
                stdout.printf ("Opening item in browser\n");
            });
    
            var feed_label = new Label(_("Feed actions"));
            raise_feed_button = new Button.with_label(_("Raise priority"));
            raise_feed_button.clicked.connect(() => {
                stdout.printf ("Raising priority of feed\n");
            });
            lower_feed_button = new Button.with_label(_("Lower priority"));
            lower_feed_button.clicked.connect(() => {
                stdout.printf ("Lowering priority of feed\n");
            }); 
            unsubscribe_feed_button = new Button.with_label(_("Unsubscribe"));
            unsubscribe_feed_button.clicked.connect(() => {
                stdout.printf ("Unsubscribing feed\n");
            }); 
            */
            
            box.pack_start (item_label, false, true, 0);
            box.pack_start (mark_button, false, true, 0);
            
            /*          
            box.pack_start (later_button, false, true, 0);
            box.pack_start (open_in_browser_button, false, true, 0);
    
            box.pack_start (feed_label, false, true, 0);
            box.pack_start (raise_feed_button, false, true, 0);
            box.pack_start (lower_feed_button, false, true, 0);
            box.pack_start (unsubscribe_feed_button, false, true, 0); 
            */
            
            return box;
        }
        
        public void update_content () {
            string s = @"<h1>$(current_item.title)</h1>$(current_item.description)";
            item_view.load_string (s, "text/html", "utf-8", "");
        }
        
        public void load_current_item () {
            current_item = new Item.from_serial (this.app.server.get_current_item());
            update_content();
        }
        
        public AppWindow (Fido.Application app_) {
            Object (application: app_);
            
            this.app = app_;
            this.title = "Fido News Reader";
            this.window_position = WindowPosition.CENTER;
            set_default_size (800, 600);

            /*
            var toolbar = new Toolbar ();
            toolbar.get_style_context ().add_class (STYLE_CLASS_PRIMARY_TOOLBAR);

            var open_button = new ToolButton.from_stock (Stock.OPEN);      // should be Subscribe...
            open_button.is_important = true;                // what does this do?
            toolbar.add (open_button);
            open_button.clicked.connect (on_subscribe_clicked);
            */

            var scrolledwindow = new Gtk.ScrolledWindow (null, null);
            item_view = new WebView ();
            scrolledwindow.add(item_view);
            load_current_item ();
            
            var action_view = create_action_view ();
        
            var hpaned = new Paned (Orientation.HORIZONTAL);
            hpaned.pack1 (scrolledwindow, true, true);
            hpaned.pack2 (action_view, false, true);
    
            var vbox = new Box (Orientation.VERTICAL, 0);
            /*
            vbox.pack_start (toolbar, false, true, 0);
            */
            vbox.pack_start (hpaned, true, true, 0);
            add (vbox);
        }

    }

}
