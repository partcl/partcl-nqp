our sub info(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "info subcommand ?argument ...?"');
    }
    my $cmd := @args.shift();

    if $cmd eq 'args' {
        return '';
    } elsif $cmd eq 'body' {
        return '';
    } elsif $cmd eq 'cmdcount' {
        return '';
    } elsif $cmd eq 'commands' {
        # XXX globbing
        # XXX other NS.
        my $pattern := @args[0];
        my $globalNS := pir::get_root_global__PS('tcl');
        try {
            my $result := $globalNS{$pattern};
            return $pattern;
            CATCH {
                return '';
            }
        }
    } elsif $cmd eq 'complete' {
        return '';
    } elsif $cmd eq 'default' {
        return '';
    } elsif $cmd eq 'exists' {
        return 0;
    } elsif $cmd eq 'frame' {
        return '';
    } elsif $cmd eq 'functions' {
        return '';
    } elsif $cmd eq 'globals' {
        return '';
    } elsif $cmd eq 'hostname' {
        return '';
    } elsif $cmd eq 'level' {
        return '';
    } elsif $cmd eq 'library' {
        our %GLOBALS;
        return %GLOBALS<tcl_library>;
    } elsif $cmd eq 'loaded' {
        return '';
    } elsif $cmd eq 'locals' {
        return '';
    } elsif $cmd eq 'nameofexecutable' {
        return '';
    } elsif $cmd eq 'patchlevel' {
        our %GLOBALS;
        return %GLOBALS<tcl_patchLevel>;
    } elsif $cmd eq 'procs' {
        return '';
    } elsif $cmd eq 'script' {
        return '';
    } elsif $cmd eq 'sharedlibextension' {
        return '';
    } elsif $cmd eq 'tclversion' {
        our %GLOBALS;
        return %GLOBALS<tcl_version>;
    } elsif $cmd eq 'vars' {
        return '';
    }

    # invalid subcommand.
    error("unknown or ambiguous subcommand \"$cmd\": must be args, body, cmdcount, commands, complete, default, exists, frame, functions, globals, hostname, level, library, loaded, locals, nameofexecutable, patchlevel, procs, script, sharedlibextension, tclversion, or vars");
}

# vim: filetype=perl6:
