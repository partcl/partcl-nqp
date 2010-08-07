class TclString is String {

    INIT {
        my $tcl_type := P6metaclass().get_parrotclass('TclString');
        my $core_type := P6metaclass().get_parrotclass('String', :hll<parrot>);

        pir::getinterp.hll_map($core_type, $tcl_type);

        $tcl_type.add_vtable_override('get_bool',
            pir::find_method__pps(TclString, 'getBoolean'));
        $tcl_type.add_vtable_override('get_integer',
            pir::find_method__pps(TclString, 'getInteger'));
    }

    method __dump($dumper, $label) {
        pir::print('"');
        $dumper.dumpStringEscaped( self, '"' );
        pir::print('"');
    }

    method getInteger() { ## :is vtable
        my $parse := Partcl::Grammar.parse(
            self, :rule('integer'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == pir::length(self) {
            return $parse.ast();
        } else {
            error('expected integer but got "' ~ self ~ '"');
        }
    }

    method getBoolean() { ## :is vtable
        my $parse := Partcl::Grammar.parse(
            self, :rule('term:sym<true>')
        );

        if ?$parse && $parse.chars() == pir::length(self) {
            return 1;
        }

        $parse := Partcl::Grammar.parse(
            self, :rule('term:sym<false>')
        );

        if ?$parse && $parse.chars() == pir::length(self) {
            return 0;
        }

        $parse := Partcl::Grammar.parse(
            self, :rule('integer'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == pir::length(self) {
            return ?$parse.ast();
        }

        error('expected boolean value but got "' ~ self ~ '"');
    }

    method getIndex($index) {
        my $parse := Partcl::Grammar.parse(
            $index, :rule('index'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == pir::length($index) {
            my @pos := $parse.ast();
            my $len := pir::length(self);
            my $loc := @pos[1];
            if @pos[0] == 2 { # position relative from end.
                $loc := $len - 1 + $loc;
            }
            return $loc;
        } else {
            error("bad index \"$index\": must be integer?[+-]integer? or end?[+-]integer?");
        }
    }

    method getList() {
        if self eq "" {
            return pir::new('TclList');
        }
        return Partcl::Grammar.parse(self, :rule<list>, :actions(Partcl::Actions) ).ast;
    }
}

# vim: filetype=perl6:
