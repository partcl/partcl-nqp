our sub rename(*@args) {
    if +@args != 2 {
        error('wrong # args: should be "rename oldName newName"');
    }
    if @args[1] eq "" {
        # delete sub.
        my $ns := pir::get_hll_namespace__P();
        pir::delete($ns, @args[0]);
    } else {
        # XXX actually rename
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
