class Internals {
    
    ## wrapper method for invoking tcl builtins - deals with unknown
    ## handling and namespace desugaring
 
    my $Builtins := Builtins.new();   
     
    method dispatch($command, *@args) {
        # barebones dispatch - doesn't respect unknown.
        $Builtins."$command"(|@args);
    }

    method getList($orig) {
        if pir::typeof__SP($orig) eq "String" {
            if $orig eq "" {
                return TclList.new();
            }
            return Partcl::Grammar.parse(
                $orig,
                :rule<list>,
                :actions(Partcl::Actions)
            ).ast;
        } elsif pir::typeof__SP($orig) eq "TclList" {
            return $orig;
        } else {
       	    say("UNKNOWN TYPE PASSED TO GETLIST");
        }
    }
} 
# vim: expandtab shiftwidth=4 ft=perl6:
