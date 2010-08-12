our sub trace(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "trace subcommand ?argument ...?"');
    }

    my @opts := <add remove info variable vdelete vinfo>;
    my $cmd := _tcl::select_option(@opts, @args.shift(), 'subcommand');

    if $cmd eq 'add' {
        return '';
    } elsif $cmd eq 'remove' {
        return '';
    } elsif $cmd eq 'info' {
        return '';
    } elsif $cmd eq 'variable' {
        return '';
    } elsif $cmd eq 'vdelete' {
        return '';
    } elsif $cmd eq 'vinfo' {
        return '';
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
