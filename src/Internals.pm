class Internals {
    
    ## wrapper method for invoking tcl builtins - deals with unknown
    ## handling and namespace desugaring
 
    my $Builtins := Builtins.new();   
     
    method dispatch($command, *@args) {
        # barebones dispatch - doesn't respect unknown.
        $Builtins."$command"(|@args);
    }

    method getList($orig) {
        my $type := pir::typeof__SP($orig); 
        if $type eq "String" {
            if $orig eq "" {
                return TclList.new();
            }
            return Partcl::Grammar.parse(
                $orig,
                :rule<list>,
                :actions(Partcl::Actions)
            ).ast;
        } elsif $type eq "TclList" {
            return $orig;
        } elsif $type eq "QAST::SVal" {
            return Partcl::Grammar.parse(
                $orig.value,
                :rule<list>,
                :actions(Partcl::Actions)
            ).ast;
        } else {
       	    say("UNKNOWN TYPE PASSED TO GETLIST: '" ~ $type ~ "'"); 
        }
    }
} 
# vim: expandtab shiftwidth=4 ft=perl6:
