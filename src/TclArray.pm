class TclArray {
    has @!array 
        is parrot_vtable_handler('get_pmc_keyed_int')
        is parrot_vtable_handler('set_pmc_keyed_int')
        is parrot_vtable_handler('exists_keyed_int')
        is parrot_vtable_handler('delete_keyed_int')
        is parrot_vtable_handler('unshift_pmc')
        is parrot_vtable_handler('push_pmc')
        ;

    method new() {
        my $n := self.CREATE;
        $n.BUILD;
        $n
    }

    method BUILD() {
        @!array := pir::new('ResizablePMCArray');
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
