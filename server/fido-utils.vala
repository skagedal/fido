/* -*- tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

namespace Fido.Utils {

    public string check_uri (string s) {
        if (Regex.match_simple ("^feed://", s))
            return "http://" + s[7:s.length];
        else if (Regex.match_simple ("^feed:", s))
            return s[5:s.length];
        return s;
    }

}
