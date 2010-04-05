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
