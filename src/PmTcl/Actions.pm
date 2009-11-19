class PmTcl::Actions is HLL::Actions;

our $LEXPAD;

INIT { $LEXPAD := PAST::Var.new( :name('lexpad'), :scope('register') ); }

method TOP($/) { make $<body>.ast; }

method PROC($/) { make $<body>.ast; }

method body($/) { 
    my $lexpad := 
        $*NEWPAD
        ?? PAST::Var.new( :name<%VARS>, :isdecl, :scope<lexical>,
                          :viviself<Hash> )
        !! PAST::Op.new( :pirop('find_dynamic_lex Ps'), '%VARS' );
    my $init := 
        PAST::Stmts.new(
            PAST::Var.new( :name<lexpad>, :scope<register>, :isdecl,
                           :viviself($lexpad) )
        );
    my $block := PAST::Block.new( $init, $<script>.ast, :node($/) );
    make $block;
}

method script($/) {
    my $past := PAST::Stmts.new( :node($/) );
    for $<command> { $past.push($_.ast); }
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

method word($/) { make $<WORD>.ast; }

method braced_word($/) { make ~$<val>; }

method quoted_word($/) { make concat_atoms($<quoted_atom>); }

method quoted_atom:sym<[ ]>($/) { make $<script>.ast; }
method quoted_atom:sym<var>($/) { make $<variable>.ast; }
method quoted_atom:sym<$>($/)   { make '$'; }
method quoted_atom:sym<\\>($/)  { make $<backslash>.ast; }
method quoted_atom:sym<chr>($/) { make ~$/; }

method bare_word($/) { make concat_atoms($<bare_atom>); }

method bare_atom:sym<[ ]>($/) { make $<script>.ast; }
method bare_atom:sym<var>($/) { make $<variable>.ast; }
method bare_atom:sym<$>($/)   { make '$'; }
method bare_atom:sym<\\>($/)  { make $<backslash>.ast; }
method bare_atom:sym<chr>($/) { make ~$/; }

method backslash:sym<nl>($/)  { make "\n"; }
method backslash:sym<chr>($/) { make ~$<chr>; }

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
    make PAST::Var.new( :scope<keyed>,
             $LEXPAD,
             ~$<identifier>,
             :node($/)
         );
}

method term:sym<variable>($/) { make $<variable>.ast; }
method term:sym<integer>($/) { make $<integer>.ast; }


