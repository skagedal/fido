/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
int main (string[] args) {
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (Config.GETTEXT_PACKAGE);

    var fido = new Fido.Application ();
    return fido.run (args);
}

