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


.sub 'mapping' :anon :init
  .local pmc tcl
  tcl  = get_class 'TclString'
  .local pmc interp
  interp = getinterp

  .local pmc core
  core = get_class 'String'
  interp.'hll_map'(core,tcl)
.end

.namespace [ 'TclString' ]
.sub get_bool :vtable
    .tailcall self.'getBoolean'()
.end

.sub get_integer :vtable
    .tailcall self.'getInteger'()
.end
