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

# vim: filetype=perl6:
