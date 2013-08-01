/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

using Fido;

class TestFeed : Gee.TestCase {
 
    public TestFeed() {
        base("Fido.Feed");
        add_test("test_construction", test_construction);
    }
 
    public override void set_up () {
    }
 
    public override void tear_down () {
    }

    public void test_construction () {
        Feed f = new Feed ();
        assert (f.source == null);
        assert (f.items.is_empty);
        f = new Feed ("http://somesource");
        assert (f.source == "http://somesource");
        assert (f.items.is_empty);
        // FIXME add .with_content
        
    }

}
