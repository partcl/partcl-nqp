#placeholder error

method error(*@args) {
    say(nqp::join("\n",@args));
}

###  use bare block to avoid catching control exceptions
#
#INIT {
#    GLOBAL::error := -> *@args {
#        my $message := '';
#        if +@args < 1 || +@args > 3 {
#            $message := 'wrong # args: should be "error message ?errorInfo? ?errorCode?"';
#        } else {
#            $message := @args[0];
#        }
#
#        if +@args >= 2 {
#            our %GLOBALS;
#            %GLOBALS<errorInfo> := @args[1];
#            my $errorCode := @args[2] // 'NONE';
#            %GLOBALS<errorCode> := $errorCode;
#        }
#
#        my $exception := pir::new('Exception');
#        # use EXCEPTION_SYNTAX_ERROR - just a generic type
#        $exception<type> := 55;
#        $exception<message> := $message;
#        pir::throw($exception);
#    }
#}
#
## vim: expandtab shiftwidth=4 ft=perl6:
