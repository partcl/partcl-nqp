method set(*@args) {
    if +@args < 1 || +@args > 2 {
        self.error('wrong # args: should be "set varName ?newValue?"');
    }
    my $varname := @args[0];
    my $value   := @args[1];

    # Does it look like foo(bar) ?
    # XXX Can we use the variable term in the grammar for this?
    my $result;
    say(1);
    if nqp::ord($varname, -1) == 41 && nqp::index($varname, '(' ) != -1 {
    say(2);
        # find the variable name and key name
        my $left_paren  := nqp::index($varname, '(');
        my $right_paren := nqp::index($varname, ')');
        my $keyname   := nqp::substr($varname, $left_paren+1, $right_paren-$left_paren-1);
        my $arrayname := nqp::substr($varname, 0, $left_paren);
       say(3); 
        if +@args == 2 { # set
            my $var := Q:PIR {
                .local pmc varname, lexpad
                varname = find_lex '$arrayname'
                lexpad = find_dynamic_lex '%LEXPAD'
                %r = vivify lexpad, varname, ['TclArray']
            };
            if !nqp::istype($var, 'TclArray') {
                self.error("can't set \"$varname\": variable isn't array");
            }
            $var{$keyname} := $value;
            $result := $var{$keyname};
        } else { # get
            my $lexpad := nqp::getlexdyn('%LEXPAD');
            my $var    := $lexpad{$arrayname};
            if nqp::isnull($var) {
                self.error("can't read \"$varname\": no such variable");
            } elsif !nqp::istype($var, 'TclArray') {
                self.error("can't read \"$varname\": variable isn't array");
            } elsif nqp::isnull($var{$keyname}) {
                self.error("can't read \"$varname($keyname)\": no such element in array");
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
        if nqp::istype($result, 'TclArray') {
            self.error("can't set \"$varname\": variable is array");
        } elsif nqp::defined($value) {
            pir::copy__vPP($result, $value);
            1; # block can't end in void
        } elsif ! nqp::defined($result) {
            self.error("can't read \"$varname\": no such variable");
        }
    }
    $result;
}

# vim: expandtab shiftwidth=4 ft=perl6:
