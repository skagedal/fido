using Grss;


namespace Fido {
    public class MemoryStore : FeedsStore 
    {
	private List<FeedChannel> channels;

	public MemoryStore () {
	    this.channels = new List<FeedChannel>();
	}

	// GList* (*get_channels) (GrssFeedsStore *store);
	public List<FeedChannel> get_channels () {
	    return this.channels;
	}

	// GList* (*get_items_by_channel) (GrssFeedsStore *store, GrssFeedChannel *channel);
	public List<FeedChannel> get_items_by_channel (FeedChannel channel) {
	    return null;
	}

	// gboolean (*has_item) (GrssFeedsStore *store, GrssFeedChannel *channel, const gchar *id);
	public bool has_item (FeedChannel channel, string id) {
	    return false;
	}

	// void (*add_item_in_channel) (GrssFeedsStore *store, GrssFeedChannel *channel, GrssFeedItem *item);
	public void add_item_in_channel (FeedChannel channel, FeedItem item) {
	    stdout.printf("Adding item\n");
	}
    }
}
