class TclArray {
    has %!array; 

    method new() {
        my $n := self.CREATE;
        $n.BUILD;
        $n
    }

    method BUILD() {
        %!array := nqp::hash();
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
