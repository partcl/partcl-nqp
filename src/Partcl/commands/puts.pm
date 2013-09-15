method puts(*@args) {
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
    my $chanObj := _getChannel($channelId);
    $chanObj.print(@args[0]);
    if $nl { 
        $chanObj.print("\n");
        1; # the void print causes trouble elsewise.
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
