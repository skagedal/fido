using Fido.Logging;

namespace Fido {

public class Updater : Object {

	// How often, in seconds, each feed should be updated.
	public static const int UPDATE_INTERVAL = 10; 

	// How many download jobs we can have simultaneously
	public static const int MAX_JOBS = 5;

	private Database database;
	private Soup.SessionAsync session;

	private Gee.Queue<Fido.Feed> jobs_to_run;
	private Gee.Map<string, Fido.Feed> running_jobs;

	public Updater (Database database) {
		this.database = database;
		this.jobs_to_run = new Gee.LinkedList<Fido.Feed> ();
		this.running_jobs = new Gee.HashMap<string, Fido.Feed> ();
		this.session = new Soup.SessionAsync ();
		session.set_data<Updater> ("fido-updater", this);
	}

	// We have to do this instead of passing the feed in a closure because of
	// a bug: https://bugzilla.gnome.org/show_bug.cgi?id=704176
	// Since passing things in closure doesn't work, I prefer to not use 
	// anonymous delegate function to make clear what the scope is.

	public static void handle_update (Soup.SessionAsync session,
					  Soup.Message m) {
		Updater updater = session.get_data<Updater> ("fido-updater");
        string uri = m.uri.to_string (false);
		Logging.message (Flag.UPDATER, 
		                 @"GET $(uri): $(m.status_code) $(m.reason_phrase)");
        if (m.status_code == 200) {
            // FIXME: Not safe, we need to check content-type and encoding
            string body = (string) m.response_body.data;
    		Logging.message (Flag.UPDATER, "Parsing string beginning with %s", body[0:20]);
            Logging.message (Flag.UPDATER, @"($(m.response_body.length) bytes)");
            if (updater.running_jobs.has_key (uri)) {
                stdout.printf ("it's there\n");
                var feed = updater.running_jobs[uri];
                stdout.printf ("Feed source: %s\n", feed.source);
                updater.update_feed (feed, body);
            } else {
                Logging.warning (Flag.UPDATER, "Got response on an URL not in running jobs");
            }
        } else {
            Logging.warning (Flag.UPDATER, "Got response $(m.status_code) $(m.reason_phrase) on $(uri)");
        }

	}

    public void update_feed (Feed feed, string body) {
        feed.parse (body);
    }

	public void work_on_queue () {
		while (jobs_to_run.size > 0 && running_jobs.size < MAX_JOBS) {
			var feed = jobs_to_run.poll ();
			stdout.printf ("Starting download of %s\n", feed.source);
			var msg = new Soup.Message ("GET", feed.source);
			session.queue_message (msg, (Soup.SessionCallback) handle_update);
			running_jobs[feed.source] = feed;
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
