use NQPHLL;

class Partcl::Compiler is HLL::Compiler {

    INIT {
        my $compiler := Partcl::Compiler.new();
        $compiler.language('Partcl');
        $compiler.parsegrammar(Partcl::Grammar);
        $compiler.parseactions(Partcl::Actions);
    }
    
    method backtrace($ex) {
        my $stderr := pir::getstderr;
        $stderr.print($ex<message>);
        $stderr.print("\n    while executing\n");
    
        my @backtrace := $ex.backtrace();
    
        for @backtrace -> $entry {
            my $sub := $entry<sub>;
            my $subname := ~$sub;
            next if pir::length($subname) > 0 &&
                    pir::ord($subname) eq 95; # XXX hack to skip _block...
            next if pir::typeof($sub) eq "Undef";
            my @ns := $sub.get_namespace().get_name();
    
            my $top := @ns.shift;
            if $top eq "tcl" {
                if +@ns {
                    $stderr.print(pir::join('::', @ns));
                    $stderr.print( '::' );
                }
            }
            $stderr.print( ~$sub );
            $stderr.print( "\n" );
    
            my $location := $entry<annotations>;
            my $line := $location<line> ?? 'line ' ~ $location<line> !! '<unknown line>';
            my $file := $location<file> ?? $location<file> !! '<unknown file>';
            $stderr.print('    (file "' ~ $file ~ '" ' ~ $line ~ ")\n");
        }
    
        '';
    }
}

# vim: expandtab shiftwidth=4 ft=perl6:
