// Should we have timeout = 120000 as Geary does?
 
namespace Fido {
	public class Item : GLib.Object {
		public string title { get; set; }
	}
}

[DBus (name = "org.gitorious.Fido.FeedStore")]
public class Fido.DBus.FeedStore : Object {
    public static const string INTERFACE_NAME = "org.gitorious.Fido.FeedStore";

	public void subscribe (string url) {
		stdout.printf ("Subscribing to %s\n", url);
	}

	public Fido.Item get_current_item () {
		return new Fido.Item ();
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
        var service = new Fido.DBus.FeedStore();
        conn.register_object ("/org/gitorious/Fido/FeedStore", service);
    } catch (IOError e) {
        stderr.printf ("Could not register service: %s\n", e.message);
    }
}

void main () {
    // See https://developer.gnome.org/gio/stable/gio-Owning-Bus-Names.html
    Bus.own_name (BusType.SESSION, 
		  Fido.DBus.FeedStore.INTERFACE_NAME,
		  BusNameOwnerFlags.NONE,
                  on_bus_aquired,
                  () => {},
                  () => stderr.printf ("Could not aquire name\n"));

    new MainLoop ().run ();
}
