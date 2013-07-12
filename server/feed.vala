public class Fido.Feed : Object {
	private int id;
	public Feed.with_id (int id) {
		this.id = id;
	}
	public string description { get; set; }
	public string source { get; set; }
	public string title { get; set; }
}