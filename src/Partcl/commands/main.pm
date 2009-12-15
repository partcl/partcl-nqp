our sub after(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "after option ?arg arg ...?"')
    }
    pir::sleep__vN(+@args[0] / 1000);
    '';
}

our sub append(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "append varName ?value value ...?"');
    }

    my $var := @args.shift;

    my $lexpad := pir::find_dynamic_lex__Ps('%LEXPAD');

    my $result := $lexpad{$var};
    while @args {
        $result := ~$result ~ @args.shift;
    }

    set($var, $result);
}

our sub apply(*@apply) {
    return '';
}

##  "break" is special -- see "return"
INIT {
    GLOBAL::break := -> $message = '' {
        my $exception := pir::new__ps('Exception');
        $exception<type> := 66; # TCL_BREAK / CONTROL_LOOP_LAST
        pir::throw($exception);
    }
}


our sub catch(*@args) {
    if +@args <1 || +@args >2 {
        error('wrong # args: should be "catch command ?varName?"');
    }
    my $code := @args[0];

    my $retval := 0; # TCL_OK
    my $result;
    try {
        $result := Partcl::Compiler.eval($code);
        CONTROL {
            my $parrot_type := $!<type>;

            # XXX using numeric type ids is potentially fragile.
            if $parrot_type == 58 {      # CONTROL_RETURN
                $retval := 2;             # TCL_RETURN
            } elsif $parrot_type == 66 { # CONTROL_LOOP_LAST
                $retval := 3;             # TCL_BREAK
            } elsif $parrot_type == 65 { # CONTROL_LOOP_NEXT
                $retval := 4;             # TCL_CONTINUE
            } elsif $parrot_type == 62 { # CONTROL_ERROR
                $retval := 1;             # TCL_ERROR
            } else {
                # This isn't a standard tcl control type. Give up.
                pir::rethrow($!);
            }
            $result := $!<message>;
        }
    };
    if +@args == 2 {
        my $lexpad := pir::find_dynamic_lex__Ps('%LEXPAD');
        $lexpad{@args[1]} := $result;
    }
    return $retval;
}


our sub concat(*@args) {
    my $result := @args ?? _tcl::string_trim(@args.shift) !! '';
    while @args {
        $result := $result ~ ' ' ~ _tcl::string_trim(@args.shift);
    }
    $result;
}

##  "continue" is special -- see "return"
INIT {
    GLOBAL::continue := -> $message = '' {
        my $exception := pir::new__ps('Exception');
        $exception<type> := 65; # TCL_CONTINUE / CONTROL_LOOP_NEXT
        pir::throw($exception);
    }
}


##  "error" is special -- see "return"
INIT {
    GLOBAL::error := -> *@args {
        my $message := '';
        if +@args <1 || +@args > 3 {
            $message := 'wrong # args: should be "error message ?errorInfo? ?errorCode?"';
        } else {
            $message := @args[0];
        }

        if +@args >= 2 {
            our %GLOBALS;
            %GLOBALS{'errorInfo'} := @args[1];
            my $errorCode := @args[2] // 'NONE';
            %GLOBALS{'errorCode'} := $errorCode;
        }

        my $exception := pir::new__ps('Exception');
        $exception<type> := 62; # CONTROL_ERROR
        $exception<message> := $message;
        pir::throw($exception);
    }
}


our sub eval(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "eval arg ?arg ...?"');
    }
    my $code := concat(|@args);
    our %EVALCACHE;
    my &sub := %EVALCACHE{$code};
    unless pir::defined__IP(&sub) {
        &sub := Partcl::Compiler.compile($code);
        %EVALCACHE{$code} := &sub;
    }
    &sub();
}

our sub exit(*@args) {
    if +@args > 1 {
        error('wrong # args: should be "exit ?returnCode?"');
    }
    my $code := @args[0] // 0;
    pir::exit__vi($code);
}

our sub expr(*@args) {
    my $code := pir::join(' ', @args);
    if $code ne '' {
        our %EXPRCACHE;
        my &sub := %EXPRCACHE{$code};
        unless pir::defined__IP(&sub) {
            my $parse :=
                Partcl::Grammar.parse(
                    $code,
                    :rule('TOP_expr'),
                    :actions(Partcl::Actions)
                );
            &sub := PAST::Compiler.compile($parse.ast);
            %EXPRCACHE{$code} := &sub;
        }
        &sub();
    } else {
        error("empty expression\nin expression \"\"");
    }
}

our sub for(*@args) {
    if +@args != 4 {
        error('wrong # args: should be "for start test next command"');
    }
    my $init := @args[0];
    my $cond := @args[1];
    my $incr := @args[2];
    my $body := @args[3];

    eval($init);
    while expr($cond) {
        eval($body);
        eval($incr);
    }
    '';
}

our sub if(*@args) {
    while @args {
        my $expr := @args.shift;
        my $body := @args.shift;
        $body := @args.shift if $body eq 'then';
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

our sub incr (*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "incr varName ?increment?"');
    }

    my $lexpad := pir::find_dynamic_lex__Ps('%LEXPAD');
    my $var := @args[0];
    my $val := @args[1];

    return set($var, pir::add__Iii($lexpad{$var}, $val // 1));
}

our sub join(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "join list ?joinString?"');
    }

    my $list := @args[0];
    my $joinString := @args[1];

    my @list :=
        Partcl::Grammar.parse($list, :rule<list>, :actions(Partcl::Actions) ).ast // pir::new__Ps('TclList');

    $joinString := " " unless pir::defined($joinString);

    pir::join($joinString, @list);
}

our sub flush(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "flush channelId"');
    }
    my $ioObj := _getChannel(@args[0]);
    if pir::can__ips($ioObj, 'flush') {
        $ioObj.flush();
    }
    return '';
}

our sub global (*@args) {
    our %GLOBALS;

    ##  my %CUR_LEXPAD := DYNAMIC::<%LEXPAD>
    my %CUR_LEXPAD := pir::find_dynamic_lex__Ps('%LEXPAD');

    for @args {
        %CUR_LEXPAD{$_} := %GLOBALS{$_};
    }
    '';
}

our sub list(*@args) {
    return @args;
}

our sub lindex($list, $pos) {
    my @list :=
        Partcl::Grammar.parse($list, :rule<list>, :actions(Partcl::Actions) ).ast;

    return @list[$pos];
}

our sub llength(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "llength list"')
    }
    my @list :=
        Partcl::Grammar.parse(@args[0], :rule<list>, :actions(Partcl::Actions) ).ast;

    return +@list;
}

our sub lsort(*@args) {
    return '';
}

our sub proc(*@args) {
    if +@args != 3 {
        error('wrong # args: should be "proc name args body"');
    }

    my $name := @args[0];
    my $args := @args[1];
    my $body := @args[2];

    my $parse :=
        Partcl::Grammar.parse( $body, :rule<TOP_proc>, :actions(Partcl::Actions) );
    my $block := $parse.ast;
    my @params  :=
        Partcl::Grammar.parse($args, :rule<list>, :actions(Partcl::Actions) ).ast;

    for @params {
        my @argument :=
            Partcl::Grammar.parse($_, :rule<list>, :actions(Partcl::Actions) ).ast;

        if +@argument == 1 {
            $block[0].push(
                PAST::Op.new( :pasttype<bind>,
                    PAST::Var.new( :scope<keyed>,
                        PAST::Var.new( :name('lexpad'), :scope<register> ),
                        $_
                    ),
                    PAST::Var.new( :scope<parameter> )
                )
            );
        } elsif +@argument == 2 {
            $block[0].push(
                PAST::Op.new( :pasttype<bind>,
                    PAST::Var.new( :scope<keyed>,
                        PAST::Var.new( :name('lexpad'), :scope<register> ),
                        @argument[0]
                    ),
                    PAST::Var.new(
                        :scope<parameter>,
                        :viviself(PAST::Val.new( :value(@argument[1]) ))
                    )
                )
            );
        }
    }
    $block.name($name);
    $block.control('return_pir');
    PAST::Compiler.compile($block);
    '';
}

our sub puts(*@args) {
    my $nl := 1;
    if @args[0] eq '-nonewline' {
        @args.shift; $nl := 0;
    }
    if @args[0] eq 'stdout' { @args.shift }
    if @args[0] eq 'stderr' {
        @args.shift;
        pir::printerr(@args[0]);
        pir::printerr("\n") if $nl;
    } else {
        pir::print(@args[0]);
        pir::print("\n") if $nl;
    }
    '';
}

our sub regexp(*@args) {
    if +@args <2 {
        error('wrong # args: should be "regexp ?switches? exp string ?matchVar? ?subMatchVar subMatchVar ...?"')
    }

    my $exp := @args.shift();
    my $string := @args.shift();

    ## my &dumper := Q:PIR { %r = get_root_global ['parrot'], '_dumper' };
    ## &dumper(ARE::Compiler.compile($exp, :target<parse>));
    my $regex := ARE::Compiler.compile($exp);
    ?Regex::Cursor.parse($string, :rule($regex), :c(0));
}

our sub rename(*@args) {
    if +@args != 2 {
        error('wrong # args: should be "rename oldName newName"');
    }
}

##  "return" is special -- we want to be able to throw a
##  CONTROL_RETURN exception without the sub itself catching
##  it.  So we create a bare block for the return (bare blocks
##  don't catch return exceptions) and bind it manually into
##  the (global) namespace when loaded.
INIT {
    GLOBAL::return := -> $result = '' { return $result; }
}

our sub set($varname, $value?) {
    my $var :=
        Q:PIR {
            .local pmc varname, lexpad
            varname = find_lex '$varname'
            lexpad = find_dynamic_lex '%LEXPAD'
            %r = vivify lexpad, varname, ['Undef']
        };
    pir::copy__0PP($var, $value) if pir::defined($value);
    $var;
}

our sub source($filename) {
    Partcl::Compiler.evalfiles($filename);
}

our sub split(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "split string ?splitChars?"')
    }

    my $string     := ~@args[0];
    my $splitChars := @args[1] // " \r\n\t";

    if $string eq '' {
        return '';
    }

    if $splitChars eq '' {
        return pir::split__Pss('',$string);
    }

    my @result;
    my $element := '';
    for $string -> $char {
        my $active := 1;
        for $splitChars -> $sc {
            if $active {
                if $char eq $sc {
                    @result.push($element);
                    $element := '';
                    $active := 0;
                }
            }
        }
        if $active {
            $element := $element ~ $char;
        }
    };
    @result.push($element);

    @result := list(|@result); # convert to a TclList
    return @result;
}

our sub switch(*@args) {
    if +@args < 3 {
        error('wrong # args: should be "switch ?switches? string pattern body ... ?default body?"');
    }
    my $string := @args.shift();
    if +@args % 2 == 1 {
        error('extra switch pattern with no body');
    }
    while @args {
        my $pat := @args.shift;
        my $body := @args.shift;
        if $string eq $pat || (+@args == 0 && $pat eq 'default') {
            eval($body);
            last;
        }
    }
}

our sub time(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "time command ?count?"');
    }

    my $command := @args[0];
    my $count;
    if +@args == 2 {
        $count := pir::set__iP(@args[1]);
    } else {
        $count := 1;
    }

    if $count == 0 {
        return '0 microseconds per iteration';
    }

    my $start := pir::time__N();

    my $loop := pir::set__IP($count);
    while $loop {
        eval($command);
        $loop--;
    }
    my $end := pir::time__N();

    my $ms_per := pir::set__IP(($end-$start)*1000000 / $count);

    return $ms_per ~ ' microseconds per iteration';
}

our sub unset(*@args) {
    for @args -> $varname {
        Q:PIR {
            $P1 = find_lex '$varname'
            $P2 = find_dynamic_lex '%LEXPAD'
            delete $P2[$P1]
        }
    }
}

our sub uplevel($level, *@args) {
    ##  my %LEXPAD := DYNAMIC::<%LEXPAD>
    my %LEXPAD := pir::find_dynamic_lex__Ps('%LEXPAD');

    ##  0x23 == '#'
    if pir::ord($level) == 0x23 {
        $level := %LEXPAD.depth - pir::substr($level, 1);
    }

    ##  walk up the chain of outer contexts
    while $level > 0 {
        %LEXPAD := %LEXPAD.outer;
        $level := $level - 1;
    }

    ##  now evaluate @args in the current context
    my $code := concat(|@args);
    Partcl::Compiler.eval($code);
}


our sub while (*@args) {
    if +@args != 2 {
        error('wrong # args: should be "while test command"');
    }
    my $cond := @args[0];
    my $body := @args[1];
    while expr($cond) {
        eval($body);
    }
}

##  EXPAND is a helper sub for {*} argument expansion; it probably
##  doesn't belong in the global namespace but this is a convenient
##  place to test it for now.  It takes a string and splits it up
##  into a list of elements, honoring braces and backslash
##  expansion (similar to the Tcl_SplitList function).  The actual
##  parsing and expansion is handled by the <list> token in
##  Partcl::Grammar .
our sub EXPAND($args) {
    Partcl::Grammar.parse($args, :rule<list>, :actions(Partcl::Actions) ).ast;
}

# vim: filetype=perl6:
