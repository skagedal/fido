public class FidoApplication : Gtk.Application {
	public FidoApplication () {
		Object(application_id: "org.gitorious.fido",
			   flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		// Create the window of this application and show it
		var window = new Fido.AppWindow (this);
		window.show_all ();
	}
}
