namespace Fido {

class Item : Object {
	private Grss.FeedItem grss;

    public Item (Feed parent) {
        this._parent = parent;
    }

	public Item.from_grss (Feed parent, Grss.FeedItem item) {
        this._parent = parent;
		this.grss = item;
	}
	
	public Feed parent { get; private set; }

    /**
     * Some feeds do not give guids to items.  In that case we fake it, using 
     * item's publishing time if exists or otherwise, item's title.  
     * (However, publishing time is not exposed by grss...)
     * I'm not sure how well this works for real-world feeds.  There will be
     * testing.
     * 
     * While guids should be globally unique, we don't trust feeds to do this
     * since we don't want to risk feed A overwriting feed B:s items. 
     * Therefore items are identified in the database with feed_id + guid.
     * A problem here is what we want to do with duplicates in planets.
     * But let's wait with that. 
     */
    public string guid {
        get {
            unowned string id = this.grss.get_id ();
            if (id != null && id != "")
                return id;
            // publishing time from feed isn't exposed by libgrss...
            return this.grss.get_title ();
        }
    }
}

}
