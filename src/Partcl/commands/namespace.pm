our sub namespace(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "namespace subcommand ?arg ...?"');
    }

    my @opts := <children code current delete ensemble eval exists export forget import inscope origin parent path qualifiers tail unknown upvar which>;
    my $cmd := _tcl::select_option(@opts, @args.shift() );

    if $cmd eq 'children' {
        return '';
    } elsif $cmd eq 'code' {
        return '';
    } elsif $cmd eq 'current' {
        return '';
    } elsif $cmd eq 'delete' {
        return '';
    } elsif $cmd eq 'ensemble' {
        return '';
    } elsif $cmd eq 'eval' {
        return '';
    } elsif $cmd eq 'exists' {
        return '';
    } elsif $cmd eq 'export' {
        return '';
    } elsif $cmd eq 'forget' {
        return '';
    } elsif $cmd eq 'import' {
        return '';
    } elsif $cmd eq 'inscope' {
        return '';
    } elsif $cmd eq 'origin' {
        return '';
    } elsif $cmd eq 'parent' {
        return '';
    } elsif $cmd eq 'path' {
        return '';
    } elsif $cmd eq 'qualifiers' {
        return '';
    } elsif $cmd eq 'tail' {
        return '';
    } elsif $cmd eq 'upvar' {
        return '';
    } elsif $cmd eq 'unknkown' {
        return '';
    } elsif $cmd eq 'which' {
        return '';
    }
}

# vim: filetype=perl6:
