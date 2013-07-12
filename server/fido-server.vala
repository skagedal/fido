// Should we have timeout = 120000 as Geary does?
 
[DBus (name = "org.gitorious.Fido.FeedStore")]
public class Fido.DBus.FeedStoreImpl : Object, Fido.DBus.FeedStore {
    public static const string INTERFACE_NAME = "org.gitorious.Fido.FeedStore";

	private Fido.Server server;

	/**
	 * Constructor.
	 */
	public FeedStoreImpl (Fido.Server server) {
		this.server = server;
	}

	public void subscribe (string url) {
		stdout.printf ("Subscribing to %s\n", url);
		try {
			var channel = new Grss.FeedChannel.with_source (url);
			this.server.database.add_feed (channel);
		} catch (SQLHeavy.Error e) {
			error ("subscribe: database error");
		}
	}

	public Fido.DBus.Feed[] get_feeds () {
		return this.server.database.get_feeds ();
	}

	public Fido.DBus.Item get_current_item () {
		Item item = { "Test item" };
		return item;
	}

/*
	public delegate void DiscoverCallback (string [] feeds);
	public void discover (string url, DiscoverCallback cb) {
		stdout.printf ("Discovering %s, let's say I found foo and bar", url);
		cb({"foo", "bar"});
	}
*/

}

public class Fido.Server : Object {

	private Fido.DBus.FeedStoreImpl service;
	private Fido.Database _database;

	public Server () {
		try {
			// For now, use in-memory database
			this._database = new Database ();
		} catch (SQLHeavy.Error e) {
			error ("Server(): couldn't create database");
		}
	}

	public Fido.Database database { get { return this._database; } }

	public void on_bus_aquired (DBusConnection conn) {
		try {
			// start service and register it as dbus object
			this.service = new Fido.DBus.FeedStoreImpl(this);
			conn.register_object ("/org/gitorious/Fido/FeedStore", this.service);
		} catch (IOError e) {
			stderr.printf ("Could not register service: %s\n", e.message);
		}
	}

	public static void main (string args []) {
		
		var server = new Fido.Server();

		// See https://developer.gnome.org/gio/stable/gio-Owning-Bus-Names.html
		Bus.own_name (BusType.SESSION, 
					  Fido.DBus.FeedStoreImpl.INTERFACE_NAME,
					  BusNameOwnerFlags.NONE,
					  server.on_bus_aquired,
					  () => {},
					  () => stderr.printf ("Could not aquire name\n"));
		
		new MainLoop ().run ();
	}
}