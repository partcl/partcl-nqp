method append(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "append varName ?value value ...?"');
    }

    my $varName := @args.shift;
 
    my $var;

    # XXX bug compatibility - tcl errors if the var doesn't exist and there
    # is nothing to append. See test file for ticket #. 

    if !+@args {
        $var := set($varName);
    } else {
        $var := Q:PIR {
            .local pmc varname, lexpad
            varname = find_lex '$varName'
            lexpad = find_dynamic_lex '%LEXPAD'
            %r = vivify lexpad, varname, ['TclString']
        };
    }

    my $result := set($varName);
    while @args {
        $result := ~$result ~ @args.shift;
    }

    set($varName, $result);
}

# vim: expandtab shiftwidth=4 ft=perl6:
