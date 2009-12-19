# This class is currently created via PIR in src/class/tcllist.pir

INIT {
    my $interp := pir::getinterp__p();
    my $tcl  := pir::get_class__ps('TclList'),

    my $core := pir::get_class__ps('ResizablePMCArray'),
    $interp.hll_map($core, $tcl);

    $core := pir::get_class__ps('Array'),
    $interp.hll_map($core, $tcl);

    $core := pir::get_class__ps('ResizableStringArray'),
    $interp.hll_map($core, $tcl);
}

module TclList {
    method getIndex($index) {
        my $parse := Partcl::Grammar.parse(
            $index, :rule('index'),
            :actions(Partcl::Actions)
        );

        if ?$parse && $parse.chars() == pir::length__is($index) { 
            my @pos := $parse.ast(); 
            my $len := +self;
            my $loc := @pos[1];
            if @pos[0] == 2 { # position relative from end.
                $loc := $len - 1 + $loc;
            }
            return $loc;
        } else {
            error("bad index \"$index\": must be integer?[+-]integer? or end?[+-]integer?");
        }
    }
} 

# vim: filetype=perl6:
