/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Gtk;

namespace Fido {

    public class SubscribeDialog : Dialog {
	    private FeedList feedlist;

        private Fido.DBus.FeedStore _server = null;	    
        
	    public SubscribeDialog (string url, Fido.DBus.FeedStore server) {
            this._server = server;
        
            this.title = _("Fido: Subscribe Feed");
            this.border_width = 10;
            this.window_position = WindowPosition.CENTER;
            this.set_default_size (350, 70);

            this.feedlist = new FeedList ();

            server.discover.begin (url, (obj, res) => {
                FeedSerial[] feeds;
                try {
                    feeds = server.discover.end (res);
                } catch (IOError e) {
                    show_error (_("DBus error: %s").printf (e.message), this);
                    this.destroy ();
                    return;
                }
                if (feeds.length == 0) {
                    show_error (_("No feeds found for %s.").printf(url), this);
                    this.destroy ();
                } else {
                    foreach (var feedserial in feeds) {
                        var feed = new Feed.from_serial (feedserial);
                        this.feedlist.add_feed (feed);
                    }
                }
            });                

            feedlist.feed_picked.connect((feed) => {
                try {
                    server.subscribe (feed.source);
                    show_info (_("Subscribed to %s.").printf(feed.title), this);
                } catch (IOError e) {
                    show_error (_("DBus error: %s").printf (e.message), this);
                }
                this.destroy ();
            });
            
	        var content = get_content_area () as Box;
	        content.pack_start (this.feedlist, false, true, 0);

            add_button ("_Close", Gtk.ResponseType.CLOSE);
	        
	        show_all ();
	    }
    }

    void show_error (string text, Gtk.Window? parent = null) {
        var msg = new Gtk.MessageDialog (parent, 
                                         Gtk.DialogFlags.MODAL, 
                                         Gtk.MessageType.ERROR, 
                                         Gtk.ButtonsType.CLOSE,
                                         text);
        if (parent == null)
            msg.skip_taskbar_hint = false;
        msg.title = _("Fido: Subscribe Feed");
        msg.run ();
        msg.destroy ();
    }
    
    void show_info (string text, Gtk.Window? parent = null) {
        var msg = new Gtk.MessageDialog (parent, 
                                         Gtk.DialogFlags.MODAL, 
                                         Gtk.MessageType.INFO, 
                                         Gtk.ButtonsType.CLOSE,
                                         text);
        if (parent == null)
            msg.skip_taskbar_hint = false;
        msg.title = _("Fido: Subscribe Feed");
        msg.run ();
        msg.destroy ();
    }

    int main (string[] args) {
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        Fido.DBus.FeedStore server;
        try {
            server = Bus.get_proxy_sync (BusType.SESSION, 
                                      "org.gitorious.Fido.FeedStore",
                                      "/org/gitorious/Fido/FeedStore");
        } catch (IOError e) {
            show_error ("Couldn't connect to server: %s\n".printf (e.message), null);
            return 1;
        }

        Gtk.init (ref args);

        if (args.length != 2) {
            show_error (_("Please specify an URL as an argument to fido-subscribe."));
        } else {
            var dialog = new SubscribeDialog (args[1], server);
            dialog.destroy.connect (Gtk.main_quit);
            dialog.response.connect (Gtk.main_quit);
            dialog.show ();

            Gtk.main ();
        }
        
        return 0;
    }
}
