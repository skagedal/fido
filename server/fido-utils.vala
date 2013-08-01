/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

namespace Fido.Utils {

    public string check_uri (string s) {
        if (Regex.match_simple ("^feed://", s))
            return "http://" + s[7:s.length];
        else if (Regex.match_simple ("^feed:", s))
            return s[5:s.length];
        return s;
    }

    class LinkParser : Object {
        private const MarkupParser parser = {
            visit_start, null, null, null, null
        };
    	private MarkupParseContext context;
    	public string rel = null;
    	public string type = null;
    	public string href = null;
    	public string title = null;
        public bool link_found = false;
    	public LinkParser () {
    		context = new MarkupParseContext (parser, 0, this, null);
    	}
    	public bool parse (string s, out string? rel, out string? type, out string? href, out string? title) {
            try {
                if (context.parse (s, -1) && this.link_found) {
                    rel = this.rel;
                    type = this.type;
                    href = this.href;
                    title = this.title;
                    return true;
                }
            } catch (MarkupError e) { }
            rel = type = href = title = null;
            return false;
        }

    	private void visit_start (MarkupParseContext context, string name, string[] attr_names, string[] attr_values) throws MarkupError {
    	    if (name.down() == "link") {
    	        this.link_found = true;
                for (int i = 0; attr_names [i] != null; i++) {
                    switch (attr_names [i].down()) {
                    case "href":
                        this.href = attr_values [i];
                        break;
                        
                    case "rel":
                        this.rel = attr_values [i];
                        break;
                        
                    case "type":
                        this.type = attr_values [i];
                        break;
                        
                    case "title":
                        this.title = attr_values [i];
                        break;
                    }
                }
    	    }
        }
    }

    public class Link : Object {
        public string? rel { get; private set; }
        public string? type_ { get; private set; } // property called "type" is not allowed
        public string? href { get; private set; }
        public string? title { get; private set; }
        public Link (string? rel_, string? type__, string? href_, string? title_) {
            rel = rel_;
            type_ = type__;
            href = href_;
            title = title_;
        }
    }

    /**
     * Get some common attributes from a single link tag 
     * 
     * @markup: String containing a <link> tag.
     * 
     * Return value: A #Link if successful, null otherwise
     */
    public Link? parse_link (string markup) {
        var parser = new LinkParser();
        string rel, type, href, title;
        if (parser.parse (markup, out rel, out type, out href, out title)) 
            return new Link (rel, type, href, title);
        else 
            return null;
    }
    
    /**
     * Find all <link> tags in a string of html and parse some common
     * attributes from them.  This just uses a simple regular expression,
     * which means that there could be false positives.  Using a proper
     * parser might be better.
     * 
     * @markup: String to look for <link> tags in
     *
     * Return value: A list of #Link:s, or null if no links found.
     */
    public List<Link> find_links (string markup) {
        List<Link> links = null;
        Regex regex;
        try {
            regex = new Regex ("<link[^>]*>", RegexCompileFlags.CASELESS);
        } catch (RegexError e) {
            error (e.message);
        }
        MatchInfo match = null;
        regex.match (markup, 0, out match);
        while (match.matches ()) {
            Link link = parse_link (match.fetch (0));
            if (link != null)
                links.append (link);
            try {
                match.next ();
            } catch (RegexError e) {
                error (e.message);
            }
        }
        return links;
    }
    
    /**
     * Find all <link> tags in a string of html that have links to RSS and
     * Atom feeds, and make Feed objects of them.
     *
     * @markup: String to look for <link> tags in
     *
     * Return value: A list of #Feed:s, or null if no links found.
     *
     */
    public Gee.List<Feed> find_feeds (string markup) {
        List<Link> links = find_links (markup);
        Gee.List<Feed> feeds = new Gee.LinkedList<Feed> ();
        
        foreach (var link in links) {
            if (link.rel == "alternate" &&
                (link.type_ == "application/rss+xml" || 
                 link.type_ == "application/atom+xml") &&
                link.href != null) 
            {
                var feed = new Feed (link.href);
                feed.title = link.title;

                feeds.add (feed);
            }
        }
        return feeds;
    }
    
}
