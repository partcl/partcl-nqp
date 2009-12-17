# This class is currently created via PIR in src/class/tclstring.pir

INIT {
    pir::getinterp__p().hll_map(
        pir::get_class__ps('String'),
        pir::get_class__ps('TclString')
    )
}

module TclString {
    method getInteger() { ## :is vtable
        my $parse := Partcl::Grammar.parse(
            self, :rule('integer'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == pir::length__is(self) {
            return $parse.ast();
        } else {
            error('expected integer but got "' ~ self ~ '"');
        }
    }

    method getBoolean() { ## :is vtable
        my $parse := Partcl::Grammar.parse(
            self, :rule('term:sym<true>')
        );

        if ?$parse && $parse.chars() == pir::length__is(self) {
            return 1;
        }

        $parse := Partcl::Grammar.parse(
            self, :rule('term:sym<false>')
        );

        if ?$parse && $parse.chars() == pir::length__is(self) {
            return 0;
        }

        $parse := Partcl::Grammar.parse(
            self, :rule('integer'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == pir::length__is(self) {
            return ?$parse.ast();
        }

        error('expected boolean value but got "' ~ self ~ '"');
    }

    method getIndex($index) {
        my $parse := Partcl::Grammar.parse(
            $index, :rule('index'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == pir::length__is($index) { 
            my $pos := $parse.ast(); 
            my $len := pir::length__is(self);
            if $pos < 0 {
                $pos := $pos + $len;
            }
            if $pos < 0 {
                return 0;
            } else { 
                return $pos;
            }
        } else {
            error("bad index \"$index\": must be integer?[+-]integer? or end?[+-]integer?");
        }
    }

} 

# vim: filetype=perl6:
