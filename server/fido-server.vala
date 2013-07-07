// Should we have timeout = 120000 as Geary does?
 
[DBus (name = "org.gitorious.Fido.FeedStore")]
public class Fido.DBus.FeedStoreImpl : Object, Fido.DBus.FeedStore {
    public static const string INTERFACE_NAME = "org.gitorious.Fido.FeedStore";

	public void subscribe (string url) {
		stdout.printf ("Subscribing to %s\n", url);
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

void on_bus_aquired (DBusConnection conn) {
    try {
        // start service and register it as dbus object
        var service = new Fido.DBus.FeedStoreImpl();
        conn.register_object ("/org/gitorious/Fido/FeedStore", service);
    } catch (IOError e) {
        stderr.printf ("Could not register service: %s\n", e.message);
    }
}

void main () {
    // See https://developer.gnome.org/gio/stable/gio-Owning-Bus-Names.html
    Bus.own_name (BusType.SESSION, 
		  Fido.DBus.FeedStoreImpl.INTERFACE_NAME,
		  BusNameOwnerFlags.NONE,
                  on_bus_aquired,
                  () => {},
                  () => stderr.printf ("Could not aquire name\n"));

    new MainLoop ().run ();
}
