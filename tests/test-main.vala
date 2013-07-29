/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

public static int main(string[] args) {
    Test.init (ref args);

    var root = TestSuite.get_root ();
    root.add_suite(new TestUtils().get_suite());
    root.add_suite(new TestUpdater().get_suite());
    return Test.run ();
}
