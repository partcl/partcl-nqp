# This class is currently created via PIR in src/class/tcllist.pir

INIT {
    my $interp := pir::getinterp__p();
    my $tcl  := pir::get_class__ps('TclList'),

    my $core := pir::get_class__ps('ResizablePMCArray'),
    $interp.hll_map($core, $tcl);

    $core := pir::get_class__ps('ResizableStringArray'),
    $interp.hll_map($core, $tcl);
}

module TclList {
	method __dump($dumper, $label) {
		$dumper.genericArray( $label, self );
	}

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

    method getList() {
        return self;
    }

    method reverse() {
        my $low  := 0;
        my $high := +self -1;

        while $low < $high {
            my $lowVal  := self[$low];
            my $highVal := self[$high];
            self[$high] := $lowVal;
            self[$low]  := $highVal;
            $low++; $high--;
        }
        return self;
    }
} 

# vim: filetype=perl6:
