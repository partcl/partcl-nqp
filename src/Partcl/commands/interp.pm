sub interp(*@args) is export {
    if +@args < 1 {
        error('wrong # args: should be "interp subcommand ?argument ...?"');
    }

    my @opts := <alias aliases bgerror create delete eval exists expose hide hidden invokehidden limit issafe marktrusted recursionlimit share slaves target transfer>;
    my $cmd := _tcl::select_option(@opts, @args.shift(), 'subcommand');

    if $cmd eq 'alias' {
        return '';
    } elsif $cmd eq 'aliases' {
        return '';
    } elsif $cmd eq 'bgerror' {
        return '';
    } elsif $cmd eq 'create' {
        return '';
    } elsif $cmd eq 'delete' {
        return '';
    } elsif $cmd eq 'eval' {
        return '';
    } elsif $cmd eq 'exists' {
        return '';
    } elsif $cmd eq 'expose' {
        return '';
    } elsif $cmd eq 'hide' {
        return '';
    } elsif $cmd eq 'hidden' {
        return '';
    } elsif $cmd eq 'invokehidden' {
        return '';
    } elsif $cmd eq 'limit' {
        return '';
    } elsif $cmd eq 'issafe' {
        return 0;
    } elsif $cmd eq 'marktrusted' {
        return '';
    } elsif $cmd eq 'recursionlimit' {
        return '';
    } elsif $cmd eq 'share' {
        return '';
    } elsif $cmd eq 'slaves' {
        return '';
    } elsif $cmd eq 'target' {
        return '';
    } elsif $cmd eq 'target' {
        return '';
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
