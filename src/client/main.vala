using GLib;

[DBus (name = "org.gitorious.Fido.FeedStore")]
interface  Fido.DBus.FeedStore : Object {
	public abstract void subscribe (string url) throws IOError;
}

class FidoClient : GLib.Object {

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


	protected void cmd_subscribe (string[] args) {
		if (args.length == 1) {
			try {
				this.server().subscribe (args [0]);
			} catch (IOError e) {
				stderr.printf ("%s\n", e.message);
			}
		} else {
			stderr.printf ("bad subscribe command\n");
		}
	}

	// Static stuff

	static bool version;

	const OptionEntry[] main_options = {
		{ "version", 0, 0, OptionArg.NONE, ref version, 
		  "Display version number", null },
		{ null }
	};

	static int main (string[] args) {
		var client = new FidoClient ();

		var option_ctx = new OptionContext (""" - a news reader

Available commands:

  subscribe <URL>         Subscribe to a feed
  feeds                   List feeds""");


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

		args = args[1:args.length];

		if (args.length > 0) {
			switch (args[0]) {
			case "subscribe":
				client.cmd_subscribe (args[1:args.length]);
				break;

			default:
				stderr.printf ("error: unknown command: %s\n",
							   args[0]);
				return 1;
			}
		}
		
		return 0;
	}

}

