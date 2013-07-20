/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

namespace Fido {

    public class Application : Gtk.Application {

        private Fido.DBus.FeedStore _server = null;

        protected Fido.DBus.FeedStore server {
            get {
                if (this._server != null)
                    return this._server;

                try {
                    this._server = Bus.get_proxy_sync (BusType.SESSION, 
                                       "org.gitorious.Fido.FeedStore",
                                       "/org/gitorious/Fido/FeedStore");
                } catch (IOError e) {
                    GLib.error ("Couldn't connect to server: %s\n", e.message);
                }
                return this._server;
            }
        }
    
        public Application () {
            Object(application_id: "org.gitorious.fido",
                   flags: ApplicationFlags.FLAGS_NONE);
        }

        protected override void activate () {
            // Create the window of this application and show it
            var window = new Fido.AppWindow (this);
            window.show_all ();
        }
    }

}
