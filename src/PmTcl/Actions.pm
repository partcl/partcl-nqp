class PmTcl::Actions is HLL::Actions;

our $LEXPAD;

INIT { $LEXPAD := PAST::Var.new( :name('lexpad'), :scope('register') ); }

method TOP($/) { 
    my $block := 
        PAST::Block.new(
            PAST::Stmts.new(
                PAST::Op.new( :inline('    .local pmc lexpad',
                                      '    get_hll_global lexpad, "%VARS"',
                                      '    .lex "%VARS", lexpad') )
            ),
            $<script>.ast
        );
    make $block;
}

method body($/) {
    my $block := 
        PAST::Block.new(
            PAST::Stmts.new(
                PAST::Op.new( :inline('    .local pmc lexpad',
                                      '    new lexpad, ["Hash"]',
                                      '    .lex "%VARS", lexpad') )
            ),
            $<script>.ast
        );
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

method quoted_atom:sym<[ ]>($/) { make $<command>.ast; }
method quoted_atom:sym<$>($/)   { make $<variable>.ast; }
method quoted_atom:sym<\\>($/)  { make $<backslash>.ast; }
method quoted_atom:sym<chr>($/) { make ~$/; }

method bare_word($/) { make concat_atoms($<bare_atom>); }

method bare_atom:sym<[ ]>($/) { make $<command>.ast; }
method bare_atom:sym<$>($/)   { make $<variable>.ast; }
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


