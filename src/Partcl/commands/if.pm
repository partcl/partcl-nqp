sub if(*@args) {
    while @args {
        my $expr := @args.shift;
        my $body;
        error('wrong # args: no script following "' ~ $expr ~ '" argument')
            if !+@args;
 
        $body := @args.shift;
        if $body eq 'then' {
            error('wrong # args: no script following "then" argument')
                if !+@args;

            $body := @args.shift;
        }
        if expr($expr) { return eval($body); }
        if @args {
            my $else := @args.shift;
            if $else ne 'elseif' {
                $else := @args.shift if $else eq 'else';
                return eval($else);
            }
        }
    }
    '';
}

# vim: expandtab shiftwidth=4 ft=perl6:
