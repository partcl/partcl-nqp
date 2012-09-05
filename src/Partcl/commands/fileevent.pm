sub fileevent(*@args) {
    if +@args < 2 || +@args > 3 {
        error('wrong # args: should be "fileevent channelId event ?script?"');
    }
    my $channelId := @args.shift;
    my $event     := @args.shift;

    if $event ne 'readable' && $event ne 'writable' {
        error("bad event name \"$event\": must be readable or writable");
    }

    our %CHANNELS;
    my $chanObj   := %CHANNELS{$channelId};
    if (! nqp::defined($chanObj) ) {
        error("can not find channel named \"$channelId\"");
    }

    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
