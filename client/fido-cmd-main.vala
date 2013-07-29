/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

namespace Fido {

    class FidoCmd : GLib.Object {

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

        protected void cmd_discover (string[] args) throws IOError {
            if (args.length != 1) {
                stderr.printf ("bad discover command\n");
                return;
            }
            var loop = new MainLoop ();
            server.discover.begin (args [0], (obj, res) => {
                FeedSerial[] feeds = server.discover.end (res);
                foreach (var feed in feeds) 
                    stdout.printf ("%s [%s]\n", feed.title, feed.source);
                loop.quit ();
            });
            loop.run();
        }

        protected void cmd_subscribe (string[] args) throws IOError {
            if (args.length == 1)
                server.subscribe (args [0]);
            else
                stderr.printf ("bad subscribe command\n");
        }

        protected void cmd_feeds () throws IOError {
            FeedSerial[] feeds = server.get_feeds ();
            foreach (var feed in feeds)
                stdout.printf ("%s [%s]\n", feed.title, feed.source);
        }

        protected void cmd_show () throws IOError {
            ItemSerial item = server.get_current_item ();
            stdout.printf ("Title: %s\n", item.title);
            stdout.printf (item.description);
        }

        protected void cmd_update_all () throws IOError {
            server.update_all();
        }

        // Static stuff

        static bool version;

        const OptionEntry[] main_options = {
            { "version", 0, 0, OptionArg.NONE, ref version, 
              "Display version number", null },
            { null }
        };

        static int main (string[] args) {
            var client = new Fido.FidoCmd ();

            var option_ctx = new OptionContext (_(""" - commandline interface for the Fido News Reader

Available commands:

  subscribe <URL>         Subscribe to a feed
  feeds                   List feeds
  update all              Force updating of all feeds
  show                    Show current item"""));

            option_ctx.add_main_entries (main_options, null);

            try {
                option_ctx.parse (ref args);
            } catch (OptionError e) {
                stderr.printf ("%s\n", e.message);
                return 1;
            }

            if (version) {
                stdout.printf ("fido-cmd %s\n", Config.VERSION);
                return 0;
            }

            args = args[1:args.length];

            try {
                switch (args[0]) {
                case "discover":
                    client.cmd_discover (args[1:args.length]);
                    break;

                case "subscribe":
                    client.cmd_subscribe (args[1:args.length]);
                    break;

                case "feeds":
                    client.cmd_feeds ();
                    break;

                case "show":
                    client.cmd_show ();
                    break;
                
                case "update":
                    if (args.length > 1 && args[1] == "all")
                        client.cmd_update_all ();
                    else {
                        stderr.printf (" only \"update all\" is supported\n");
                        return 1;
                    }
                    break;
                        
                default:
                    stderr.printf ("error: unknown command: %s\n",
                                   args[0]);
                    return 1;
                }
            } catch (IOError e) {
                stderr.printf ("%s\n", e.message);
                return 1;
            }

            return 0;
        }
    }

}
