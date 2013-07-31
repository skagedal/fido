/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Fido.Logging;

[DBus (name = "org.gitorious.Fido.FeedStore")] // Should we have timeout = 120000 as Geary does?
public class Fido.DBus.FeedStoreImpl : Object /*, Fido.DBus.FeedStore */ {
    public static const string INTERFACE_NAME = "org.gitorious.Fido.FeedStore";

    private Fido.Server server;

    /**
     * Constructor.
     */
    public FeedStoreImpl (Fido.Server server) {
        this.server = server;
    }

    /* 
     * Serialization helpers.
     */

    private FeedSerial[] serialize_feeds (Gee.List<Feed>? feeds) {
        var feedlist = new FeedSerial[0]; 
        if (feeds != null) {
            foreach (var feed in feeds)
                feedlist += feed.to_serial();
        }
        return feedlist;        
    }

    /*
     * Methods dealing with feeds.
     */

    public async FeedSerial[] discover (string url) {
        var uri = Fido.Utils.check_uri(url);
        var feeds = yield server.updater.discover_async (uri);
        return serialize_feeds (feeds);
    }

    public void subscribe (string url) {
        var uri = Fido.Utils.check_uri(url);
        Logging.message (Flag.SERVER, "Subscribing to %s", uri);
        try {
            this.server.database.add_feed (uri);
        } catch (DatabaseError e) {
            Logging.critical (Flag.SERVER, @"Subscribing to $(uri): $(e.message)");
        }
    }

    public void unsubscribe (int id) {
        try {
            this.server.database.remove_feed (id);
        } catch (DatabaseError e) {
            Logging.critical (Flag.SERVER, @"Unsubscribing feed $(id): $(e.message)");
        }
    }

    public FeedSerial[] get_feeds () {
        try {
            var feeds = server.database.get_all_feeds();
            return serialize_feeds(feeds);
        } catch (DatabaseError e) {
            Logging.critical(Flag.SERVER, @"get_feeds: database error: $(e.message)");
        }
        return new FeedSerial[0];
    }

    public FeedSerial get_feed (int id) {
        try {
            return server.database.get_feed(id).to_serial();
        } catch (DatabaseError e) {
            Logging.critical(Flag.SERVER, @"get_feed $(id): $(e.message)");
        }
        return FeedSerial();
    }

    public void update_all () {
        this.server.updater.force_update_all();
    }

    /*
     * Methods dealing with items.
     */

    public ItemSerial get_current_item () {
        try {
            var item = server.database.get_first_item();
            if (item != null)
                return item.to_serial();
        } catch (DatabaseError e) {
            Logging.critical(Flag.SERVER, @"Getting current item: $(e.message)");
        }
        return ItemSerial();
    }

    public void mark_item_as_read (int id) {
        try {
            server.database.set_item_read_time(id, 0);
        } catch (DatabaseError e) {
            Logging.critical(Flag.SERVER, @"Marking item $(id) read: $(e.message)");
        }
    }
    
    public void set_item_priority_relative (int id, int diff) {
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
    private Updater _updater;

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

        this._updater = new Updater (this._database);

        var timeout = new TimeoutSource.seconds (300);
        timeout.set_callback(() => {
            this._updater.check_for_updates ();
            return true;    
        });
        timeout.attach (this.mainloop.get_context ());
        
        // Schedule a single update
        Idle.add (() => {
            this._updater.check_for_updates ();
            return false;
        });
    }

    public Fido.Database database { get { return this._database; } }
    public Fido.Updater updater { get { return this._updater; } }

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
        stderr.printf("%s\n", Config.PATH_PACKAGE_DATA);
    
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
