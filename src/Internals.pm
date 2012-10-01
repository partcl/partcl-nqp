use src::Partcl::commands;
use src::init;

class Internals {
    
    ## wrapper method for invoking tcl builtins - deals with unknown
    ## handling and namespace desugaring
 
    my $Builtins := Builtins.new();   
     
    method dispatch($command, *@args) {

        ## Call a tcl method just to prove it works here.
        $Builtins."$command"(|@args);
    }
} 
# vim: expandtab shiftwidth=4 ft=perl6:
