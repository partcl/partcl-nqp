method lset(*@args) {
    if +@args < 2 {
        self.error('wrong # args: should be "lset listVar index ?index...? value"');
    }

    my $name  := @args.shift;
    my $value := @args.pop;

    my $original_list := set($name);    # Error if $name not found - don't viv

    if @args == 0
        || (@args == 1 && Internals.getList(@args[0]) == 0) {
        set($name, $value);
    }
    else {
        ### XXX is this boxing needed?? 
        ##if pir::isa__IPS($original_list, 'String') {
            ##$original_list := pir::box__PS($original_list);
        ##}

        my @result := Internals.getList(nqp::clone($original_list));
        my @sublist := @result;
        my @previous;
        my $index;

        for @args -> $arg {
            @previous := @sublist;

            $index := @previous.getIndex: $arg;

            if $index < 0 || $index >= @previous {
                self.error('list index out of range');
            }

            if @previous[$index] ~~ String {
                @previous[$index] := TclString.new(@previous[$index]);
            }

            @previous[$index] := @sublist := @previous[$index].getList;
        }

        @previous[$index] := $value;
        set($name, @result);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
