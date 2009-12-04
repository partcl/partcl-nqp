our sub package(*@args) {
    if +@args <1 {
        error('wrong # args: should be "package option ?argument ...?"');
    }
    my $cmd := @args.shift();

    if $cmd eq 'forget' {
        return '';
    } elsif $cmd eq 'ifneeded' {
        return '';
    } elsif $cmd eq 'names' {
        return '';
    } elsif $cmd eq 'prefer' {
        return '';
    } elsif $cmd eq 'present' {
        return '';
    } elsif $cmd eq 'provide' {
        return '';
    } elsif $cmd eq 'require' {
        return '';
    } elsif $cmd eq 'unknown' {
        return '';
    } elsif $cmd eq 'vcompare' {
        return '';
    } elsif $cmd eq 'versions' {
        return '';
    } elsif $cmd eq 'vsatisfies' {
        return '';
    }

    # invalid subcommand.
    error("bad option \"$cmd\": must be forget, ifneeded, names, prefer, present, provide, require, unknown, vcompare, versions, or vsatisfies");
}
