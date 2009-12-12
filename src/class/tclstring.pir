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

=head2 get_bool

Replace default truthiness.

=cut

.sub get_bool :vtable

    .local string check
    check = self
    downcase check, check

    eq check, 'true', yes
    eq check, 'tru', yes
    eq check, 'tr', yes
    eq check, 't', yes
    eq check, 'yes', yes
    eq check, 'ye', yes
    eq check, 'y', yes
    eq check, 'on', yes

    eq check, 'false', no
    eq check, 'fals', no
    eq check, 'fal', no
    eq check, 'fa', no
    eq check, 'f', no
    eq check, 'no', no
    eq check, 'n', no
    eq check, 'off', no
    eq check, 'of', no

    # is this an int? use that value.
    $I1 = check
    $S1 = $I1
    ne check, $S1, mu
    eq $I1, 0, no
    goto yes

mu:
    $S1 = self
    $S1 = 'expected boolean value but got "' . $S1
    $S1 .= '"'
    $P1 = new 'Exception'
    .include 'except_types.pasm'
    $P1['type'] = .CONTROL_ERROR 
    $P1['message'] = $S1
    throw $P1

no:
    .return(0)
yes:
    .return(1) 
.end

.sub get_integer :vtable
    .tailcall self.'getInteger'()
.end
