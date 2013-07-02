// Should we have timeout = 120000 as Geary does?
[DBus (name = "org.gitorious.Fido.FeedStore"]
class Fido.DBus.FeedStore {
    public static const string INTERFACE_NAME = "org.gitorious.Fido.FeedStore";
}

void on_bus_aquired (DBusConnection conn) {
    try {
        // start service and register it as dbus object
        var service = new FeedStore();
        conn.register_object ("/org/gitorious/Fido/FeedStore", service);
    } catch (IOError e) {
        stderr.printf ("Could not register service: %s\n", e.message);
    }
}

void main () {
    // See https://developer.gnome.org/gio/stable/gio-Owning-Bus-Names.html
    Bus.own_name (BusType.SESSION, 
		  FeedStore.INTERFACE_NAME,
		  BusNameOwnerFlags.NONE,
                  on_bus_aquired,
                  () => {},
                  () => stderr.printf ("Could not aquire name\n"));

    new MainLoop ().run ();
}
