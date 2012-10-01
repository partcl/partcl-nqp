method set(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "set varName ?newValue?"');
    }
    my $varname := @args[0];
    my $value   := @args[1];

    # Does it look like foo(bar) ?
    # XXX Can we use the variable term in the grammar for this?
    my $result;
    if pir::ord__ISI($varname, -1) == 41 && pir::index__ISS($varname, '(' ) != -1 {
        # find the variable name and key name
        my $left_paren  := pir::index__ISS($varname, '(');
        my $right_paren := pir::index__ISS($varname, ')');
        my $keyname   := nqp::substr($varname, $left_paren+1, $right_paren-$left_paren-1);
        my $arrayname := nqp::substr($varname, 0, $left_paren);
        
        if +@args == 2 { # set
            my $var := Q:PIR {
                .local pmc varname, lexpad
                varname = find_lex '$arrayname'
                lexpad = find_dynamic_lex '%LEXPAD'
                %r = vivify lexpad, varname, ['TclArray']
            };
            if !pir::isa__IPS($var, 'TclArray') {
                error("can't set \"$varname\": variable isn't array");
            }
            $var{$keyname} := $value;
            $result := $var{$keyname};
        } else { # get
            my $lexpad := pir::find_dynamic_lex__PS('%LEXPAD');
            my $var    := $lexpad{$arrayname};
            if nqp::isnull($var) {
                error("can't read \"$varname\": no such variable");
            } elsif !pir::isa__IPS($var, 'TclArray') {
                error("can't read \"$varname\": variable isn't array");
            } elsif nqp::isnull($var{$keyname}) {
                error("can't read \"$varname($keyname)\": no such element in array");
            } else {
                $result := $var{$keyname};
            }
        }
    } else {
        # scalar
        $result := Q:PIR {
            .local pmc varname, lexpad
            varname = find_lex '$varname'
            lexpad = find_dynamic_lex '%LEXPAD'
            %r = vivify lexpad, varname, ['Undef']
        };
        if pir::isa__IPS($result, 'TclArray') {
            error("can't set \"$varname\": variable is array");
        } elsif nqp::defined($value) {
            pir::copy__vPP($result, $value);
            1; # block can't end in void
        } elsif ! nqp::defined($result) {
            error("can't read \"$varname\": no such variable");
        }
    }
    $result;
}

# vim: expandtab shiftwidth=4 ft=perl6:
