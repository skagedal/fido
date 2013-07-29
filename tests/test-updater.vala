/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Fido;

[DBus (name = "org.gitorious.fido.TestWebserver")]
interface WebServer : Object {
    public abstract void add_path (string path, string xml) throws IOError;
}


class TestUpdater : Gee.TestCase {
    Pid webserver_pid;
    WebServer server;
    
    public TestUpdater() {
        base("Fido.Updater");
        add_test("test_simple_update", test_simple_update);
    }
 
    public override void set_up () {
//        stderr.printf ("Starting webserver...\n");

        // Might want to remove this if tests do fail
        Logging.set_flags (Logging.Flag.NONE);

        // Spawn webserver
        Pid pid;
        try {
            Process.spawn_async (null, { "test-webserver" }, null, 0, null, out pid);
        } catch (SpawnError e) {
            error (e.message);
        }
        this.webserver_pid = pid;

        // Wait for it to have registered it's DBus service
        var waitloop = new MainLoop ();
        Bus.watch_name (BusType.SESSION, "org.gitorious.fido.TestWebserver", BusNameWatcherFlags.NONE,
                        (conn, name, owner) => {
                           waitloop.quit();
                        }, null);
        waitloop.run();
        
        try {
            server = Bus.get_proxy_sync (BusType.SESSION, "org.gitorious.fido.TestWebserver",
                                                          "/org/gitorious/fido/TestWebserver");
        } catch (IOError e) {
            error (e.message);
        }
      }

    public override void tear_down () {
        Posix.kill ((int) this.webserver_pid, Posix.SIGTERM);
    }

    public void test_simple_update () {
        try {
            server.add_path ("/simple_update", """<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
  <channel>
    <title>Simple update</title>
    <item>
      <title>Item</title>
      <link>http://localhost:8088/item/</link>
      <description>A simple item.</description>
      <pubDate>Fri, 26 Jul 2013 04:00:00 -0000</pubDate>
      <guid>http://localhost:8088/item/</guid>
    </item>
  </channel>
</rss>
            """);
            var database = new Database (null);
            var updater = new Updater (database);
            database.add_feed ("http://localhost:8088/simple_update");
            updater.force_update_all ();
            updater.sync ();
            var item = database.get_first_item ();
            assert (item.title == "Item");
            var time = new DateTime.utc (2013, 07, 26, 04, 00, 00).to_unix ();
            assert (item.publish_time == time);
            database.set_item_read_time (item.id);
            assert (database.get_first_item () == null);
            updater.force_update_all ();
            updater.sync ();
            assert (database.get_first_item () == null);
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
            assert_not_reached ();
        }
    }
}
