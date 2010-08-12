class FileGlob::Actions is StringGlob::Actions;

method metachar:sym<{>($/) {
    my $ast := PAST::Regex.new( :pasttype<alt>, :node($/) );
    for $<word> {
        $ast.push(PAST::Regex.new( ~$_, :pasttype<literal>, :node($/) ) );
    }
    make $ast;
}

# vim: expandtab shiftwidth=4 ft=perl6:
