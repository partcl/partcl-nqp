class TclList {

    has @!array
        is parrot_vtable_handler('get_pmc_keyed_int')
        is parrot_vtable_handler('set_pmc_keyed_int')
        is parrot_vtable_handler('exists_keyed_int')
        is parrot_vtable_handler('delete_keyed_int')
        is parrot_vtable_handler('unshift_pmc')
        is parrot_vtable_handler('push_pmc')
        is parrot_vtable_handler('elements')
        is parrot_vtable_handler('get_iter')
        ;

    method new() {
        my $n := self.CREATE;
        $n.BUILD;
        $n
    }

    method push($item) {
        @!array.push($item);
    }

    method BUILD() {
        @!array := pir::new__PS('ResizablePMCArray');
    }

    method getIndex($index) {
        my $parse := Partcl::Grammar.parse(
            $index, :rule('index'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == nqp::chars($index) {
            my @pos := $parse.ast();
            my $len := +self;
            my $loc := @pos[1];
            if @pos[0] == 2 { # position relative from end.
                $loc := $len - 1 + $loc;
            }
            return $loc;
        } else {
            Builtins.new.error("bad index \"$index\": must be integer?[+-]integer? or end?[+-]integer?");
        }
    }

    method reverse() {
        my $low  := 0;
        my $high := +self -1;

        while $low < $high {
            my $lowVal  := self[$low];
            my $highVal := self[$high];
            self[$high] := $lowVal;
            self[$low]  := $highVal;
            $low++; $high--;
        }
        return self;
    }

    method get_string() {
        my @retval := ();

        my $first := 1;

        for @!array -> $element {
            my $elem_length := nqp::chars($element);
            my $new_s := '';

            if $elem_length == 0 {
                $new_s := '{}';
            } else {
                my $count := 0;
                my $pos := 0;
                my $brace_check_pos := 0;
                my $has_braces := 0;

                my $escaped := 0;

                while $pos < $elem_length && !$escaped {
                    my $char := nqp::ord($element, $pos);
                    if $char == 0x7b {      # open brace
                        $count++;
                        $has_braces := 1;
                    } elsif $char == 0x7d { # close brace
                        $count--;
                        if $count < 0 {
                            $new_s := self.'escape_element'($element);
                            $escaped := 1;
                        } else {
                            $brace_check_pos := +$pos;
                        }
                    }
                    $pos++;
                }

                unless $escaped {
                    if $count {
                        $new_s := self.'escape_element'($element);
                    } else {

                        if $has_braces && $brace_check_pos != $elem_length -1 {
                            if $brace_check_pos != $elem_length -2 {
                                $new_s := '{' ~ $element ~ '}';
                            } elsif nqp::ord($element,$elem_length-1) != 0x5c   {
                                # 0x5c == backslash
                                $new_s := '{' ~ $element ~ '}';
                            } else {
                                $new_s := self.'escape_element'($element);
                            }
                        } elsif $elem_length -1 == pir::index__ISSI($element,"\\", $elem_length-1) {
                            $new_s := self.'escape_element'($element);
                        } elsif pir::index__ISS($element, '"') != -1 ||
                                pir::index__ISS($element, '[') != -1 ||
                                pir::index__ISS($element, '$') != -1 ||
                                pir::index__ISS($element, ';') != -1 ||
                    ( $first && pir::index__ISS($element, '#') != -1 ) {
                            $new_s := '{' ~ $element ~ '}';
                        } elsif pir::index__ISS($element, ']') != -1 {
                            $new_s := self.'escape_element'($element);
                        } elsif pir::find_cclass__IISII(32, $element, 0, $elem_length) != $elem_length {
                            # .macro_const CCLASS_WHITESPACE      32
                            $new_s := '{' ~ $element ~ '}';
                        } else {
                            $new_s := $element
                        }
                    }
                }
            }

            @retval.push($new_s);
            $first := 0;
        }

        nqp::join(' ', @retval);
    }

    method escape_element($string) {
        my $repl := ~$string;
        $repl.replace("\\", "\\\\");
        $repl.replace("\t", "\\t");
        $repl.replace("\f", "\\f");
        $repl.replace("\n", "\\n");
        $repl.replace("\r", "\\r");
        $repl.replace("\x0b", "\\v");
        $repl.replace("\;", "\\;" );
        $repl.replace('$',  "\\\$" );
        $repl.replace('{',  "\\\x7b" );
        $repl.replace('}',  "\\\x7d" );
        $repl.replace(' ',  "\\ " );
        $repl.replace('[',  "\\[" );
        $repl.replace(']',  "\\]" );
        $repl.replace('"', "\\\"");
        return $repl;
    }

    method join($string) {
        return nqp::join($string, self);
    }

    method Numeric() is parrot_vtable('get_number') {
        return +@!array;
    }
}

#
# Add a vtable override for get_string
#
BEGIN {
    sub static($code) {
        $code.get_lexinfo().get_static_code() 
    };

    TclList.HOW.add_parrot_vtable_mapping(
        TclList, 'get_string', static(sub ($self) {
            $self.get_string
        })
    );
    TclList.HOW.compose(TclList);
}
# vim: expandtab shiftwidth=4 ft=perl6:
