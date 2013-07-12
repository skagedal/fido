namespace Fido {

public class Updater : Object {

	// How often, in seconds, each feed should be updated.
	public static const int FEED_UPDATE_INTERVAL = 10; 

	private Database database;

	public Updater (Database database) {
		this.database = database;
	}
	
	public void run () {
		stdout.printf ("Time for update!\n");
		var cutoff = new DateTime.now_utc().add_seconds(-FEED_UPDATE_INTERVAL);
		var feeds = database.get_feeds_not_updated_since(cutoff);
		foreach (var feed in feeds) {
			stdout.printf ("Queueing: %s [%s]\n", feed.title, feed.source);
		}
	}
}

}