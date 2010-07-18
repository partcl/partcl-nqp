our sub regexp(*@args) {
    error('wrong # args: should be "regexp ?switches? exp string ?matchVar? ?subMatchVar subMatchVar ...?"')
        if +@args < 2;

    my $exp := @args.shift();
    my $string := @args.shift();

    my $regex := ARE::Compiler.compile($exp);
    my $match := Regex::Cursor.parse($string, :rule($regex), :c(0));

    # XXX Set ALL the sub match strings to the main string 
    for @args -> $varname {
        set($varname, $match.Str());
    }
 
    ## my &dumper := Q:PIR { %r = get_root_global ['parrot'], '_dumper' };
    ## &dumper(ARE::Compiler.compile($exp, :target<parse>));

    ?$match;
}
