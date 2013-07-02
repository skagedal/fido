[DBus (name = "org.gitorious.Fido.FeedStore")]
interface  Fido.DBus.FeedStore : Object {
	public abstract void subscribe (string url) throws IOError;
}

void main () {
	Fido.DBus.FeedStore server = null;

	try {
		server = Bus.get_proxy_sync (BusType.SESSION, 
									 "org.gitorious.Fido.FeedStore",
									 "/org/gitorious/Fido/FeedStore");

		server.subscribe ("foo");
		stdout.printf ("Sent subscribe\n");
	} catch (IOError e) {
		stderr.printf ("%s\n", e.message);
	}
}