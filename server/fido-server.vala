using Fido.Logging;

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
			Logging.error (Flag.SERVER, "subscribe: database error");
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
	private MainLoop mainloop;
	private Updater updater;

	public Server () {
	    Logging.debug (Flag.SERVER, "Creating mainloop");
		this.mainloop = new MainLoop ();
	}

    /** 
     * Initializes database, and things that depends on the database
     * being initialized.
     */
    public void init_db (bool memory = false, string? filename = null) throws SQLHeavy.Error, DatabaseError {
	    string db_filename;
	    if (memory)
	        db_filename = null;
	    else
	        db_filename = filename ?? get_default_database_filename();
	    Logging.message (Flag.SERVER, "Initializing database: %s", db_filename);

		this._database = new Database (db_filename);

		this.updater = new Updater (this._database);

		var timeout = new TimeoutSource.seconds (1);
		timeout.set_callback(() => { 
				updater.check_for_updates (); 
				return true;
			});
		timeout.attach (this.mainloop.get_context ());
    }

	public Fido.Database database { get { return this._database; } }

    public string get_user_data_directory() {
        return Path.build_filename(Environment.get_user_data_dir(), "fido");
    }
    
    public string get_default_database_filename() {
        return Path.build_filename(get_user_data_directory(), "fido.db");
    }
    
	public void on_bus_aquired (DBusConnection conn) {
		try {
			// start service and register it as dbus object
			this.service = new Fido.DBus.FeedStoreImpl(this);
			conn.register_object ("/org/gitorious/Fido/FeedStore", this.service);
		} catch (IOError e) {
			stderr.printf ("Could not register service: %s\n", e.message);
		}
	}

	public int run () {
		this.mainloop.run ();
		return 0;
	}

    static bool version;
    static bool memory_db;

	const OptionEntry[] main_options = {
		{ "version", 0, 0, OptionArg.NONE, ref version, 
		  "Display version number", null },
		{ "memory-db", 0, 0, OptionArg.NONE, ref memory_db,
		  "Use temporary database", null },
		{ null }
	};

	public static int main (string args []) {
		var option_ctx = new OptionContext (""" - server for the Fido news reader""");
		option_ctx.add_main_entries (main_options, null);

		try {
			option_ctx.parse (ref args);
		} catch (OptionError e) {
			stderr.printf ("%s\n", e.message);
			return 1;
		}

		if (version) {
			stdout.printf ("fido-server doesn't even have a version yet\n");
			return 0;
		}

	    var server = new Fido.Server();
		try {
            server.init_db(memory_db);
		} catch (DatabaseError e) {
            Logging.critical (Flag.SERVER, e.message);
            return 1;
		} catch (SQLHeavy.Error e) {
			Logging.critical (Flag.SERVER, "Database error: %s", e.message);
			return 1;
		}
		
		// See https://developer.gnome.org/gio/stable/gio-Owning-Bus-Names.html
		Bus.own_name (BusType.SESSION, 
					  Fido.DBus.FeedStoreImpl.INTERFACE_NAME,
					  BusNameOwnerFlags.NONE,
					  server.on_bus_aquired,
					  () => {},
					  () => stderr.printf ("Could not aquire name\n"));
		
		return server.run ();
	}
}
