/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */


HashTable<string, string> hash;

void handler (Soup.Server server, Soup.Message msg, string path,
              GLib.HashTable? query, Soup.ClientContext client) 
{
    string response_text = hash.get (path);
    if (response_text == null) {
        critical (@"Unknown path: $path\n");
        msg.set_status (404);
        msg.set_response ("text/html", Soup.MemoryUse.COPY, @"<html><h1>404: $path</h1></html>".data);
        return;
    }
    msg.set_status (200);
    msg.set_response ("text/xml", Soup.MemoryUse.COPY, response_text.data);    
}

[DBus (name = "org.gitorious.fido.TestWebserver")]
public class WebServer : Object {
    public void add_path (string path, string xml) {
        hash.insert (path, xml);
    }
}

void on_bus_aquired (DBusConnection conn) {
    try {
        conn.register_object ("/org/gitorious/fido/TestWebserver", new WebServer ());
    } catch (IOError e) {
        error ("Could not register service\n");
    }
}

void main () {
    hash = new HashTable<string, string> (str_hash, str_equal);
    hash.insert ("/foo", "<foo>foo</foo>");

    var loop = new MainLoop ();
    
    Bus.own_name (BusType.SESSION, "org.gitorious.fido.TestWebserver", BusNameOwnerFlags.NONE,
                  on_bus_aquired,
                  () => {},
                  () => error ("Could not aquire name\n"));    
                  
    var server = new Soup.Server (Soup.SERVER_PORT, 8088, 
		                  Soup.SERVER_ASYNC_CONTEXT, loop.get_context ());
		                  
    server.add_handler ("/", handler);
    server.run_async ();
    loop.run ();
}
