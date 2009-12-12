# This class is currently created via PIR in src/class/tclstring.pir

module TclString {

    method getInteger () { ## :is vtable

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
} 

# vim: filetype=perl6:
