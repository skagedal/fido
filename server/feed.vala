using Fido.Logging;

public class Fido.Feed : Object {
	private int id;
	public Feed.with_id (int id) {
		this.id = id;
	}
	public string description { get; set; }
	public string source { get; set; }
	public string title { get; set; }

    public void parse (string body) {
        try {
            var grss_feed = new Grss.FeedChannel.with_source (this._source);
            var parser = new Grss.FeedParser ();
            var grss_items = parser.parse_from_string (grss_feed, body);
            foreach (var item in grss_items) {
                stdout.printf (" - %s\n", item.get_title ());
            }
        } catch (Error e) {
            Logging.warning (Flag.UPDATER, "Parse error: %s", e.message);
        }        
    }
}
