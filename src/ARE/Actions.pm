class ARE::Actions is HLL::Actions;

method TOP($/) {
    my $past := buildsub( $<nibbler>.ast );
    $past.node($/);
    make $past;
}

method nibbler($/) {
    my $past;
    if +$<termish> > 1 {
        $past := PAST::Regex.new( :pasttype('alt'), :node($/) );
        for $<termish> { $past.push($_.ast); }
    }
    else {
        $past := $<termish>[0].ast;
    }
    make $past;
}

method termish($/) {
    my $past := PAST::Regex.new( :pasttype('concat'), :node($/) );
    my $lastlit := 0;
    for $<noun> {
        my $ast := $_.ast;
        if $ast {
            if $lastlit && $ast.pasttype eq 'literal'
                    && !PAST::Node.ACCEPTS($ast[0]) {
                $lastlit[0] := $lastlit[0] ~ $ast[0];
            }
            else {
                $past.push($ast);
                $lastlit := $ast.pasttype eq 'literal'
                            && !PAST::Node.ACCEPTS($ast[0])
                            ?? $ast !! 0;
            }
        }
    }
    make $past;
}

method quantified_atom($/) {
    make $<atom>.ast;
}

method atom($/) {
    my $past := PAST::Regex.new( ~$/, :pasttype<literal>, :node($/) );
    make $past;
}


sub buildsub($rpast, $block = PAST::Block.new() ) {
    $rpast := PAST::Regex.new(
        PAST::Regex.new( :pasttype('scan') ),
        $rpast,
        PAST::Regex.new( :pasttype('pass') ),
        :pasttype('concat'),
    );
    unless $block.symbol('$¢') { $block.symbol('$¢', :scope<lexical>); }
    unless $block.symbol('$/') { $block.symbol('$/', :scope<lexical>); }
    $block.push($rpast);
    $block.blocktype('method');
    $block;
}

