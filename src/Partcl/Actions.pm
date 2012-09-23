class Partcl::Actions is HLL::Actions {

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
            QAST::Var.new( :name<lexpad>, :scope<local>, :decl<var>);
  
  
        my $block;  
        if ! nqp::isnull(pir::find_dynamic_lex__PS('@*PARTCL_COMPILER_NAMESPACE')) {
            $block := QAST::Block.new( QAST::Stmts.new( $lexpad_init ), $past,
                :namespace(@*PARTCL_COMPILER_NAMESPACE)
            );
        } else {
            $block := QAST::Block.new( QAST::Stmts.new( $lexpad_init ), $past);
        }
        QAST::CompUnit.new( :hll<tcl>, $block );
    }
    
    ## TOP_proc creates a PAST::Block that initializes a
    ## new lexical scope in %LEXPAD.
    
    method TOP_proc($/) { make lex_block($<body>.ast); }
    
    sub lex_block($past) {
        ## This is the runtime equivalent of
        ##     register lexpad :=
        ##         my %LEXPAD := TclLexPad.newpad(DYNAMIC::<%LEXPAD>);
        my $lexpad_init :=
            QAST::Var.new( :name<lexpad>, :scope<local>, :decl<var>);
    
        if ! nqp::isnull(pir::find_dynamic_lex__PS('@*PARTCL_COMPILER_NAMESPACE')) {
            QAST::Block.new( QAST::Stmts.new( $lexpad_init ), $past,
                :namespace(@*PARTCL_COMPILER_NAMESPACE)
            );
        } else {
            QAST::Block.new( QAST::Stmts.new( $lexpad_init ), $past);
        }
    }
    
    method body($/) { make $<script>.ast; }
    
    method script($/) {
        my $past := QAST::Stmts.new( :node($/) );
        if $<command> {
            for $<command> { $past.push($_.ast); }
        }
        else { $past.push(''); }
        make $past;
    }
    
    method command($/) {
        my $past := QAST::Op.new( :op<call>, :name('invoke'), :node($/) );
        my $i := 0;
        my $n := +$<word>;
        while $i < $n {
            $past.push($<word>[$i].ast);
            $i++;
        }
        make $past;
    }
    
    method word:sym<{*}>($/)  {
        make QAST::Op.new( :op<call>, :name<EXPAND>, $<word>.ast, :flat);
    }
    method word:sym<{ }>($/)  { make $<braced_word>.ast; }
    method word:sym<" ">($/)  { make $<quoted_word>.ast; }
    method word:sym<bare>($/) { make concat_atoms($<bare_atom>); }
    
    method braced_word($/) { make concat_atoms($<braced_atom>); }
    method braced_atom:sym<{ }>($/)    { make '{' ~ $<braced_word>.ast ~ '}'; }
    method braced_atom:sym<backnl>($/) { make ' '; }
    method braced_atom:sym<back{>($/)  { make "\\" ~ '{'; }
    method braced_atom:sym<back}>($/)  { make "\\" ~ '}'; }
    method braced_atom:sym<backd>($/)  { make "\\" ~ "\\"; }
    method braced_atom:sym<back>($/)   { make "\\"; }
    method braced_atom:sym<chr>($/)    { make ~$/; }
    
    method quoted_word($/) { make concat_atoms($<quoted_atom>); }
    
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
        my $len := nqp::chars(~$<x>);
        my $substr_len := ($len >= 2) ?? -2 !! -$len;
        make nqp::chr(HLL::Actions::string_to_int(nqp::substr(~$<x>, $substr_len), 16));
    }
    method backslash:sym<backo>($/) {
        make nqp::chr(HLL::Actions::string_to_int(~$<o>, 8));
    }
    method backslash:sym<backu>($/) {
        make nqp::chr(HLL::Actions::string_to_int(~$<u>, 16));
    }
    
    method list($/) {
        my @list := pir::new__PS('TclList');
    
        for $<EXPR> {
            @list.push: $_.ast;
        }
    
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
            if !QAST::Node.ACCEPTS($ast) {
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
            $past := QAST::Op.new( :op<call>, $past, @parts.shift, :name<concat>);
        }
        $past;
    }
    
    
    ##  The beginning of each variable block sets up the C<lexpad> register
    ##  to point to the current lexical scope -- this simply
    ##  looks up the variable name in that lexpad and returns
    ##  the corresponding value.
    
    method variable:sym<normal>($/) {
        my $variable;
        if $<global> {
           $variable := QAST::Var.new( :scope<keyed>,
               QAST::Var.new( :name<%GLOBALS>, :scope<package>, :namespace([]) ),
               ~$<identifier>
           );
       } else {
           $variable := QAST::Var.new( :scope<keyed>,
               QAST::Var.new( :name<lexpad>, :scope<register> ),
               ~$<identifier>
           );
        }
    
        # Array access
        if $<key> {
            make QAST::Op.new( :pasttype<if>,
                QAST::Op.new( :pirop<iseq__iss>,
                    QAST::Op.new(  :op<pir::typeof__SP>, $variable),
                    QAST::Val.new( :value<TclArray>)
                ),
                QAST::Var.new( :scope<keyed>,
                    $variable,
                    ~$<key>[0]
                ),
                QAST::Op.new( :op<call>, :name<error>, 
                    "can't read \"$<identifier>({$<key>[0]})\": variable isn't array"
                )
            )
        }
        else {
            # Scalar
    
            make QAST::Op.new( :pasttype<unless>,
                QAST::Op.new( :pirop<isnull>, $variable),
                QAST::Op.new( :pasttype<unless>,
                    QAST::Op.new( :op<pir::iseq__ISS>,
                        QAST::Op.new(  :op<pir::typeof__SP>, $variable),
                        QAST::Val.new( :value<TclArray>)
                    ),
                    $variable,
                    QAST::Op.new( :op<call>, :name<error>, 
                        "can't read \"$<identifier>\": variable is array"
                    )
                ),
                QAST::Op.new( :op<call>, :name<error>, 
                    "can't read \"$<identifier>\": no such variable"
                )
            );
        }
    }
    
    method variable:sym<escaped>($/) {
        make QAST::Var.new( :scope<keyed>,
                 QAST::Var.new( :name<lexpad>, :scope<register> ),
                 ~$<identifier>,
                 :node($/)
             );
    }
    
    method integer($/) {
        if $<sign> eq '-' {
            make -1 * $<int>.ast;
        } else {
            make $<int>.ast;
        }
    }
    
    method int:sym<oct>($/) { make HLL::Actions::string_to_int(~$<digits>, 8) }
    method int:sym<dec>($/) { make HLL::Actions::string_to_int(~$<digits>, 10) }
    method int:sym<hex>($/) { make HLL::Actions::string_to_int(~$<digits>, 16) }
    
    method term:sym<true>($/)  { make $/.Str }
    method term:sym<false>($/) { make $/.Str }
    
    method term:sym<variable>($/) { make $<variable>.ast; }
    method term:sym<integer>($/) { make $<integer>.ast; }
    
    method term:sym<( )>($/) { make $<EXPR>.ast; }
    
    method term:sym<[ ]>($/) { make $<script>.ast; }
    method term:sym<" ">($/) { make concat_atoms($<quoted_atom>); }

=begin head1 index
    
    Return a two element list; the first element is either 1 (from 0) or
    2 (from end), the second is the relative position.
    
=end head1 index
    
    method index:sym<int>($/) {
        my $val := $<a>.ast;
        if $<op> {
           if ~$<op>[0] eq '+' {
               $val := $val + $<b>[0].ast;
           } else {
               $val := $val - $<b>[0].ast;
           }
        }
        make (1, $val);
    }
    
    method index:sym<end>($/) {
        make (2, 0);
    }
    
    method index:sym<end+>($/) {
        make (2, $<a>.ast);
    }
    
    method index:sym<end->($/) {
        make (2, -$<a>.ast);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6:
