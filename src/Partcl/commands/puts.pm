method puts(*@args) {
    my $nl := 1;
    if @args[0] eq '-nonewline' {
        @args.shift; $nl := 0;
    }
    my $channelId;
    if nqp::elems(@args) == 1 {
        $channelId := 'stdout';
    } else {
        $channelId := @args.shift;
    } 
    my $chanObj := %*CHANNELS{$channelId};
    $chanObj // nqp::die("can not find channel named \"$channelId\"");
    $chanObj := nqp::getstdout;
    nqp::printfh($chanObj, @args[0]);
    if $nl { 
        nqp::printfh($chanObj, "\n");
        1; # the void print causes trouble elsewise.
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
