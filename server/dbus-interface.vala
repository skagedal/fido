namespace Fido.DBus {
	public struct Item {
		public string title;
	}

	public struct Feed {
		public string title;
		public string url;
	}

	[DBus (name = "org.gitorious.Fido.FeedStore")]
	public interface FeedStore : Object {
		public abstract void subscribe (string url) throws IOError;
		public abstract Item get_current_item () throws IOError;
		public abstract Feed[] get_feeds () throws IOError;
		public abstract void update_all () throws IOError;
	}
}
