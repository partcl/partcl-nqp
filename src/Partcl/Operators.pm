sub &infix:<==>($a, $b) {
    # Try to do a numeric compare first (XXX this is integer for now)
    try {
        return pir::set__iP($a) == pir::set__iP($b);
        CATCH {
            # Not numeric. Try as string...
            return $a eq $b;
        }
    }

}

# vim: filetype=perl6:
