# all list-related commands

our sub lappend(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "lappend varName ?value value ...?"');
    }
    my $var := @args.shift();
    my @list;
    # lappend auto-vivifies
    try {
        @list := set($var);
        CATCH {
            @list := set($var, pir::new__ps('TclList'));
        }
    }
    @list := @list.getList();

    for @args -> $elem {
        @list.push($elem);
    }
    return set($var,@list);
}

our sub lassign(*@args) {
    if +@args < 2 {
        error('wrong # args: should be "lassign list varName ?varName ...?"');
    }
    my @list := @args.shift().getList();
    my $listLen := +@list;
    my $pos := 0;
    for @args -> $var {
        if $pos < $listLen {
            set($var, @list.shift());
        } else {
            set($var,'');
        }
        $pos++;
    }
    return @list;
}

our sub linsert(*@args) {
    if +@args < 2 {
        error('wrong # args: should be "linsert list index element ?element ...?"')
    }
    my @list := @args.shift().getList();

    #if user says 'end', make sure we use the end (imagine one element list)
    my $oIndex := @args.shift();
    my $index := @list.getIndex($oIndex);
    if pir::substr__ssii($oIndex,0,3) eq 'end' {
        $index++;
    } else {
        if $index > +@list { $index := +@list; }
        if $index < 0      { $index := 0;}
    }

    pir::splice__vppii(@list, @args, $index, 0);
    return @list;
}

our sub list(*@args) {
    return @args;
}

our sub lindex(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "lindex list ?index...?"');
    }
    my $list := @args.shift();

    my @indices;
    if +@args == 0 {
        return $list;
    } elsif +@args == 1 {
        @indices := @args[0].getList();
    } else {
        @indices := @args;
    }

    my $result := $list;
    while (@indices) {
        $result := $result.getList();
        my $index := $result.getIndex(@indices.shift()); # not a TclList?
        my $size := +$result;
        if $index < 0 || $index >= $size {
            $result := '';
        } else {
            $result := $result[$index];
        }
    }
    return $result;
}

our sub llength(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "llength list"')
    }

    +@args[0].getList();
}

our sub lrange(*@args) {
    if +@args != 3 {
        error('wrong # args: should be "lrange list first last"')
    }
    my @list := @args[0].getList();
    my $from := @list.getIndex(@args[1]);
    my $to   := @list.getIndex(@args[2]);

    if $from < 0 { $from := 0}
    my $listLen := +@list;
    if $to > $listLen { $to := $listLen - 1 }

    my @retval := pir::new__ps('TclList');
    while $from <= $to  {
        @retval.push(@list[$from]);
        $from++;
    }
    return @retval;
}


our sub lrepeat(*@args) {
    if +@args < 2  {
        error('wrong # args: should be "lrepeat positiveCount value ?value ...?"');
    }
    my $count := @args.shift.getInteger();
    if $count < 1 {
        error('must have a count of at least 1');
    }
    my @result := pir::new__ps('TclList');
    while $count {
        for @args -> $elem {
            @result.push($elem);
        }
        $count--;
    }
    return @result;
}

our sub lreplace(*@args) {
    if +@args < 3 {
        error('wrong # args: should be "lreplace list first last ?element element ...?"');
    }

    my @list := pir::clone__pp(@args.shift().getList());

    my $first := @list.getIndex(@args.shift());
    my $last  := @list.getIndex(@args.shift());

    if +@list == 0 {
        pir::splice__vppii(@list, @args, 0, 0);
        return @list;
    }

    $last := +@list -1 if $last >= +@list;
    $first := 0 if $first < 0;

    if $first >= +@list {
        error("list doesn't contain element $first");
    }

    my $count := $last - $first + 1;
    if $count >= 0 {
        pir::splice__vppii(@list, @args, $first, $count);
        return @list;
    }

    pir::splice__vppii(@list, @args, $first, 0);
    return @list;
}

our sub lreverse(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "lreverse list"');
    }
    return @args[0].getList().reverse();
}

our sub lset(*@args) {
    if +@args < 2 {
        error('wrong # args: should be "lset listVar index ?index...? value"');
    }

    my $name  := @args.shift;
    my $value := @args.pop;

    my $original_list := set($name);    # Error if $name not found - don't viv

    if @args == 0
        || (@args == 1 && @args[0].getList == 0) {
        set($name, $value);
    }
    else {
        if pir::isa__ips($original_list, 'String') {
            $original_list := pir::box__ps($original_list);
        }

        my @result := pir::clone__pp($original_list).getList;
        my @sublist := @result;
        my @previous;
        my $index;

        for @args -> $arg {
            @previous := @sublist;

            $index := @previous.getIndex: $arg;

            if $index < 0 || $index >= @previous {
                error('list index out of range');
            }

            if pir::typeof__sp(@previous[$index]) eq 'String' {
                @previous[$index] := pir::box__ps(@previous[$index]);
            }

            @previous[$index] := @sublist := @previous[$index].getList;
        }

        @previous[$index] := $value;
        set($name, @result);
    }
}

our sub lsort(*@args) {

    error('wrong # args: should be "lsort ?options? list"')
        unless +@args;

    # Set defaults
    my $compare := sort_ascii;
    my $decr    := 0;  
    my $unique  := 0;

    my @list := @args.pop().getList();

    for @args -> $key {
        if $key eq '-decreasing' {
            $decr := 1;
        } elsif $key eq '-increasing' {
            $decr := 0;
        } elsif $key eq '-unique' {
            $unique := 1;
        } elsif $key eq '-integer' {
            $compare := sort_integer;
        } elsif $key eq '-real' {
            $compare := sort_real;
        } elsif $key eq '-dictionary' {
            $compare := sort_dictionary;
        } elsif $key eq '-command' {
            $compare := error("NYI");
        } else {
            error("bad option \"$key\": must be -ascii, -command, -decreasing, -dictionary, -increasing, -index, -indices, -integer, -nocase, -real, or -unique");
        }
    }

    # XXX need the assigns?
    @list.sort($compare);

    if $unique  {
        my @uniqued := pir::new__ps('TclList');
        my $last;
        for @list -> $element {
            if !+@uniqued || $element ne $last {
                @uniqued.push($element);
            }
            $last := $element;
        }
        @list := @uniqued;
    }

    @list.'reverse'() if $decr;

    @list;
}

my sub sort_ascii($a, $b) {
    pir::cmp__iss($a, $b);
}

my sub sort_integer($a, $b) {
    # XXX defensively avoid changing the string value of these pmcs.
    pir::cmp__iii(pir::clone($a), pir::clone($b));
}

my sub sort_real($a, $b) {
    error("NYI");
}

=begin fromPartcl

.sub 'dictionary'
    .param string s1
    .param string s2

    .include 'cclass.pasm'

    .local int len1, len2, pos1, pos2
    len1 = length s1
    len2 = length s2
    pos1 = 0
    pos2 = 0
loop:
    if pos1 >= len1 goto end1
    if pos2 >= len2 goto greater

    $I0 = is_cclass .CCLASS_NUMERIC, s1, pos1
    if $I0 goto numeric
    $I0 = is_cclass .CCLASS_NUMERIC, s2, pos2
    if $I0 goto numeric

    .local string char1, char2, sortchar1, sortchar2
    char1 = substr s1, pos1, 1
    char2 = substr s2, pos2, 1
    sortchar1 = downcase char1
    sortchar2 = downcase char2
    if sortchar1 != sortchar2 goto got_chars
    sortchar1 = char1
    sortchar2 = char2

got_chars:
    $I1 = ord sortchar1
    $I2 = ord sortchar2

    inc pos1
    inc pos2
    goto compare

numeric:
    $I3 = find_not_cclass .CCLASS_NUMERIC, s1, pos1, len1
    if $I3 == pos1 goto greater

    $I4 = find_not_cclass .CCLASS_NUMERIC, s2, pos2, len2
    if $I4 == pos2 goto less

    $I5 = $I3 - pos1
    $I6 = $I4 - pos2
    $S1 = substr s1, pos1, $I5
    $S2 = substr s2, pos2, $I6
    pos1 = $I3
    pos2 = $I4
    $I1 = $S1
    $I2 = $S2

compare:
    if $I1 < $I2 goto less
    if $I1 > $I2 goto greater
    goto loop

end1:
    if len1 == len2 goto equal

less:
    .return(-1)

equal:
    .return(0)

greater:
    .return(1)
.end

=end fromPartcl

# vim: filetype=perl6:
