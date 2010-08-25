our sub rename(*@args) {
    if +@args != 2 {
        error('wrong # args: should be "rename oldName newName"');
    }
    my $hll := pir::get_hll_namespace__P();
    if @args[1] ne "" {
        $hll{~@args[1]} := $hll{~@args[0]};
    }
    pir::delete($hll, @args[0]);
}

# vim: expandtab shiftwidth=4 ft=perl6:
