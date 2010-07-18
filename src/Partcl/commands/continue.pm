##  use bare block to avoid catching control exceptions

INIT {
    GLOBAL::continue := -> $message = '' {
        my $exception := pir::new__ps('Exception');
        $exception<type> := 64; # TCL_CONTINUE / CONTROL_LOOP_NEXT
        pir::throw($exception);
    }
}

# vim: filetype=perl6:
