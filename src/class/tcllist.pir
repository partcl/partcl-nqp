=head1 TclList

A Tcl-style list

=cut

.include 'cclass.pasm'

.HLL 'tcl'
.namespace [ 'TclList' ]

.sub class_init :anon :init
  .local pmc core, tcl
  core = get_class 'ResizablePMCArray'
  tcl = subclass core, 'TclList'
.end

=head2 get_string

Returns the list as a string

=cut

.sub get_string :vtable
    .local pmc retval
    retval = new 'ResizablePMCArray'

    .local int elems
    elems = self

    .local pmc iterator
    iterator = iter self

    .local string elem_s
    .local int elem_len
    .local string new_s

    .local int first_elem
    first_elem = 1
  loop:
    unless iterator goto done
    elem_s = shift iterator
    elem_len = length elem_s

    if elem_len != 0 goto has_length
    new_s = '{}'
    goto append_elem

  has_length:
    .local int count, pos, brace_check_pos, has_braces
    count = 0
    pos = 0
    brace_check_pos = 0
    has_braces = 0

    .local int char
  elem_loop:
    if pos >= elem_len goto elem_loop_done
    char = ord elem_s, pos
    if char == 0x7b goto open_count
    if char == 0x7d goto close_count
    goto elem_loop_next
  open_count:  
    inc count
    has_braces = 1
    goto elem_loop_next
  close_count:
    dec count
    if count < 0 goto escape
    brace_check_pos = pos
  elem_loop_next:
    inc pos
    goto elem_loop
  elem_loop_done:

    if count goto escape
    unless has_braces goto done_brace_check
    if count goto done_brace_check
    $I0 = elem_len - 1
    if brace_check_pos == $I0 goto done_brace_check

    # escape {ab}\, but brace-wrap anything else. 
    $I0 = elem_len - 2
    if brace_check_pos != $I0 goto quote
    $I0 = elem_len - 1
    char = ord elem_s, $I0
    if char != 0x5c goto quote

    goto escape

  done_brace_check:
    # trailing slash
    $I0 = elem_len - 1
    $I1 = index elem_s, "\\", $I0
    if $I0 == $I1 goto escape

    $I0 = index elem_s, "\""
    if $I0 != -1 goto quote

    $I0 = index elem_s, '['
    if $I0 != -1 goto quote

    # only check hashes on first elem.
    unless first_elem goto done_hash
    $I0 = index elem_s, '#'
    if $I0 != -1 goto quote

  done_hash:
    $I0 = index elem_s, '$'
    if $I0 != -1 goto quote

    $I0 = index elem_s, ';'
    if $I0 != -1 goto quote

    # \'d constructs 
    $I0 = index elem_s, ']'
    if $I0 != -1 goto escape

    $I0 = index elem_s, "\\"
    if $I0 != -1 goto escape

    # {}'d constructs 
    $I0 = find_cclass .CCLASS_WHITESPACE, elem_s, 0, elem_len
    if elem_len != $I0 goto quote

    new_s = elem_s 
  goto append_elem

  escape:
    .local pmc string_t
    string_t = new 'String'
    string_t = elem_s
    string_t.'replace'("\\", "\\\\")
    string_t.'replace'("\t", "\\t")
    string_t.'replace'("\f", "\\f")
    string_t.'replace'("\n", "\\n")
    string_t.'replace'("\r", "\\r")
    string_t.'replace'("\v", "\\v")
    string_t.'replace'("\;", "\\;" )
    string_t.'replace'("$",  "\\$" )
    string_t.'replace'("}",  "\\}" )
    string_t.'replace'("{",  "\\{" )
    string_t.'replace'(" ",  "\\ " )
    string_t.'replace'("[",  "\\[" )
    string_t.'replace'("]",  "\\]" )
    string_t.'replace'("\"", "\\\"")
    new_s = string_t
    goto append_elem

  quote:
    new_s = '{' . elem_s
    new_s = new_s . '}'

  append_elem:
    push retval, new_s
    first_elem = 0
    goto loop

  done:
    .local string retval_s
    retval_s = join " ", retval
    .return(retval_s)
.end
