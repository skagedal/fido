/* libgrss-0.5.vapi generated by vapigen-0.20, do not modify. */

[CCode (cprefix = "Grss", gir_namespace = "Grss", gir_version = "0.5", lower_case_cprefix = "grss_")]
namespace Grss {
	[CCode (cheader_filename = "libgrss.h", type_id = "grss_feed_channel_get_type ()")]
	public class FeedChannel : GLib.Object {
		[CCode (has_construct_function = false)]
		public FeedChannel ();
		public void add_contributor (string contributor);
		public void add_cookie (Soup.Cookie cookie);
		public bool fetch () throws GLib.Error;
		public GLib.List<Grss.FeedItem> fetch_all () throws GLib.Error;
		public async unowned GLib.List<Grss.FeedItem> fetch_all_async () throws GLib.Error;
		public async bool fetch_async () throws GLib.Error;
		[CCode (has_construct_function = false)]
		public FeedChannel.from_file (string path) throws GLib.Error;
		public unowned string get_category ();
		public unowned GLib.List<string> get_contributors ();
		public GLib.SList<Soup.Cookie> get_cookies ();
		public unowned string get_copyright ();
		public unowned string get_description ();
		public unowned string get_editor ();
		public unowned string get_format ();
		public unowned string get_generator ();
		public bool get_gzip_compression ();
		public unowned string get_homepage ();
		public unowned string get_icon ();
		public unowned string get_image ();
		public unowned string get_language ();
		public long get_publish_time ();
		public bool get_pubsubhub (string hub);
		public bool get_rsscloud (string path, string protocol);
		public unowned string get_source ();
		public unowned string get_title ();
		public int get_update_interval ();
		public long get_update_time ();
		public unowned string get_webmaster ();
		public void set_category (string category);
		public void set_copyright (string copyright);
		public void set_description (string description);
		public void set_editor (string editor);
		public void set_format (string format);
		public void set_generator (string generator);
		public void set_gzip_compression (bool value);
		public void set_homepage (string homepage);
		public void set_icon (string icon);
		public void set_image (string image);
		public void set_language (string language);
		public void set_publish_time (long publish);
		public void set_pubsubhub (string hub);
		public void set_rsscloud (string path, string protocol);
		public void set_source (string source);
		public void set_title (string title);
		public void set_update_interval (int minutes);
		public void set_update_time (long update);
		public void set_webmaster (string webmaster);
		[CCode (has_construct_function = false)]
		public FeedChannel.with_source (string source);
	}
	[CCode (cheader_filename = "libgrss.h", type_id = "grss_feed_enclosure_get_type ()")]
	public class FeedEnclosure : GLib.Object {
		[CCode (has_construct_function = false)]
		public FeedEnclosure (string url);
		public unowned string get_format ();
		public size_t get_length ();
		public unowned string get_url ();
		public void set_format (string type);
		public void set_length (size_t length);
	}
	[CCode (cheader_filename = "libgrss.h", type_id = "grss_feed_item_get_type ()")]
	public class FeedItem : GLib.Object {
		[CCode (has_construct_function = false)]
		public FeedItem (Grss.FeedChannel parent);
		public void add_category (string category);
		public void add_contributor (string contributor);
		public void add_enclosure (Grss.FeedEnclosure enclosure);
		public unowned string get_author ();
		public unowned GLib.List<string> get_categories ();
		public unowned string get_comments_url ();
		public unowned GLib.List<string> get_contributors ();
		public unowned string get_copyright ();
		public unowned string get_description ();
		public unowned GLib.List<Grss.FeedEnclosure> get_enclosures ();
		public bool get_geo_point (double latitude, double longitude);
		public unowned string get_id ();
		public unowned Grss.FeedChannel get_parent ();
		public long get_publish_time ();
		public void get_real_source (string realsource, string title);
		public unowned string get_related ();
		public unowned string get_source ();
		public unowned string get_title ();
		public void set_author (string author);
		public void set_comments_url (string url);
		public void set_copyright (string copyright);
		public void set_description (string description);
		public void set_geo_point (double latitude, double longitude);
		public void set_id (string id);
		public void set_publish_time (long publish);
		public void set_real_source (string realsource, string title);
		public void set_related (string related);
		public void set_source (string source);
		public void set_title (string title);
	}
	[CCode (cheader_filename = "libgrss.h", type_id = "grss_feed_parser_get_type ()")]
	public class FeedParser : GLib.Object {
		[CCode (has_construct_function = false)]
		public FeedParser ();
		public GLib.List<Grss.FeedItem> parse (Grss.FeedChannel feed, xml.DocPtr doc) throws GLib.Error;
		public GLib.List<Grss.FeedItem> parse_from_string (Grss.FeedChannel feed, string content) throws GLib.Error;
	}
	[CCode (cheader_filename = "libgrss.h", type_id = "grss_feeds_group_get_type ()")]
	public class FeedsGroup : GLib.Object {
		[CCode (has_construct_function = false)]
		public FeedsGroup ();
		public bool export_file (GLib.List<Grss.FeedChannel> channels, string format, string uri) throws GLib.Error;
		public GLib.List<string> get_formats ();
		public GLib.List<Grss.FeedChannel> parse_file (string path) throws GLib.Error;
	}
	[CCode (cheader_filename = "libgrss.h", type_id = "grss_feeds_pool_get_type ()")]
	public class FeedsPool : GLib.Object {
		[CCode (has_construct_function = false)]
		public FeedsPool ();
		public GLib.List<weak Grss.FeedChannel> get_listened ();
		public int get_listened_num ();
		public unowned Soup.Session get_session ();
		public void listen (GLib.List<Grss.FeedChannel> feeds);
		public void @switch (bool run);
		public virtual signal void feed_fetching (GLib.Object feed);
		public signal void feed_ready (GLib.Object feed, void* items);
	}
	[CCode (cheader_filename = "libgrss.h", type_id = "grss_feeds_publisher_get_type ()")]
	public class FeedsPublisher : GLib.Object {
		[CCode (has_construct_function = false)]
		public FeedsPublisher ();
		public string format_content (Grss.FeedChannel channel, GLib.List<Grss.FeedItem> items) throws GLib.Error;
		public void hub_set_port (int port);
		public void hub_set_topics (GLib.List<Grss.FeedChannel> topics);
		public void hub_switch (bool run);
		public bool publish_file (Grss.FeedChannel channel, GLib.List<Grss.FeedItem> items, string uri) throws GLib.Error;
		public bool publish_web (Grss.FeedChannel channel, GLib.List<Grss.FeedItem> items, string id) throws GLib.Error;
		public virtual signal void delete_subscription (Grss.FeedChannel topic, string callback);
		public virtual signal void new_subscription (Grss.FeedChannel topic, string callback);
	}
	[CCode (cheader_filename = "libgrss.h", type_id = "grss_feeds_store_get_type ()")]
	public abstract class FeedsStore : GLib.Object {
		[CCode (has_construct_function = false)]
		protected FeedsStore ();
		public virtual void add_item_in_channel (Grss.FeedChannel channel, Grss.FeedItem item);
		public virtual unowned GLib.List<Grss.FeedChannel> get_channels ();
		public virtual unowned GLib.List<Grss.FeedItem> get_items_by_channel (Grss.FeedChannel channel);
		public virtual bool has_item (Grss.FeedChannel channel, string id);
		public void @switch (bool run);
	}
	[CCode (cheader_filename = "libgrss.h", type_id = "grss_feeds_subscriber_get_type ()")]
	public class FeedsSubscriber : GLib.Object {
		[CCode (has_construct_function = false)]
		public FeedsSubscriber ();
		public unowned GLib.InetAddress get_address ();
		public GLib.List<weak Grss.FeedChannel> get_listened ();
		public int get_port ();
		public unowned Soup.Session get_session ();
		public bool listen (GLib.List<Grss.FeedChannel> feeds);
		public void set_port (int port);
		public void @switch (bool run);
		public virtual signal void notification_received (GLib.Object feed, GLib.Object item);
	}
}
