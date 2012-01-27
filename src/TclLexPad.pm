class TclLexPad {

    has %!hash
        is parrot_vtable_handler('get_pmc_keyed_str')
        is parrot_vtable_handler('get_pmc_keyed')
        is parrot_vtable_handler('set_pmc_keyed_str')
        is parrot_vtable_handler('set_pmc_keyed')
        is parrot_vtable_handler('exists_keyed')
        is parrot_vtable_handler('exists_keyed_str')
        is parrot_vtable_handler('delete_keyed')
        is parrot_vtable_handler('delete_keyed_str')
        ;
    has $!outer;
    has $!depth;

    method new() {
        my $n := self.CREATE;
        $n.BUILD;
        $n
    }

    method BUILD() {
        %!hash := pir::new('Hash');
    }

    method newpad($outer?) {
        self := self.new;
        $!outer := $outer // self;
        $!depth := $outer ?? $outer.depth + 1 !! 0;
        self;
    }

    method depth() { $!depth }
    method outer() { $!outer }
}

# vim: expandtab shiftwidth=4 ft=perl6:
