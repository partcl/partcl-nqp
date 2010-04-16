our sub package(*@args) {
    if +@args < 1 {
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
        our %GLOBALS;
        my $library := %GLOBALS{'tcl_library'};
        my $package := @args.shift();
        if $package eq 'tcltest' {
            return Partcl::Compiler.evalfiles("$library/tcltest/tcltest.tcl");
        } elsif $package eq 'opt' {
            return Partcl::Compiler.evalfiles("$library/opt/optparse.tcl");
        }
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

# vim: filetype=perl6:
