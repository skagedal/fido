/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

namespace Fido {

    //public class ApplicationWindow : Gtk.ApplicationWindow {
    //}

    public class Application : Gtk.Application {

        static bool print_version;
        const OptionEntry[] option_entries = {
            { "version", 'v', 0, OptionArg.NONE, ref print_version, N_("Print version information and exit"), null },
            { null }
        };

        private Fido.DBus.FeedStore _server = null;

        public Fido.DBus.FeedStore server {
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

        protected override void startup () {
            base.startup ();
            
            // Not sure if this or DOCUMENT_BROWSER is best
            WebKit.set_cache_model (WebKit.CacheModel.DOCUMENT_VIEWER);
            
            stderr.printf ("Starting..\n");
        }

        protected override void activate () {
            // Create the window of this application and show it
            var window = new Fido.AppWindow (this);
            window.show_all ();
            /*Gtk.ApplicationWindow window = new Gtk.ApplicationWindow (this);
            window.set_default_size (400, 400);
            window.title = "My Gtk.Application";

            Gtk.Label label = new Gtk.Label ("Hello, GTK");
            window.add (label);
            window.show_all (); */
        }
        
        protected override bool local_command_line ([CCode (array_length = false, array_null_terminated = true)] ref unowned string[] arguments, out int exit_status) {
            var ctx = new OptionContext (_("- News Reader"));

            ctx.add_main_entries (option_entries, Config.GETTEXT_PACKAGE);
            ctx.add_group (Gtk.get_option_group (true));

            // Workaround for bug #642885
            unowned string[] argv = arguments;

            try {
                ctx.parse (ref argv);
            } catch (Error e) {
                exit_status = 1;
                return true;
            }

            if (print_version) {
                print ("%s %s\n", Environment.get_application_name (), Config.VERSION);
                exit_status = 0;
                return true;
            }

            return base.local_command_line (ref arguments, out exit_status);
        }

    }

}
