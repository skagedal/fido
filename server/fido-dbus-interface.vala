/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

namespace Fido {
    public struct FeedSerial {
        int id;
        string source;
        string title;
        int priority;
        int64 publish_time;
        int64 update_time;
        public FeedSerial () {
            id = 0;
            source = "";
            title = "";
            priority = 0;
            publish_time = 0;
            update_time = 0;
        }
    }
    
    public struct ItemSerial {
        int id;
        int feed_id;
        string guid;
        string title;
        string source;
        string author;
        string description;
        int64 publish_time;

        public ItemSerial () {
            id = 0;
            feed_id = 0;
            guid = "";
            title = "";
            source = "";
            author = "";
            description = "";
            publish_time = 0;
        }
    }
}

namespace Fido.DBus {
    [DBus (name = "org.gitorious.Fido.FeedStore")]
    public interface FeedStore : Object {
        public abstract ItemSerial get_current_item () throws IOError;
        public abstract void mark_item_as_read (int id) throws IOError;
        public abstract void set_item_priority_relative (int id, int diff) throws IOError;
        
        public abstract void subscribe (string url) throws IOError;
        public abstract void unsubscribe (int id) throws IOError;
        public abstract FeedSerial[] get_feeds () throws IOError;
        public abstract FeedSerial get_feed (int id) throws IOError;
        public abstract void update_all () throws IOError;
    }
}
