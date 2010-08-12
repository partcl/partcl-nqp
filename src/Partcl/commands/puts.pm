our sub puts(*@args) {
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
    if (! pir::defined($chanObj) ) {
        error("can not find channel named \"$channelId\"");
    }
    pir::print__vps($chanObj, @args[0]);
    pir::print__vps($chanObj, "\n") if $nl;
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
