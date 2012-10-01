###  use bare block to avoid catching control exceptions
#
#INIT {
#    GLOBAL::break := -> *@args {
#        if +@args {
#            self.error('wrong # args: should be "break"');
#        }
#        my $exception := pir::new('Exception');
#        $exception<type> := 65; # TCL_BREAK / CONTROL_LOOP_LAST
#        pir::throw($exception);
#    }
#}
#
## vim: expandtab shiftwidth=4 ft=perl6:
