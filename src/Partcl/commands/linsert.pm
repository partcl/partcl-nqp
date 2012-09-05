#sub linsert(*@args) {
#    if +@args < 2 {
#        error('wrong # args: should be "linsert list index element ?element ...?"')
#    }
#    my @list := @args.shift().getList();
#
#    #if user says 'end', make sure we use the end (imagine one element list)
#    my $oIndex := @args.shift();
#    my $index := @list.getIndex($oIndex);
#    if pir::substr($oIndex,0,3) eq 'end' {
#        $index++;
#    } else {
#        if $index > +@list { $index := +@list; }
#        if $index < 0      { $index := 0;}
#    }
#
#    pir::splice(@list, @args, $index, 0);
#    return @list;
#}
#
## vim: expandtab shiftwidth=4 ft=perl6:
