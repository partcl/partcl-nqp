#sub catch(*@args) is export {
#    if +@args < 1 || +@args > 2 {
#        error('wrong # args: should be "catch script ?resultVarName? ?optionVarName?"');
#    }
#    my $code := @args[0];
#
#    my $retval := 0; # TCL_OK
#    my $result;
#    try {
#        $result := Partcl::Compiler.eval($code);
#        CATCH {
#            $retval := 1;             # TCL_ERROR
#            $result := $!<message>;
#        }
#        CONTROL {
#            my $parrot_type := $!<type>;
#
#            # XXX using numeric type ids is fragile.
#            if $parrot_type == 57 {      # CONTROL_RETURN
#                $retval := 2;             # TCL_RETURN
#            } elsif $parrot_type == 65 { # CONTROL_LOOP_LAST
#                $retval := 3;             # TCL_BREAK
#            } elsif $parrot_type == 64 { # CONTROL_LOOP_NEXT
#                $retval := 4;             # TCL_CONTINUE
#            } else {
#                # This isn't a standard tcl control type. Give up.
#                pir::rethrow($!);
#            }
#            $result := $!<message>;
#        }
#    };
#    if +@args == 2 {
#        set(@args[1], $result);
#    }
#    $retval;
#}
#
## vim: expandtab shiftwidth=4 ft=perl6:
