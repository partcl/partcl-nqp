method switch(*@args) {
    if +@args < 2 {
        self.error('wrong # args: should be "switch ?switches? string pattern body ... ?default body?"');
    }

    my $regex := 0;
    my $glob := 0;
    my $nocase := 0;
    if +@args != 2 {
        while @args[0] ne '--' && nqp::substr(@args[0],0,1) eq '-' {
            my $opt := @args.shift;
            $regex := 1 if $opt eq '-regex';
            $glob := 1 if $opt eq '-glob';
            $nocase := 1 if $opt eq '-nocase';
        }
        @args.shift if @args[0] eq '--';
    }
    # else, only 2 options, must be 2nd variant.

    my $string := @args.shift();
    if +@args == 1 {
        # list form; expand the list.
        @args := @args[0].getList();
        self.error('wrong # args: should be "switch ?switches? string {pattern body ... ?default body?}"')
            unless +@args;
    }
    if +@args % 2 == 1 {
        self.error('extra switch pattern with no body');
    }
    while @args {
        my $pat := @args.shift;
        my $body := @args.shift;
        if $nocase {
            $pat := nqp::lc($pat);
            $string := nqp::lc($string);
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

# vim: expandtab shiftwidth=4 ft=perl6:
