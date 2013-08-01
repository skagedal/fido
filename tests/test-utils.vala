/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Fido.Utils;

class TestUtils : Gee.TestCase {
 
    public TestUtils() {
        base("Fido.Utils");
        add_test("test_parse_link", test_parse_link);
        add_test("test_find_links", test_find_links);
    }
 
    public override void set_up () {
    }
 
    public override void tear_down () {
    }

    public void test_parse_link() {
        Fido.Utils.Link? link;

        // Self-closing tag
        link = parse_link ("""<link rel="alternate" type="text/rss" href="http://example.org/foo.xml" />""");
        assert (link != null);
        assert (link.rel == "alternate");
        assert (link.type_ == "text/rss");
        assert (link.href == "http://example.org/foo.xml");

        // Only a start tag
        link = parse_link ("""<link rel="REL" type="TYPE" href="HREF">""");
        assert (link != null);
        assert (link.rel == "REL");
        assert (link.type_ == "TYPE");
        assert (link.href == "HREF");
        
        // Null attributes
        link = parse_link ("""<link href="http://foo" />""");
        assert (link != null);
        assert (link.rel == null);
        assert (link.type_ == null);
        assert (link.href == "http://foo");
        
        // Upper case works
        link = parse_link ("""<LINK HREF="http://upper.case/" TYPE="type" REL="rel">""");
        assert (link != null);
        assert (link.rel == "rel");
        assert (link.type_ == "type");
        assert (link.href == "http://upper.case/");
        
        // Not a link tag
        assert (parse_link ("""<nolink>""") == null);
        
        // Empty string
        assert (parse_link ("") == null);
    }
 
    public void test_find_links () {
        List<Link> links;
        
        links = find_links ("""
<html>
<head>
  <link href="http://example.org/rss.xml" type="application/rss+xml" rel="alternate" title="RSS Feed" />
  <link href="http://example.org/atom.xml" type="application/atom+xml" rel="alternate" title="Atom Feed" />
</head>
<body></body></html>
        """);
        assert (links.length () == 2);
        Link l1 = links.data;
        assert (l1.href == "http://example.org/rss.xml"); 
        assert (l1.rel == "alternate");
        assert (l1.type_ == "application/rss+xml");
        assert (l1.title == "RSS Feed");
        Link l2 = links.next.data;
        assert (l2.href == "http://example.org/atom.xml"); 
        assert (l2.rel == "alternate");
        assert (l2.type_ == "application/atom+xml");
        assert (l2.title == "Atom Feed");
        
        links = find_links ("""<body><foo><bar></bar></foo></body>""");
        assert (links.length () == 0);
        
    }
 
}
