class Partcl::Actions is HLL::Actions {

    method TOP($/) { 
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<TOP_eval>.ast;
    }
    
    ## TOP_eval and TOP_expr create a PAST::Block that uses the
    ## lexical scope given by the caller's %LEXPAD.
    
    method TOP_eval($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make eval_block($<body>.ast);
    }
    method TOP_expr($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make eval_block($<EXPR>.ast);
    }

    sub eval_block($past) {
        ## This is the runtime equivalent of
        ##     register lexpad := DYNAMIC::<%LEXPAD>;
        ## The body of the code to be evaluated
        my $lexpad_init :=
            QAST::Var.new( :name<lexpad>, :scope<lexical>, :decl<var>);
  
        my $block := QAST::Block.new( QAST::Stmts.new( $lexpad_init ), $past);
        QAST::CompUnit.new( :hll<tcl>, $block );
    }
    
    ## TOP_proc creates a PAST::Block that initializes a
    ## new lexical scope in %LEXPAD.
    
    method TOP_proc($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make lex_block($<body>.ast);
    }
    
    sub lex_block($past) {
        ## This is the runtime equivalent of
        ##     register lexpad :=
        ##         my %LEXPAD := TclLexPad.newpad(DYNAMIC::<%LEXPAD>);
        my $lexpad_init :=
            QAST::Var.new( :name<lexpad>, :scope<local>, :decl<var>);
    
        QAST::Block.new( QAST::Stmts.new( $lexpad_init ), $past);
    }
    
    method body($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<script>.ast;
    }
    
    method script($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        my $past := QAST::Stmts.new( :node($/) );
        if $<command> {
            for $<command> { $past.push($_.ast); }
        }
        else { $past.push(''); }
        make $past;
    }
    
    method command($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        my $past := QAST::Op.new( 
               :op('callmethod'), :name('dispatch'), :node($/),
               QAST::WVal.new( :value(Internals) ) );
        my $i := 0;
        my $n := +$<word>;
        while $i < $n {
            my $ast := $<word>[$i].ast;
            $past.push($ast);
            $i++;
        }
        make $past;
    }
    
