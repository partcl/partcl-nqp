class TclString {
    has $!string
        is parrot_vtable_handler('set_string_native')
        is parrot_vtable_handler('get_string')
    ;

    method getInteger() { ## :is vtable
        my $parse := Partcl::Grammar.parse(
            self, :rule('integer'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == nqp::chars(self) {
            return $parse.ast();
        } else {
            error('expected integer but got "' ~ self ~ '"');
        }
    }

    method getBoolean() { ## :is vtable
        my $parse := Partcl::Grammar.parse(
            self, :rule('term:sym<true>')
        );

        if ?$parse && $parse.chars() == nqp::chars(self) {
            return 1;
        }

        $parse := Partcl::Grammar.parse(
            self, :rule('term:sym<false>')
        );

        if ?$parse && $parse.chars() == nqp::chars(self) {
            return 0;
        }

        $parse := Partcl::Grammar.parse(
            self, :rule('integer'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == nqp::chars(self) {
            return ?$parse.ast();
        }

        error('expected boolean value but got "' ~ self ~ '"');
    }

    method getIndex($index) {
        my $parse := Partcl::Grammar.parse(
            $index, :rule('index'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == nqp::chars($index) {
            my @pos := $parse.ast();
            my $len := nqp::chars(self);
            my $loc := @pos[1];
            if @pos[0] == 2 { # position relative from end.
                $loc := $len - 1 + $loc;
            }
            return $loc;
        } else {
            error("bad index \"$index\": must be integer?[+-]integer? or end?[+-]integer?");
        }
    }

    # XXX Simplistic version split to avoid pulling in PGE. 
    # XXX Take from nqp-setting when available.
    method split($regex) {
        my $pos := 0;
        my $result := pir::new__PS('TclList');
        my $looking := 1;
        while $looking {
            my $match := 
                Regex::Cursor.parse(self, :rule($regex), :c($pos)) ;

            if ?$match {
                my $from := $match.from();
                my $to := $match.to();
                my $prefix := nqp::substr(self, $pos, $from-$pos);
                $result.push($prefix);
                $pos := $match.to();
            } else {
                my $len := nqp::chars(self);
                if $pos < $len {
                    $result.push( nqp::substr(self, $pos) );
                }
                $looking := 0;
            }
        }
        return $result;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
