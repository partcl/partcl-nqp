INIT {
    pir::load_bytecode('P6object.pir');
    P6metaclass().register('ResizablePMCArray', :hll<parrot>);
}

sub P6metaclass() {
    Q:PIR {
        %r = get_root_global ['parrot'], 'P6metaclass'
    };
}

class TclList is ResizablePMCArray {
    
    INIT {
        my $tcl_type := P6metaclass().get_parrotclass('TclList');
        my $core_type := P6metaclass().get_parrotclass('ResizablePMCArray', :hll<parrot>);
    
        my $interp := pir::getinterp__p();
        $interp.hll_map($core_type, $tcl_type);
    
        $core_type := P6metaclass().get_parrotclass('ResizableStringArray', :hll<parrot>);
        $interp.hll_map($core_type, $tcl_type);
    
        $tcl_type.add_vtable_override('get_string', TclList::get_string);
    }
    
    method __dump($dumper, $label) {
        $dumper.genericArray( $label, self );
    }

    method getIndex($index) {
        my $parse := Partcl::Grammar.parse(
            $index, :rule('index'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == pir::length__is($index) { 
            my @pos := $parse.ast(); 
            my $len := +self;
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
        return self;
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

        for self -> $element {
            my $elem_length := pir::length__is($element);
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
                    my $char := pir::ord__isi($element, $pos);
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
                            } elsif pir::ord__isi($element,$elem_length-1) != 0x5c   {
                                # 0x5c == backslash
                                $new_s := '{' ~ $element ~ '}';
                            } else {
                                $new_s := self.'escape_element'($element);
                            }
                        } elsif $elem_length -1 == pir::index__issi($element,"\\", $elem_length-1) {
                            $new_s := self.'escape_element'($element);
                        } elsif pir::index__iss($element, '"') != -1 ||
                                pir::index__iss($element, '[') != -1 ||
                                pir::index__iss($element, '$') != -1 ||
                                pir::index__iss($element, ';') != -1 ||
                    ( $first && pir::index__iss($element, '#') != -1 ) {
                            $new_s := '{' ~ $element ~ '}';
                        } elsif pir::index__iss($element, ']') != -1 {
                            $new_s := self.'escape_element'($element);
                        } elsif pir::find_cclass__iisii(32, $element, 0, $elem_length) != $elem_length {
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

        return pir::join__ssp(' ', @retval);
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
}

# vim: filetype=perl6:
