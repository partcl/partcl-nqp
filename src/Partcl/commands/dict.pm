our sub dict(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "array option arrayName ?arg ...?"');
    }

    my @opts := <append create exists filter for get incr info keys lappend merge remove
                 replace set size unset update values with>;
    my $cmd := _tcl::select_option(@opts, @args.shift(), 'subcommand');

    if $cmd eq 'append' {
        return '';
    } elsif $cmd eq 'create' {
        return '';
    } elsif $cmd eq 'filter' {
        return '';
    } elsif $cmd eq 'for' {
        return '';
    } elsif $cmd eq 'get' {
        return '';
    } elsif $cmd eq 'incr' {
        return '';
    } elsif $cmd eq 'info' {
        return '';
    } elsif $cmd eq 'keys' {
        return '';
    } elsif $cmd eq 'lappend' {
        return '';
    } elsif $cmd eq 'merge' {
        return '';
    } elsif $cmd eq 'remove' {
        return '';
    } elsif $cmd eq 'replace' {
        return '';
    } elsif $cmd eq 'set' {
        return '';
    } elsif $cmd eq 'size' {
        return '';
    } elsif $cmd eq 'unset' {
        return '';
    } elsif $cmd eq 'update' {
        return '';
    } elsif $cmd eq 'values' {
        return '';
    } elsif $cmd eq 'with' {
        return '';
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
