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
    pir::cmp__inn(pir::clone($a), pir::clone($b));
}

# vim: filetype=perl6:
