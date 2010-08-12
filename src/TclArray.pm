class TclArray is Hash {

    INIT {
        my $tcl_type := P6metaclass().get_parrotclass('TclArray');
        my $core_type := P6metaclass().get_parrotclass('Hash', :hll<parrot>);

        my $interp := pir::getinterp();
        $interp.hll_map($core_type, $tcl_type);
    }

    method __dump($dumper, $label) {
        $dumper.genericHash( $label, self );
    }

}

# vim: expandtab shiftwidth=4 ft=perl6:
