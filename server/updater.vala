namespace Fido {

public class Updater : Object {

	// How often, in seconds, each feed should be updated.
	public static const int UPDATE_INTERVAL = 10; 

	// How many download jobs we can have simultaneously
	public static const int MAX_JOBS = 5;

	private Database database;
	private Soup.SessionAsync session;

	private Gee.Queue<Fido.Feed> jobs_to_run;
	private Gee.Set<Fido.Feed> running_jobs;

	public Updater (Database database) {
		this.database = database;
		this.jobs_to_run = new Gee.LinkedList<Fido.Feed> ();
		this.running_jobs = new Gee.HashSet<Fido.Feed> ();
		this.session = new Soup.SessionAsync ();
	}

	// Would want to pass the Fido.Feed, but there's a bug

	public void handle_update (string feedurl, string body) {
		stdout.printf ("Parsing string beginning with %s\n", body[0:20]);
	}

	public void work_on_queue () {
		while (jobs_to_run.size > 0 && running_jobs.size < MAX_JOBS) {
			var feed = jobs_to_run.poll ();
			stdout.printf ("Starting download of %s\n", feed.source);
			var msg = new Soup.Message ("GET", feed.source);
			session.queue_message (msg, (s, m) => {
					stdout.printf (@"Got response: $(m.status_code) - ");
					if (m.status_code == 200) {
						this.handle_update (m.get_uri ().to_string (false),
											(string) m.response_body.data);
					}
					// MessageBody response = m.response_body;
					// stdout.write (m.response_body.data);
					stdout.printf (@"$(m.response_body.length) bytes\n");
				});
		}
	}
	
	public void check_for_updates () {
		stdout.printf ("Time for update!\n");
		var cutoff = new DateTime.now_utc().add_seconds(-UPDATE_INTERVAL);
		var feeds = database.get_feeds_not_updated_since(cutoff);
		foreach (var feed in feeds) {
			stdout.printf ("Queueing: %s [%s]\n", feed.title, feed.source);
			this.jobs_to_run.offer (feed);
		}
		if (!feeds.is_empty) {
			work_on_queue (); 
		}

	}
}

}