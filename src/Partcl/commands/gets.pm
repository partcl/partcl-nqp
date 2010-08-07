our sub gets(*@args) {
    our %CHANNELS;

    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "gets channelId ?varName?"');
    }

    my $channelId := @args[0];
    my $chanObj := %CHANNELS{$channelId};
    if (! pir::defined($chanObj) ) {
        error("can not find channel named \"$channelId\"");
    }

    my $result := pir::readline__sp($chanObj);
    if pir::length($result) >0 && pir::substr__ssi($result, -1) eq "\n" {
        $result := pir::chopn__ssi($result,1);
    }
    if +@args == 2 {
        set(@args[1], $result);
        return pir::length($result);
    } else {
        return $result;
    }
}
