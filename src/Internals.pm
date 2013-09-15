class Internals {
    
    ## wrapper method for invoking tcl builtins - deals with unknown
    ## handling and namespace desugaring
 
    my $Builtins := Builtins.new();   
     
    method dispatch($command, *@args) {
        # barebones dispatch - doesn't respect unknown.
        $Builtins."$command"(|@args);
    }

    method getList($orig) {
        if $orig ~~ String {
            if $orig eq "" {
                return TclList.new();
            }
            return Partcl::Grammar.parse(
                $orig,
                :rule<list>,
                :actions(Partcl::Actions)
            ).ast;
        } elsif $orig ~~ TclList {
            return $orig;
        } elsif $orig ~~ QAST::SVal {
            return Partcl::Grammar.parse(
                $orig.value,
                :rule<list>,
                :actions(Partcl::Actions)
            ).ast;
        } else {
       	    say("UNKNOWN TYPE PASSED TO GETLIST: '" ~ $orig.WHAT ~ "'"); 
        }
    }
} 
# vim: expandtab shiftwidth=4 ft=perl6:
