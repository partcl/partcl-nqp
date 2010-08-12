##  use bare block to avoid catching control exceptions

INIT {
    GLOBAL::continue := -> $message = '' {
        my $exception := pir::new('Exception');
        $exception<type> := 64; # TCL_CONTINUE / CONTROL_LOOP_NEXT
        pir::throw($exception);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
