# This class is currently created via PIR in src/class/tclstring.pir

module TclString {

    method getInteger() { ## :is vtable

        my $parse := Partcl::Grammar.parse(
            self,
            :rule('integer'),
            :actions(Partcl::Actions)
        );

        my $to := $parse.to();
        if $parse.to() == pir::length__is(self) {
            return $parse.ast(); # Will constant fold
        } else {
            error('expected integer but got "' ~ self ~ '"');
        }
    }

    method getBoolean() { ## :is vtable
        my $check := pir::downcase__ss(self);


        if $check eq 'true' || $check eq 'tru' || $check eq 'tr' || $check eq 't' {
                return 1;
        }
        if $check eq 'yes' || $check eq 'ye' || $check eq 'y' {
                return 1;
        }
        if $check eq 'on' {
                return 1;
        }
        if $check eq 'false' || $check eq 'fals' || $check eq 'fal' || $check eq 'fa' || $check eq 'f' {
                return 0;
        }
        if $check eq 'no' || $check eq 'n' {
                return 0;
        }
        if $check eq 'off' || $check eq 'of' {
                return 0;
        }

        my $bool := -1;

        try {
            $bool := ?self.getInteger();
            CONTROL {}
        };


        if $bool != -1 {
            return $bool;
        } else {
            error('expected boolean value but got "' ~ self ~ '"');
        }
    }

} 

# vim: filetype=perl6:
