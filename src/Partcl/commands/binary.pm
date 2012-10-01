method binary(*@args) {
    error('wrong # args: should be "binary option ?arg arg ...?"')
        if !+@args;

    my $subcommand := @args.shift();
    if $subcommand eq 'format' {
        if +@args < 1 {
            error('wrong # args: should be "binary format formatString ?arg arg ...?"');
        }
    } elsif $subcommand eq 'scan' {
        if +@args < 2 {
            error('wrong # args: should be "binary scan value formatString ?varName varName ...?"');
        }
        my $value := @args.shift();
        my $formatString := @args.shift();
        for @args -> $varName {
            set($varName, ''); # XXX placeholder
        }
    } else {
        error("bad option \"$subcommand\": must be format or scan");
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
