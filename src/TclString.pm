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
} 

# vim: filetype=perl6:
