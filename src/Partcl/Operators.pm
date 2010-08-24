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

sub &infix:<ni>($check, @list) {
   for @list -> $item {
       if $item eq $check {
          return 0;
       }
   }
   return 1;
}

sub &infix:<in>($check, @list) {
   for @list -> $item {
       if $item eq $check {
          return 1;
       }
   }
   return 0;
}

# vim: expandtab shiftwidth=4 ft=perl6:
