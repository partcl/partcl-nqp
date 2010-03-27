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

    my $result := set($var);
    while @args {
        $result := ~$result ~ @args.shift;
    }

    set($var, $result);
}

our sub apply(*@args) {
    return '';
}

our sub binary(*@args) {
}

##  "break" is special -- see "return"
INIT {
    GLOBAL::break := -> *@args {
        if +@args {
            error('wrong # args: should be "break"');
        }
        my $exception := pir::new__ps('Exception');
        $exception<type> := 66; # TCL_BREAK / CONTROL_LOOP_LAST
        pir::throw($exception);
    }
}


our sub catch(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "catch script ?resultVarName? ?optionVarName?"');
    }
    my $code := @args[0];

    my $retval := 0; # TCL_OK
    my $result;
    try {
        $result := Partcl::Compiler.eval($code);
        CATCH {
            $retval := 1;             # TCL_ERROR
            $result := $!<message>;
        }
        CONTROL {
            my $parrot_type := $!<type>;

            # XXX using numeric type ids is potentially fragile.
            if $parrot_type == 58 {      # CONTROL_RETURN
                $retval := 2;             # TCL_RETURN
            } elsif $parrot_type == 66 { # CONTROL_LOOP_LAST
                $retval := 3;             # TCL_BREAK
            } elsif $parrot_type == 65 { # CONTROL_LOOP_NEXT
                $retval := 4;             # TCL_CONTINUE
            } else {
                # This isn't a standard tcl control type. Give up.
                pir::rethrow($!);
            }
            $result := $!<message>;
        }
    };
    if +@args == 2 {
        set(@args[1], $result);
    }
    return $retval;
}

# TODO: implement ~user syntax
our sub cd(*@args) {
    if +@args > 1 {
        error('wrong # args: should be "cd ?dirName?"');
    }
    my $dir;
    if @args == 1 {
        $dir := @args[0];
    } else {
        $dir := pir::new__ps('Env'){'HOME'};
    }
    my $OS := pir::new__ps('OS');
    $OS.chdir($dir);
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

our sub eof(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "eof channelId"')
    }
    my $chan := _getChannel(@args[0]);
    return 0;
}

##  "error" is special -- see "return"
INIT {
    GLOBAL::error := -> *@args {
        my $message := '';
        if +@args < 1 || +@args > 3 {
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
        # use EXCEPTION_SYNTAX_ERROR - just a generic type
        $exception<type> := 56; 
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

our sub fileevent(*@args) {
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

our sub for(*@args) {
    if +@args != 4 {
        error('wrong # args: should be "for start test next command"');
    }
    my $init := @args[0];
    my $cond := @args[1];
    my $incr := @args[2];
    my $body := @args[3];

    eval($init);
    my $loop := 1;
    while $loop && expr($cond) {
        eval($body);
        eval($incr);
        CONTROL {
            if $!<type> == 65 { # CONTROL_LOOP_NEXT
                eval($incr);
            } elsif $!<type> == 66 { # CONTROL_LOOP_LAST
                $loop := 0;
            }
        }
    }
    '';
}

# TODO: do this correctly!  This is a very naive implementation.
our sub foreach(*@args) {
    if +@args == 0 || +@args % 2 == 0 {
        error('wrong # args: should be "foreach varList list ?varList list ...? command"');
    }
    my $var := @args[0];
    my @list := split(@args[1],' ');
    my $body := @args.pop;		# Body is always last
    for @list -> $val {
        set($var,$val);
        eval($body);
    }
}

our sub format(*@args) {
}

our sub gets(*@args) {
}

our sub glob(*@args) {
    my $dir := ".";
    while @args[0] ne '--' && pir::substr(@args[0],0,1) eq '-' {
        my $opt := @args.shift;
        $dir := @args.shift if $opt eq '-directory';
    }
    my @files := Q:PIR {
        $P0 = new ['OS']
        $P1 = find_lex '$dir'
        %r = $P0.'readdir'($P1)
    };
    my @globs;
    for @args -> $pat {
        @globs.push( FileGlob::Compiler.compile($pat) );
    }

    my @retval := pir::new__ps('TclList');
    for @files -> $f {
        my $matched := 0;
        for @globs -> $g {
            $matched := 1 if ?Regex::Cursor.parse($f, :rule($g), :c(0));
            }
        @retval.push($f) if $matched;
    }
    return @retval;
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

our sub if(*@args) {
    # while @args {
    Q:PIR {
      if_loop:
        $P0 = find_lex '@args'
        unless $P0 goto if_done
    };
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
    # }
    Q:PIR {
        goto if_loop
      if_done:
    };
    '';
}

our sub incr (*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "incr varName ?increment?"');
    }

    my $var := @args[0];
    my $val := @args[1];

    # incr auto-vivifies
    try {
        set($var);
        CATCH {
            set($var,0);
        } 
    }
    return set($var, pir::add__Iii(set($var), $val // 1));
}

our sub join(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "join list ?joinString?"');
    }

    pir::join(@args[1] // " ", @args[0].getList());
}
our sub lappend(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "lappend varName ?value value ...?"');
    }
    my $var := @args.shift();
    my @list;
    # lappend auto-vivifies
    try {
        @list := set($var);
        CATCH {
            @list := set($var, pir::new__ps('TclList'));
        } 
    }
    @list := @list.getList();

    for @args -> $elem { 
        @list.push($elem);
    }
    return set($var,@list);
}

our sub lassign(*@args) {
    if +@args < 2 { 
        error('wrong # args: should be "lassign list varName ?varName ...?"');
    }
    my @list := @args.shift().getList();
    my $listLen := +@list;
    my $pos := 0;
    for @args -> $var {
        if $pos < $listLen {
            set($var, @list.shift());
        } else {
            set($var,'');
        }
        $pos++;
    }
    return @list;
}

our sub linsert(*@args) {
    if +@args < 2 {
        error('wrong # args: should be "linsert list index element ?element ...?"')
    }
    my @list := @args.shift().getList();
    
    #if user says 'end', make sure we use the end (imagine one element list)
    my $oIndex := @args.shift();
    my $index := @list.getIndex($oIndex);
    if pir::substr__ssii($oIndex,0,3) eq 'end' {
        $index++;
    } else {
        if $index > +@list { $index := +@list; }
        if $index < 0      { $index := 0;}
    }

    pir::splice__vppii(@list, @args, $index, 0);
    return @list;
}

our sub list(*@args) {
    return @args;
}

our sub lindex(*@args) {
    if +@args < 1 {
        error('wrong # args: should be "lindex list ?index...?"');
    }
    my $list := @args.shift();

    my @indices;
    if +@args == 0 {
        return $list; 
    } elsif +@args == 1 {
        @indices := Partcl::Grammar.parse(
            @args[0], :rule<list>, :actions(Partcl::Actions)
        ).ast;
    } else {
        @indices := @args;
    }

    my $result := $list;
    while (@indices) {
        $result :=
            Partcl::Grammar.parse($result, :rule<list>, :actions(Partcl::Actions) ).ast;
        my $index := $result.getIndex(@indices.shift()); # not a TclList?
        my $size := +$result;
        if $index < 0 || $index >= $size {
            $result := '';
        } else {
            $result := $result[$index];
        }
    }
    return $result;
}

our sub llength(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "llength list"')
    }
    my @list :=
        Partcl::Grammar.parse(@args[0], :rule<list>, :actions(Partcl::Actions) ).ast;

    return +@list;
}

our sub lrange(*@args) {
    if +@args != 3 {
        error('wrong # args: should be "lrange list first last"')
    }
    my @list := @args[0].getList();
    my $from := @list.getIndex(@args[1]);
    my $to   := @list.getIndex(@args[2]);

    if $from < 0 { $from := 0}
    my $listLen := +@list;
    if $to > $listLen { $to := $listLen - 1 }

    my @retval := pir::new__ps('TclList');
    while $from <= $to  {
        @retval.push(@list[$from]);
        $from++;
    }
    return @retval;
}


our sub lrepeat(*@args) {
    if +@args < 2  {
        error('wrong # args: should be "lrepeat positiveCount value ?value ...?"');
    }
    my $count := @args.shift.getInteger();
    if $count < 1 {
        error('must have a count of at least 1');
    }
    my @result := pir::new__ps('TclList');
    while $count {
        for @args -> $elem { 
            @result.push($elem);
        }
        $count--;
    }
    return @result;
}

our sub lreplace(*@args) {
}

our sub lreverse(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "lreverse list"');
    }
    return @args[0].getList().reverse();
}

our sub lset(*@args) {
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

our sub pwd () {
    my $pwd := Q:PIR {
        $P0 = new ['OS']
        %r = $P0.'cwd'()
    };
    return $pwd;
}

our sub regexp(*@args) {
    if +@args < 2 {
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

our sub set(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "set varName ?newValue?"');
    }
    my $varname := @args[0];
    my $var :=
        Q:PIR {
            .local pmc varname, lexpad
            varname = find_lex '$varname'
            lexpad = find_dynamic_lex '%LEXPAD'
            %r = vivify lexpad, varname, ['Undef']
        };
    my $value := @args[1];
    if pir::defined($value) {
        pir::copy__0PP($var, $value)
    } elsif ! pir::defined($var) {
        error("can't read \"$varname\": no such variable");
    }
    return $var;
}

our sub socket(*@args) {
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

our sub subst(*@args) {
}

our sub switch(*@args) {
    if +@args < 3 {
        error('wrong # args: should be "switch ?switches? string pattern body ... ?default body?"');
    }
    my $regex := 0;
    my $glob := 0;
    my $nocase := 0;
    while @args[0] ne '--' && pir::substr(@args[0],0,1) eq '-' {
        my $opt := @args.shift;
        $regex := 1 if $opt eq '-regex';
        $glob := 1 if $opt eq '-glob';
        $nocase := 1 if $opt eq '-nocase';
    }
    my $string := @args.shift();
    if +@args % 2 == 1 {
        error('extra switch pattern with no body');
    }
    while @args {
        my $pat := @args.shift;
        my $body := @args.shift;
        if $nocase {
            $pat := pir::downcase($pat);
            $string := pir::downcase($string);
        }
        my $cmp := $string eq $pat;
        if $regex {
            my $re := ARE::Compiler.compile($pat);
            $cmp := ?Regex::Cursor.parse($string, :rule($re), :c(0));
        }
        if $glob {
            my $globber := StringGlob::Compiler.compile($pat);
            $cmp := ?Regex::Cursor.parse($string, :rule($globber), :c(0));
        }
        if $cmp || (+@args == 0 && $pat eq 'default') {
            return eval($body);
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

our sub upvar(*@args) {
}

our sub variable(*@args) {
}

our sub vwait(*@args) {
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
