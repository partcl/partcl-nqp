sub foreach(*@args) is export {
    if +@args < 2 || +@args % 2 == 0 {
        error('wrong # args: should be "foreach varList list ?varList list ...? command"');
    }

    my @varlists;
    my @lists;
    my $iterations := 0;

    my $body := @args.pop();
    my @varlist;
    my @list;
    for @args -> @varlist, @list {
        @varlist := @varlist.getList();
        @list    := @list.getList();

        error('foreach varlist is empty') unless +@varlist;

        @varlists.push(@varlist);
        @lists.push(@list);

        # elements in list are spread over varlist. make sure we're
        # going to iterate only enough to cover.
        my $count := pir::ceil__IN(+@list / +@varlist);
        $iterations := $count if $count > $iterations;
    }

    my $iteration := 0;
    while $iteration < $iterations {
        $iteration++;
        my $counter := 0;
        while $counter < +@varlists {
            my @varlist := @varlists[$counter];
            my @list :=    @lists[$counter];
            $counter++;

            my $I0 := 0;
            while $I0 < +@varlist {
                my $varname := @varlist[$I0++];

                if +@list {
                    set($varname,nqp::clone(@list.shift()));
                } else {
                    set($varname,'');
                }
            }
        }

        my $result := 0;

        # let break and continue propagate to our surrounding while.
        eval($body);
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
