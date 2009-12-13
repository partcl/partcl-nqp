# XXX Once NQP-rx supports vtable overrides, convert to NQP

=head1 TclString

A Tcl-style string

=cut

.HLL 'tcl'
.namespace []

.sub class_init :anon :init
  .local pmc core, tcl
  core = get_class 'String'
  tcl = subclass core, 'TclString'
.end

.namespace [ 'TclString' ]
.sub get_bool :vtable
    .tailcall self.'getBoolean'()
.end

.sub get_integer :vtable
    .tailcall self.'getInteger'()
.end
