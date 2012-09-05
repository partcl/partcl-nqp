sub puts(*@args) {
    our %CHANNELS;

    my $nl := 1;
    if @args[0] eq '-nonewline' {
        @args.shift; $nl := 0;
    }
    my $channelId;
    if +@args == 1 {
        $channelId := 'stdout';
    } else {
        $channelId := @args.shift;
    } 
    my $chanObj := %CHANNELS{$channelId};
    if (! nqp::defined($chanObj) ) {
        error("can not find channel named \"$channelId\"");
    }
    pir::print__vPS($chanObj, @args[0]);
    if $nl { 
        pir::print__vPS($chanObj, "\n");
        1; # the void print causes trouble elsewise.
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
