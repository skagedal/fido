/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Fido.Logging;

namespace Fido {

    public class Updater : Object {

        // How often, in seconds, each feed should be updated.
        public static const int UPDATE_INTERVAL = 60 * 60 * 24; 

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

        public static void handle_update_static (Soup.SessionAsync session,
                          Soup.Message m) {
            Updater updater = session.get_data<Updater> ("fido-updater");
            updater.handle_update (session, m);
        }

        public void handle_update (Soup.SessionAsync session, Soup.Message m) {
            string uri = m.uri.to_string (false);
            Logging.message (Flag.UPDATER, 
                             @"GET $(uri): $(m.status_code) $(m.reason_phrase)");
            if (m.status_code == 200) {
                // FIXME: Not safe, we need to check content-type and encoding
                string body = (string) m.response_body.data;
                Logging.message (Flag.UPDATER, "Parsing string beginning with %s", body[0:20]);
                Logging.message (Flag.UPDATER, @"($(m.response_body.length) bytes)");
                if (running_jobs.has_key (uri)) {
                    var feed = running_jobs[uri];
                    update_feed (feed, body);
                    running_jobs.unset (uri);
                } else {
                    Logging.warning (Flag.UPDATER, "Got response on an URL not in running jobs");
                }
            } else {
                Logging.warning (Flag.UPDATER, @"Got response $(m.status_code) $(m.reason_phrase) on $(uri)");
            }

            work_on_queue ();
            
            if (running_jobs.is_empty && jobs_to_run.is_empty) 
                notify_wait_for_empty ();
        }

        public void update_feed (Feed feed, string body) {
            try {
                feed.parse(body);
                feed.updated_time = new DateTime.now_utc().to_unix();
                database.update_feed(feed);
            } catch (DatabaseError e) {
                Logging.critical (Flag.UPDATER, 
                                  "Database error: %s", e.message);
            } catch (ParseError e) {
                Logging.critical (Flag.UPDATER,
                                  "Parse error: %s", e.message);
            }
        }

        public void work_on_queue () {
            while (jobs_to_run.size > 0 && running_jobs.size < MAX_JOBS) {
                var feed = jobs_to_run.poll ();
                Logging.debug (Flag.UPDATER, "Starting download of %s\n", feed.source);
                var msg = new Soup.Message ("GET", feed.source);
                session.queue_message (msg, (Soup.SessionCallback) handle_update_static);
                running_jobs[feed.source] = feed;
            }
        }
        
        private void queue_feeds (Gee.List<Feed> feeds) {
            foreach (var feed in feeds) {
                if (!(feed in this.jobs_to_run)) {
                    Logging.debug (Flag.UPDATER, "Queueing: %s [%s]", feed.title, feed.source);
                    this.jobs_to_run.offer (feed);
                }
            }
            if (!feeds.is_empty) {
                work_on_queue (); 
            }
        }
        
        public void check_for_updates () {
            Logging.message (Flag.UPDATER, "Checking for feeds to update...");
            var cutoff = new DateTime.now_utc().add_seconds(-UPDATE_INTERVAL);
            queue_feeds(database.get_feeds_not_updated_since(cutoff));
        }
        
        public void force_update_all () {
            try {
                queue_feeds(database.get_all_feeds());
            } catch (DatabaseError e) {
                Logging.critical (Flag.UPDATER, 
                                  "Database error: %s", e.message);
            }
        }
        
        public async Gee.List<Feed> discover_async (string uri) {
            var msg = new Soup.Message ("GET", uri);
            session.queue_message (msg, (s, m) => {
                Idle.add(discover_async.callback);
            });
            yield;
            
            Logging.message (Flag.UPDATER, 
                             @"discover: GET $(uri): $(msg.status_code) $(msg.reason_phrase)");

            if (msg.status_code != 200) {
                Logging.warning (Flag.UPDATER, @"discover: Got response $(msg.status_code) $(msg.reason_phrase) on $(uri)");
                // FIXME: the HTTP status should somehow be forwarded to the client, possibly through exception
                return new Gee.LinkedList<Feed> ();            // empty list
            }

            // FIXME: Not safe, we need to check content-type and encoding
            string body = (string) msg.response_body.data;
            // Logging.message (Flag.UPDATER, "discover: Parsing string beginning with %s", body[0:20]);

            // First, try to parse the content as a feed

            try {
                var feed = new Feed.with_content (uri, body);
                Gee.List<Feed> feeds = new Gee.LinkedList<Feed> ();
                feeds.add (feed);
                return feeds;
            } catch (ParseError e) { }
            
            // Otherwise, try to find <link> tags 
            return Utils.find_feeds (body);
        }
        
        private void notify_wait_for_empty () {
            if (wait_loop != null) {
                wait_loop.quit ();
                wait_loop = null;
            }
        }
        
        private MainLoop wait_loop = null;
        
        /** 
         * Wait for all updates to finish. Intended to be used from unit test.
         */
        public void sync () {
            while (!running_jobs.is_empty || !jobs_to_run.is_empty) {
                if (wait_loop != null) {
                    Logging.critical (Flag.UPDATER, "Can't sync recursively.");
                    return;
                }
                wait_loop = new MainLoop ();
                wait_loop.run ();
            }
        }
    }

}
