class Partcl::Actions is HLL::Actions;

method TOP($/) { make $<TOP_eval>.ast; }

## TOP_eval and TOP_expr create a PAST::Block that uses the
## lexical scope given by the caller's %LEXPAD.

method TOP_eval($/) { make eval_block($<body>.ast); }
method TOP_expr($/) { make eval_block($<EXPR>.ast); }

sub eval_block($past) {
    ## This is the runtime equivalent of
    ##     register lexpad := DYNAMIC::<%LEXPAD>;
    ## The body of the code to be evaluated
    my $lexpad_init :=
        PAST::Var.new( :name<lexpad>, :scope<register>, :isdecl,
            :viviself( PAST::Op.new(:pirop('find_dynamic_lex Ps'), '%LEXPAD'))
        );

    PAST::Block.new( PAST::Stmts.new( $lexpad_init ), $past, :hll<tcl> );
}

## TOP_proc creates a PAST::Block that initializes a
## new lexical scope in %LEXPAD.

method TOP_proc($/) { make lex_block($<body>.ast); }

sub lex_block($past) {
    ## This is the runtime equivalent of 
    ##     register lexpad :=
    ##         my %LEXPAD := TclLexPad.newpad(DYNAMIC::<%LEXPAD>);
    my $lexpad_init :=
        PAST::Var.new( :name<lexpad>, :scope<register>, :isdecl,
            :viviself(
                PAST::Var.new( :name<%LEXPAD>, :scope<lexical>, :isdecl,
                    :viviself( 
                        PAST::Op.new( 
                            :pasttype<callmethod>, :name<newpad>,
                            PAST::Var.new( :name<TclLexPad>, :scope<package> ),
                            PAST::Op.new(:pirop('find_dynamic_lex Ps'), '%LEXPAD')
                        )
                    )
                )
            )
        );

    PAST::Block.new( PAST::Stmts.new( $lexpad_init ), $past, :hll<tcl> );
}

method body($/) { make $<script>.ast; }

method script($/) {
    my $past := PAST::Stmts.new( :node($/) );
    if $<command> {
        for $<command> { $past.push($_.ast); }
    }
    else { $past.push(''); }
    make $past;
}

method command($/) {
    my $past := PAST::Op.new( :name(~$<word>[0].ast), :node($/) );
    my $i := 1;
    my $n := +$<word>;
    while $i < $n {
        $past.push($<word>[$i].ast);
        $i++;
    }
    make $past;
}

method word:sym<{*}>($/)  {
    make PAST::Op.new( :name<EXPAND>, $<word>.ast, :flat);
}
method word:sym<{ }>($/)  { make $<braced_word>.ast; }
method word:sym<" ">($/)  { make concat_atoms($<quoted_atom>); }
method word:sym<bare>($/) { make concat_atoms($<bare_atom>); }

method braced_word($/) { make concat_atoms($<braced_atom>); }
method braced_atom:sym<{ }>($/)    { make '{' ~ $<braced_word>.ast ~ '}'; }
method braced_atom:sym<backnl>($/) { make ' '; }
method braced_atom:sym<back{>($/)  { make '{'; }
method braced_atom:sym<back}>($/)  { make '}'; }
method braced_atom:sym<back>($/)   { make "\\"; }
method braced_atom:sym<chr>($/)    { make ~$/; }

method quoted_atom:sym<[ ]>($/) { make $<script>.ast; }
method quoted_atom:sym<var>($/) { make $<variable>.ast; }
method quoted_atom:sym<$>($/)   { make '$'; }
method quoted_atom:sym<\\>($/)  { make $<backslash>.ast; }
method quoted_atom:sym<chr>($/) { make ~$/; }

method bare_atom:sym<[ ]>($/) { make $<script>.ast; }
method bare_atom:sym<var>($/) { make $<variable>.ast; }
method bare_atom:sym<$>($/)   { make '$'; }
method bare_atom:sym<\\>($/)  { make $<backslash>.ast; }
method bare_atom:sym<chr>($/) { make ~$/; }

method backslash:sym<bel>($/)   { make "\x07"; }
method backslash:sym<bs>($/)    { make "\x08"; }
method backslash:sym<ff>($/)    { make "\x0c"; }
method backslash:sym<lf>($/)    { make "\x0a"; }
method backslash:sym<cr>($/)    { make "\x0d"; }
method backslash:sym<ht>($/)    { make "\x09"; }
method backslash:sym<vt>($/)    { make "\x0b"; }
method backslash:sym<chr>($/)   { make ~$<chr>; }
method backslash:sym<backnl>($/) { make ' '; }
method backslash:sym<backx>($/) {
    my $len := pir::length(~$<x>);
    my $substr_len := ($len >= 2) ?? -2 !! -$len;
    make pir::chr(HLL::Actions::string_to_int(pir::substr(~$<x>, $substr_len), 16));
}
method backslash:sym<backo>($/) {
    make pir::chr(HLL::Actions::string_to_int(~$<o>, 8));
}
method backslash:sym<backu>($/) {
    make pir::chr(HLL::Actions::string_to_int(~$<u>, 16));
}

method list($/) {
    my @list;
    for $<EXPR> { @list.push($_.ast); }
    make @list;
}
method list_word($/) { make concat_atoms($<list_atom>); }
method list_atom:sym<\\>($/)  { make $<backslash>.ast; }
method list_atom:sym<chr>($/) { make ~$/; }

sub concat_atoms(@atoms) {
    my @parts;
    my $lastlit := '';
    for @atoms {
        my $ast := $_.ast;
        if !PAST::Node.ACCEPTS($ast) {
            $lastlit := $lastlit ~ $ast;
        }
        else {
            if $lastlit gt '' { @parts.push($lastlit); }
            @parts.push($ast);
            $lastlit := '';
        }
    }
    if $lastlit gt '' { @parts.push($lastlit); }
    my $past := @parts ?? @parts.shift !! '';
    while @parts {
        $past := PAST::Op.new( $past, @parts.shift, :pirop<concat>);
    }
    $past;
}


method variable($/) {
    ##  The beginning of each block sets up the C<lexpad> register
    ##  to point to the current lexical scope -- this simply
    ##  looks up the variable name in that lexpad and returns
    ##  the corresponding value.
    make PAST::Var.new( :scope<keyed>,
             PAST::Var.new( :name<lexpad>, :scope<register> ),
             ~$<identifier>,
             :node($/)
         );
}

method term:sym<variable>($/) { make $<variable>.ast; }
method term:sym<integer>($/) { make $<integer>.ast; }
method term:sym<[ ]>($/) { make $<script>.ast; }
method term:sym<" ">($/)  { make concat_atoms($<quoted_atom>); }

# vim: filetype=perl6:
