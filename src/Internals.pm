use src::Partcl::commands;

class Internals {
    
    ## wrapper method for invoking tcl builtins - deals with unknown
    ## handling and namespace desugaring
    
    method dispatch($command, *@args) {

        ## Call a tcl method just to prove it works here.
        puts("Called our invoke dispatcher");

        ## Get our caller's namespace, do the lookup from there.
        my $ns := Q:PIR {
            $P1 = getinterp
            %r = $P1['sub'; 1]
        }.get_namespace();
    
        my &command := $ns{$command};
    
        ## if that didn't work, check in the root ns.
        if pir::typeof__SP(&command) eq "Undef" {
            $ns := pir::get_hll_namespace__P();
            &command := $ns{$command};
        }
    
        if pir::typeof__SP(&command) eq "Undef" {
            error("invalid command name \"$command\"");
        }
    
        &command(|@args);
    }
} 
# vim: expandtab shiftwidth=4 ft=perl6:
