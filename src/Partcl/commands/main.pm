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

our sub apply(*@args) {
    if +@args == 0 {
        error('wrong # args: should be "apply lambdaExpr ?arg1 arg2 ...?"');
    }
    '';
}

our sub binary(*@args) {
    error('wrong # args: should be "binary option ?arg arg ...?"')
        if !+@args;

    my $subcommand := @args.shift();
    if $subcommand eq 'format' {
        if +@args < 1 {
            error('wrong # args: should be "binary format formatString ?arg arg ...?"');
        }
    } elsif $subcommand eq 'scan' {
        if +@args < 2 {
            error('wrong # args: should be "binary scan value formatString ?varName varName ...?"');
        }
        my $value := @args.shift();
        my $formatString := @args.shift();
        for @args -> $varName {
            set($varName, ''); # XXX placeholder
        }
    } else {
        error("bad option \"$subcommand\": must be format or scan");
    }
    '';
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

            # XXX using numeric type ids is fragile.
            if $parrot_type == 57 {      # CONTROL_RETURN
                $retval := 2;             # TCL_RETURN
            } elsif $parrot_type == 65 { # CONTROL_LOOP_LAST
                $retval := 3;             # TCL_BREAK
            } elsif $parrot_type == 64 { # CONTROL_LOOP_NEXT
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
    $retval;
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
        $dir := pir::new__ps('Env')<HOME>;
    }
    my $OS := pir::new__ps('OS');
    $OS.chdir($dir);
}

our sub concat(*@args) {
    my $result := @args ?? String::trim(@args.shift) !! '';
    while @args {
        $result := $result ~ ' ' ~ String::trim(@args.shift);
    }
    $result;
}

our sub eof(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "eof channelId"')
    }
    my $chan := _getChannel(@args[0]);
    0;
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
    if +@args < 2 || +@args > 3 {
        error('wrong # args: should be "fileevent channelId event ?script?"');
    }
    my $channelId := @args.shift;
    my $event     := @args.shift;
    if $event ne 'readable' || $event ne 'writable' {
        error("bad event name \"$event\": must be readable or writable");
    }
    '';
}

our sub flush(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "flush channelId"');
    }
    my $ioObj := _getChannel(@args[0]);
    if pir::can__ips($ioObj, 'flush') {
        $ioObj.flush();
    }
    '';
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
            if $!<type> == 64 { # CONTROL_LOOP_NEXT
                eval($incr);
            } elsif $!<type> == 65 { # CONTROL_LOOP_LAST
                $loop := 0;
            }
        }
    }
    '';
}

our sub foreach(*@args) {
    if +@args < 2 || +@args % 2 == 0 {
        error('wrong # args: should be "foreach varList list ?varList list ...? command"');
    }

    my @varlists;
    my @lists;
    my $iterations := 0;

    my $body := @args.pop();
    my @varlist;
    my @list;
    for @args -> @varlist, @list {
        @varlist := @varlist.getList();
        @list    := @list.getList();

        error('foreach varlist is empty') unless +@varlist;

        @varlists.push(@varlist);
        @lists.push(@list);

        # elements in list are spread over varlist. make sure we're
        # going to iterate only enough to cover.
        my $count := pir::ceil__in(+@list / +@varlist);
        $iterations := $count if $count > $iterations;
    }

    my $iteration := 0;
    while $iteration < $iterations {
        $iteration++;
        my $counter := 0;
        while $counter < +@varlists {
            my @varlist := @varlists[$counter];
            my @list :=    @lists[$counter];
            $counter++;

            my $I0 := 0;
            while $I0 < +@varlist {
                my $varname := @varlist[$I0++];

                if +@list {
                    set($varname,pir::clone__pp(@list.shift()));
                } else {
                    set($varname,'');
                }
            }
        }

        my $result := 0;

        # let break and continue propagate to our surrounding while.
        eval($body);
    }
    '';
}

our sub format(*@args) {
    unless +@args {
        error('wrong # args: should be "format formatString ?arg arg ...?"');
    }

    pir::sprintf__ssp(@args.shift(), @args)
}

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
    if pir::length__is($result) >0 && pir::substr__ssi($result, -1) eq "\n" {
        $result := pir::chopn__ssi($result,1);
    }
    if +@args == 2 {
        set(@args[1], $result);
        return pir::length__is($result);
    } else {
        return $result;
    }
}

our sub glob(*@args) {
    my $dir := ".";
    while @args[0] ne '--' && pir::substr(@args[0],0,1) eq '-' {
        my $opt := @args.shift;
        $dir := @args.shift if $opt eq '-directory';
    }
    my @files := pir::new__ps('OS').readdir($dir);
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
    @retval;
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
    my @params  := $args.getList();

    for @params {
        my @argument := $_.getList();

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
    our %CHANNELS;

    my $nl := 1;
    if @args[0] eq '-nonewline' {
        @args.shift; $nl := 0;
    }
    my $channelId;
    if +@args == 1 {
        $channelId := 'stdout';
    } else {
        $channelId := @args.shift;
    } 
    my $chanObj := %CHANNELS{$channelId};
    if (! pir::defined($chanObj) ) {
        error("can not find channel named \"$channelId\"");
    }
    pir::print__vps($chanObj, @args[0]);
    pir::print__vps($chanObj, "\n") if $nl;
    '';
}

our sub pwd () {
    pir::new__ps('OS').'cwd'();
}

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

our sub rename(*@args) {
    if +@args != 2 {
        error('wrong # args: should be "rename oldName newName"');
    }
}

our sub set(*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "set varName ?newValue?"');
    }
    my $varname := @args[0];
    my $value   := @args[1];

    # Does it look like foo(bar) ?
    # XXX Can we use the variable term in the grammar for this?
    my $result;
    if pir::ord__isi($varname, -1) == 41 && pir::index__iss($varname, '(' ) != -1 {
        # find the variable name and key name
        my $left_paren  := pir::index__iss($varname, '(');
        my $right_paren := pir::index__iss($varname, ')');
        my $keyname   := pir::substr__ssii($varname, $left_paren+1, $right_paren-$left_paren-1);
        my $arrayname := pir::substr__ssii($varname, 0, $left_paren);
        
        if pir::defined($value) { # set
            my $var := Q:PIR {
                .local pmc varname, lexpad
                varname = find_lex '$arrayname'
                lexpad = find_dynamic_lex '%LEXPAD'
                %r = vivify lexpad, varname, ['TclArray']
            };
            if !pir::isa($var, 'TclArray') {
                error("can't set \"$varname\": variable isn't array");
            }
            $var{$keyname} := $value;
            $result := $var{$keyname};
        } else { # get
            my $lexpad := pir::find_dynamic_lex('%LEXPAD');
            my $var    := $lexpad{$arrayname};
            if pir::isnull($var) {
                error("can't read \"$varname\": no such variable");
            } elsif !pir::isa($var, 'TclArray') {
                error("can't read \"$varname\": variable isn't array");
            } elsif pir::isnull($var{$keyname}) {
                error("can't read \"$varname($keyname)\": no such element in array");
            } else {
                $result := $var{$keyname};
            }
        }
    } else {
        # scalar
        $result := Q:PIR {
            .local pmc varname, lexpad
            varname = find_lex '$varname'
            lexpad = find_dynamic_lex '%LEXPAD'
            %r = vivify lexpad, varname, ['Undef']
        };
        if pir::isa($result, 'TclArray') {
            error("can't set \"$varname\": variable is array");
        } elsif pir::defined($value) {
            pir::copy__0PP($result, $value)
        } elsif ! pir::defined($result) {
            error("can't read \"$varname\": no such variable");
        }
    }
    $result;
}

our sub socket(*@args) {
    '';
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
        return list();
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
    @result;
}

our sub subst(*@args) {
    '';
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

    $ms_per ~ ' microseconds per iteration';
}

our sub unset(*@args) {
    for @args -> $varname {
        Q:PIR {
            $P1 = find_lex '$varname'
            $P2 = find_dynamic_lex '%LEXPAD'
            delete $P2[$P1]
        }
    }
    '';
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
    '';
}

our sub variable(*@args) {
    error('wrong # args: should be "variable ?name value...? name ?value?"')
        unless +@args;
    '';
}

our sub vwait(*@args) {
    if +@args != 1 {
        error('wrong # args: should be "vwait name"');
    }
    '';
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
    $args.getList();
}

sub dumper($what, $label = 'VAR1') {
    pir::load_bytecode('dumper.pbc');
    my &dumper := Q:PIR {
        %r = get_root_global ['parrot'], '_dumper'
    };
    &dumper($what, $label);
}

# vim: filetype=perl6:
