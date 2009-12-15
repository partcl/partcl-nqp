our sub file(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "file option ?arg ...?"');
    }

    my @opts := <atime attributes channels copy delete dirname executable exists extension isdirectory isfile join link lstat mkdir mtime nativename normalize owned pathtype readable readlink rename rootname separator size split stat system tail type volumes writable>;
    my $cmd := _tcl::select_option(@opts, @args.shift());

    if $cmd eq 'atime' {
        return '';
    } elsif $cmd eq 'attributes' {
        return '';
    } elsif $cmd eq 'channels' {
        return '';
    } elsif $cmd eq 'copy' {
        return '';
    } elsif $cmd eq 'delete' {
        return '';
    } elsif $cmd eq 'dirname' {
        return '';
    } elsif $cmd eq 'executable' {
        return '';
    } elsif $cmd eq 'exists' {
        return '';
    } elsif $cmd eq 'extension' {
        return '';
    } elsif $cmd eq 'isdirectory' {
        return '';
    } elsif $cmd eq 'isfile' {
        return '';
    } elsif $cmd eq 'join' {
        return '';
    } elsif $cmd eq 'link' {
        return '';
    } elsif $cmd eq 'lstat' {
        return '';
    } elsif $cmd eq 'mkdir' {
        return '';
    } elsif $cmd eq 'mtime' {
        return '';
    } elsif $cmd eq 'nativename' {
        return '';
    } elsif $cmd eq 'normalize' {
        return '';
    } elsif $cmd eq 'owned' {
        return '';
    } elsif $cmd eq 'pathtype' {
        return '';
    } elsif $cmd eq 'readable' {
        return '';
    } elsif $cmd eq 'readlink' {
        return '';
    } elsif $cmd eq 'rename' {
        return '';
    } elsif $cmd eq 'rootname' {
        return '';
    } elsif $cmd eq 'separator' {
        return '';
    } elsif $cmd eq 'size' {
        return '';
    } elsif $cmd eq 'split' {
        return '';
    } elsif $cmd eq 'stat' {
        return '';
    } elsif $cmd eq 'system' {
        return '';
    } elsif $cmd eq 'tail' {
        return '';
    } elsif $cmd eq 'type' {
        return '';
    } elsif $cmd eq 'volumes' {
        return '';
    } elsif $cmd eq 'writable' {
        return '';
    }
}

# vim: filetype=perl6:
