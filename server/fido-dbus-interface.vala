namespace Fido.DBus {
	public struct Item {
		public string title;
	}

	[DBus (name = "org.gitorious.Fido.FeedStore")]
	public interface FeedStore : Object {
		public abstract void subscribe (string url) throws IOError;
		public abstract Item get_current_item () throws IOError;
	}
}
