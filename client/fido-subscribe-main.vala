/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Gtk;

namespace Fido {

    public class SubscribeDialog : Dialog {
	    private FeedList feedlist;
	    
	    public SubscribeDialog () {
            this.title = _("Fido: Subscribe Feed");
            this.border_width = 10;
            this.window_position = WindowPosition.CENTER;
            this.set_default_size (350, 70);

            this.feedlist = new FeedList ();
            var feed = new Feed.with_id(0);
            feed.source = "http://foo.com/";
            feed.title = "The Foo blog";
            this.feedlist.add_feed (feed);
            feed = new Feed.with_id(0);
            feed.source = "http://very.long/super/silly/url/";
            feed.title = "And this is another fine feed";
            this.feedlist.add_feed (feed);
	
	        var content = get_content_area () as Box;
	        content.pack_start (this.feedlist, false, true, 0);
	        
	        show_all ();
	    }
    }

    int main (string[] args) {
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        Gtk.init (ref args);

        var dialog = new SubscribeDialog ();
        dialog.destroy.connect (Gtk.main_quit);
        dialog.show ();
        Gtk.main ();

        return 0;
    }
}
