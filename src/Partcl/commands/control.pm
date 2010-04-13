##  these commands are special -- we want to be able to throw a
##  CONTROL_<FOO> exception without the NQP sub itself catching
##  it.  So we create a bare block (which doesn't come with any
##  exception handling) and bind it manually into the (global)
##  namespace when loaded.

INIT {
    GLOBAL::break := -> *@args {
        if +@args {
            error('wrong # args: should be "break"');
        }
        my $exception := pir::new__ps('Exception');
        $exception<type> := 66; # TCL_BREAK / CONTROL_LOOP_LAST
        pir::throw($exception);
    }
}

INIT {
    GLOBAL::continue := -> $message = '' {
        my $exception := pir::new__ps('Exception');
        $exception<type> := 65; # TCL_CONTINUE / CONTROL_LOOP_NEXT
        pir::throw($exception);
    }
}

INIT {
    GLOBAL::error := -> *@args {
        my $message := '';
        if +@args < 1 || +@args > 3 {
            $message := 'wrong # args: should be "error message ?errorInfo? ?errorCode?"';
        } else {
            $message := @args[0];
        }

        if +@args >= 2 {
            our %GLOBALS;
            %GLOBALS{'errorInfo'} := @args[1];
            my $errorCode := @args[2] // 'NONE';
            %GLOBALS{'errorCode'} := $errorCode;
        }

        my $exception := pir::new__ps('Exception');
        # use EXCEPTION_SYNTAX_ERROR - just a generic type
        $exception<type> := 56;
        $exception<message> := $message;
        pir::throw($exception);
    }
}

INIT {
    GLOBAL::return := -> $result = '' { return $result; }
}

# vim: filetype=perl6:
