our sub array(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "array subcommand ?argument ...?"');
    }

    my @opts := <anymore donesearch exists get names nextelement set size startsearch statistics unset>;
    my $cmd := _tcl::select_option(@opts, @args.shift(), 'subcommand');

    if $cmd eq 'anymore' {
        return '';
    } elsif $cmd eq 'donesearch' {
        return '';
    } elsif $cmd eq 'exists' {
        return '';
    } elsif $cmd eq 'get' {
        return '';
    } elsif $cmd eq 'names' {
        return '';
    } elsif $cmd eq 'nextelement' {
        return '';
    } elsif $cmd eq 'set' {
        return '';
    } elsif $cmd eq 'size' {
        return '';
    } elsif $cmd eq 'startsearch' {
        return '';
    } elsif $cmd eq 'statistics' {
        return '';
    } elsif $cmd eq 'unset' {
        return '';
    }
}

# vim: filetype=perl6:
