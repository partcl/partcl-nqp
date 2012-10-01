method gets(*@args) {
    our %CHANNELS;

    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "gets channelId ?varName?"');
    }

    my $channelId := @args[0];
    my $chanObj := %CHANNELS{$channelId};
    if (! nqp::defined($chanObj) ) {
        error("can not find channel named \"$channelId\"");
    }


    my $result := pir::readline__SP($chanObj);

    if nqp::chars($result) >0 && nqp::substr($result, -1) eq "\n" {
        $result := pir::chopn__SSi($result,1);
    }
    if +@args == 2 {
        set(@args[1], $result);
        return nqp::chars($result);
    } else {
        return $result;
    }

}

# vim: expandtab shiftwidth=4 ft=perl6:
