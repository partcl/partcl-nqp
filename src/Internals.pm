use src::Partcl::commands;
use src::init;

class Internals {
    
    ## wrapper method for invoking tcl builtins - deals with unknown
    ## handling and namespace desugaring
 
    my $Builtins := Builtins.new();   
     
    method dispatch($command, *@args) {
        # barebones dispatch - doesn't respect unknown.
        $Builtins."$command"(|@args);
    }
} 
# vim: expandtab shiftwidth=4 ft=perl6:
