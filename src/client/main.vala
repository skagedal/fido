using GLib;

[DBus (name = "org.gitorious.Fido.FeedStore")]
interface  Fido.DBus.FeedStore : Object {
	public abstract void subscribe (string url) throws IOError;
}

class FidoClient : GLib.Object {

	static bool version;

	const OptionEntry[] main_options = {
		{ "version", 0, 0, OptionArg.NONE, ref version, 
		  "Display version number", null },
		{ null }
	};

	static int main (string[] args) {
		Fido.DBus.FeedStore server = null;

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
		
		try {
			server = Bus.get_proxy_sync (BusType.SESSION, 
										 "org.gitorious.Fido.FeedStore",
										 "/org/gitorious/Fido/FeedStore");

			server.subscribe ("foo");
			stdout.printf ("Sent subscribe\n");
		} catch (IOError e) {
			stderr.printf ("%s\n", e.message);
		}

		return 0;
	}

}

