sub upvar(*@args) {
    my $usage := 'wrong # args: should be "upvar ?level? otherVar localVar ?otherVar localVar ...?"';
    error($usage) unless +@args > 1;

    my %LEXPAD := pir::find_dynamic_lex__PS('%LEXPAD');

    my $peekLevel := @args[0];
    my $level := 1;

    ##  0x23 == '#'
    if nqp::ord($peekLevel) == 0x23 {
        $level := %LEXPAD.depth - nqp::substr($level, 1);
        @args.shift();
    } elsif ~+$peekLevel eq $peekLevel {
        # XXX need real isInt check..
        $level := $peekLevel;
        @args.shift();
    }

    # Rest of the arguments must be paired up.
    error($usage) if +@args % 2;

    my %curLEXPAD := %LEXPAD;

    # Walk up chain.
    while $level > 0 {
        %LEXPAD := %LEXPAD.outer;
        $level := $level - 1;
    }

    for @args -> $old_var, $new_var {
        if pir::exists__IQs(%curLEXPAD, $new_var) {
            error("variable \"$new_var\" already exists");
        }
        %curLEXPAD{$new_var} := %LEXPAD{$old_var};
    }
    
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
