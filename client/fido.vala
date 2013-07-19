namespace Fido {

class Client : GLib.Object {

	private Fido.DBus.FeedStore _server = null;

	protected Fido.DBus.FeedStore server () {
		if (this._server != null)
			return this._server;

		try {
			this._server = Bus.get_proxy_sync (BusType.SESSION, 
											   "org.gitorious.Fido.FeedStore",
											   "/org/gitorious/Fido/FeedStore");

		} catch (IOError e) {
			stderr.printf ("%s\n", e.message);
		}
		return this._server;
	}


	protected void cmd_subscribe (string[] args) throws IOError {
		if (args.length == 1) {
			this.server().subscribe (args [0]);
		} else {
			stderr.printf ("bad subscribe command\n");
		}
	}

	protected void cmd_feeds () throws IOError {
		FeedSerial[] feeds = this.server().get_feeds ();
		foreach (var feed in feeds) {
			stdout.printf ("%s [%s]\n", feed.title, feed.source);
		}
	}

	protected void cmd_show () throws IOError {
		ItemSerial item = this.server().get_current_item ();
		stdout.printf ("Title: %s\n", item.title);
		stdout.printf (item.description);
	}

    protected void cmd_update_all () throws IOError {
        this.server().update_all();
    }

	// Static stuff

	static bool version;

	const OptionEntry[] main_options = {
		{ "version", 0, 0, OptionArg.NONE, ref version, 
		  "Display version number", null },
		{ null }
	};



	static int main (string[] args) {
		var client = new Fido.Client ();

		var option_ctx = new OptionContext (""" - a news reader

Available commands:

  subscribe <URL>         Subscribe to a feed
  feeds                   List feeds
  update all              Force updating of all feeds
  show                    Show current item""");


		option_ctx.add_main_entries (main_options, null);

		try {
			option_ctx.parse (ref args);
		} catch (OptionError e) {
			stderr.printf ("%s\n", e.message);
			return 1;
		}


		if (version) {
			stdout.printf ("fido doesn't even have a version yet\n");
			return 0;
		}


		if (args.length == 1) {
    		var app = new FidoApplication ();
    		return app.run (args);
		} else {
       		args = args[1:args.length];

		    try {
				switch (args[0]) {
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
                        stderr.printf ("error: only \"update all\" is supported");
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
		}
		return 0;
	}

}

}