    method word:sym<{*}>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::Op.new( :op<call>, :name<EXPAND>, $<word>.ast, :flat);
    }
    method word:sym<{ }>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<braced_word>.ast;
    }
    method word:sym<" ">($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<quoted_word>.ast;
    }
    method word:sym<bare>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make concat_atoms($<bare_atom>);
    }
    
    method braced_word($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make concat_atoms($<braced_atom>);
    }
    method braced_atom:sym<{ }>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(
            '{' ~ $<braced_word>.ast ~ '}'
        ));
    }
    method braced_atom:sym<backnl>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(' '));
    }
    method braced_atom:sym<back{>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\\" ~ '{'));
    }
    method braced_atom:sym<back}>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\\" ~ '}'));
    }
    method braced_atom:sym<backd>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\\" ~ "\\"));
    }
    method braced_atom:sym<back>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\\"));
    }
    method braced_atom:sym<chr>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(~$/));
    }
    
    method quoted_word($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make concat_atoms($<quoted_atom>);
    }
    
    method quoted_atom:sym<[ ]>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<script>.ast;
    }
    method quoted_atom:sym<var>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<variable>.ast;
    }
    method quoted_atom:sym<$>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value('$'));
    }
    method quoted_atom:sym<\\>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<backslash>.ast;
    }
    method quoted_atom:sym<chr>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(~$/));
    }
    
    method bare_atom:sym<[ ]>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<script>.ast;
    }
    method bare_atom:sym<var>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<variable>.ast;
    }
    method bare_atom:sym<$>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value('$'));
    }
    method bare_atom:sym<\\>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<backslash>.ast;
    }
    method bare_atom:sym<chr>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(~$/));
    }
    
    method backslash:sym<bel>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\x07"));
    }
    method backslash:sym<bs>($/) { 
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\x08"));
    }
    method backslash:sym<ff>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\x0c"));
    }
    method backslash:sym<lf>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\x0a"));
    }
    method backslash:sym<cr>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\x0d"));
    }
    method backslash:sym<ht>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\x09"));
    }
    method backslash:sym<vt>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value("\x0b"));
    }
    method backslash:sym<chr>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(~$<chr>));
    }
    method backslash:sym<backnl>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(" "));
    }
    method backslash:sym<backx>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        my $len := nqp::chars(~$<x>);
        my $substr_len := ($len >= 2) ?? -2 !! -$len;
        make QAST::SVal.new(:value(
            nqp::chr(
                HLL::Actions.string_to_int(
                    nqp::substr(~$<x>, $substr_len), 16
                )
            )
        ));
    }
    method backslash:sym<backo>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(
            nqp::chr(HLL::Actions.string_to_int(~$<o>, 8))
        ));
    }
    method backslash:sym<backu>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(
            nqp::chr(HLL::Actions.string_to_int(~$<u>, 16))
        ));
    }
    
    method list($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        my @list := TclList.new();
    
        for $<EXPR> {
            @list.push: $_.ast;
        }
    
        make @list;
    }
    method list_word($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make concat_atoms($<list_atom>);
    }
    method list_atom:sym<\\>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<backslash>.ast;
    }
    method list_atom:sym<chr>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new(:value(~$/));
    }
    
    sub concat_atoms(@atoms) {
        my @parts;
        my $lastlit := '';
        if (! @atoms) {
            return QAST::SVal.new(:value(""));
        }
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
            $past := QAST::Op.new( :op<concat>, $past, @parts.shift);
        }
        $past;
    }
    
    
    ##  The beginning of each variable block sets up the C<lexpad> register
    ##  to point to the current lexical scope -- this simply
    ##  looks up the variable name in that lexpad and returns
    ##  the corresponding value.
    
    method variable:sym<normal>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        my $variable;
        if $<global> {
            $variable := QAST::Op.new( :op<atkey>,  
                QAST::Var.new(
                    :name<%GLOBALS>,
                    :scope<package>,
                    :namespace([])
                ),
                QAST::SVal.new(:value($<identifier>))
            );
       } else {
            $variable := QAST::Op.new( :op<atkey>,  
                QAST::Var.new(
                    :name<lexpad>,
                    :scope<lexical>
                ),
                QAST::SVal.new(:value($<identifier>))
            );
       }
    
        # Array access
        if $<key> {

            make QAST::SVal.new(:value($<key>[0]));

=begin fixit

            make QAST::Op.new( :op<if>,
                QAST::Op.new( :op<iseq_s>,
                    QAST::Op.new(  :op<what>, $variable),
                    QAST::Val.new( :value<TclArray>)
                ),
                QAST::Op.new( :op<atkey>,  
                    $variable,
                    QAST::SVal.new(:value($<key>[0]))
                ),
                QAST::Op.new( :op<call>, :name<error>, 
                    "can't read \"$<identifier>({$<key>[0]})\": variable isn't array"
                )
            )
=end fixit

        }
        else {

            # Scalar

            make QAST::SVal.new(:value("eek"));
  
=begin fixit
            make QAST::Op.new( :op<unless>,
                QAST::Op.new( :op<isnull>, $variable),
                QAST::Op.new( :op<unless>,
                    QAST::Op.new( :op<iseq_s>,
                        QAST::Op.new(  :op<what>, $variable),
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
=end fixit

        }
    }
    
    method variable:sym<escaped>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::Op.new( :op<atkey>,  
            QAST::Var.new(
                :name<lexpad>,
                :scope<lexical>
            ),
            QAST::SVal.new(:value($<identifier>))
        );
    }
    
    method integer($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        if $<sign> eq '-' {
            make QAST::IVal.new( :value(-1 * $<int>.ast) )
        } else {
            make QAST::IVal.new( :value($<int>.ast) )
        }
    }
    
    method int:sym<oct>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make HLL::Actions.string_to_int(~$<digits>, 8)
    }
    method int:sym<dec>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make HLL::Actions.string_to_int(~$<digits>, 10)
    }
    method int:sym<hex>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make HLL::Actions.string_to_int(~$<digits>, 16)
    }
    
    method term:sym<true>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new( :value($/.Str) )
    }
    method term:sym<false>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make QAST::SVal.new( :value($/.Str) )
    }
    
    method term:sym<variable>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<variable>.ast;
    }
    method term:sym<integer>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<integer>.ast;
    }
    
    method term:sym<( )>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<EXPR>.ast;
    }
    
    method term:sym<[ ]>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make $<script>.ast;
    }
    method term:sym<" ">($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make concat_atoms($<quoted_atom>);
    }

=begin head1 index
    
    Return a two element list; the first element is either 1 (from 0) or
    2 (from end), the second is the relative position.
    
=end head1 index
    
    method index:sym<int>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
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
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make (2, 0);
    }
    
    method index:sym<end+>($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make (2, $<a>.ast);
    }
    
    method index:sym<end->($/) {
        #say(nqp::getcodename(nqp::curcode()) ~ ':' ~ $/);
        make (2, -$<a>.ast);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6:
