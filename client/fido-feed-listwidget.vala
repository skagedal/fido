/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

namespace Fido {
    public class FeedListWidget : Gtk.Grid {
        public Feed? feed { get; private set; }
        
        public FeedListWidget (Feed feed_) {
            feed = feed_;
            
            orientation = Gtk.Orientation.HORIZONTAL;
            column_spacing = 12;
            margin = 6;

            var escaped = GLib.Markup.escape_text (feed.title, -1);
            var label = new Gtk.Label ("<b>%s</b>".printf (escaped));
            label.use_markup = true;
            label.hexpand = true;
            label.halign = Gtk.Align.START;
            label.valign = Gtk.Align.END;
            label.xalign = 0;
            attach (label, 0, 0, 1, 1);
            
            escaped = GLib.Markup.escape_text (feed.source, -1);
            label = new Gtk.Label ("<small>%s</small>".printf (escaped));
            label.use_markup = true;
            label.hexpand = true;
            label.halign = Gtk.Align.START;
            label.valign = Gtk.Align.START;
            label.xalign = 0;
            label.get_style_context ().add_class ("dim-label");
            attach (label, 0, 1, 1, 1);
            
            show_all ();
        }
    }
}
