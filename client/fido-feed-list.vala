/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

namespace Fido {
    public class FeedList : Egg.ListBox {
        private List<Feed> feeds = null;
        
        construct {
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_separator_funcs (update_separator);
        }

        void update_separator (ref Gtk.Widget? separator, Gtk.Widget widget, Gtk.Widget? before_widget) {
            if (before_widget != null && separator == null) {
                separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            } else {
                separator = null;
            }
        }

        public override void child_activated (Gtk.Widget? widget) {
            var feedwidget = widget as FeedListWidget;
            stdout.printf("Activated: %s\n", feedwidget.feed.title);
        }

        public void update () {
            this.foreach ((widget) => { widget.destroy (); });

            foreach (var feed in feeds) {
                add (new FeedListWidget (feed));
            }

            show_all ();
        }

        public void add_feed (Feed feed) {
            feeds.append (feed);
            
            update ();
        }
    }
}
