=head1 TclList

A Tcl-style list

=cut

.HLL 'tcl'
.namespace []

.sub class_init :anon :init
  .local pmc core, tcl
  core = get_class 'ResizablePMCArray'
  tcl = subclass core, 'TclList'
.end
