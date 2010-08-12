our sub lset(*@args) {
    if +@args < 2 {
        error('wrong # args: should be "lset listVar index ?index...? value"');
    }

    my $name  := @args.shift;
    my $value := @args.pop;

    my $original_list := set($name);    # Error if $name not found - don't viv

    if @args == 0
        || (@args == 1 && @args[0].getList == 0) {
        set($name, $value);
    }
    else {
        if pir::isa($original_list, 'String') {
            $original_list := pir::box__ps($original_list);
        }

        my @result := pir::clone($original_list).getList;
        my @sublist := @result;
        my @previous;
        my $index;

        for @args -> $arg {
            @previous := @sublist;

            $index := @previous.getIndex: $arg;

            if $index < 0 || $index >= @previous {
                error('list index out of range');
            }

            if pir::typeof(@previous[$index]) eq 'String' {
                @previous[$index] := pir::box__ps(@previous[$index]);
            }

            @previous[$index] := @sublist := @previous[$index].getList;
        }

        @previous[$index] := $value;
        set($name, @result);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
