class TclLexPad {

    has %!hash is associative_delegate;

    has $!outer;
    has $!depth;

    method new() {
        my $n := self.CREATE;
        $n.BUILD;
        $n
    }

    method BUILD(*%a) {
        %!hash := nqp::hash();
    }

    method newpad($outer?) {
        my $outerP := $outer // self;
        my $depthP := $outer ?? $outer.depth + 1 !! 0;
        self.bless(:outer($outerP), :depth($depthP));
    }

    method depth() { $!depth }
    method outer() { $!outer }
}

# vim: expandtab shiftwidth=4 ft=perl6:
