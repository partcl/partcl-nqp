our sub file(*@args) {
    File::dispatch_command(|@args);
}

module File;

our  %Arg_limits;
our  %funcs;
our  %Auto_vivify;

INIT {

    ## Negative limit in "max" position => unlimited.
    %funcs<atime> := File::append;
    %Arg_limits<atime> := [ 0, -1, "" ];

    %funcs<attributes> := File::attributes;
    %Arg_limits<attributes> := [ 0, -1, "" ];

    %funcs<channels> := File::channels;
    %Arg_limits<channels> := [ 0, -1, "" ];

    %funcs<copy> := File::copy;
    %Arg_limits<copy> := [ 0, -1, "" ];

    %funcs<delete> := File::delete;
    %Arg_limits<delete> := [ 0, -1, "" ];

    %funcs<dirname> := File::dirname;
    %Arg_limits<dirname> := [ 1, 1, "name" ];

    %funcs<executable> := File::executable;
    %Arg_limits<executable> := [ 0, -1, "" ];

    %funcs<exists> := File::exists;
    %Arg_limits<exists> := [ 0, -1, "" ];

    %funcs<extension> := File::extension;
    %Arg_limits<extension> := [ 0, -1, "" ];

    %funcs<exists> := File::exists;
    %Arg_limits<exists> := [ 0, -1, "" ];

    %funcs<isdirectory> := File::isdirectory;
    %Arg_limits<isdirectory> := [ 0, -1, "" ];

    %funcs<isfile> := File::isfile;
    %Arg_limits<isfile> := [ 0, -1, "" ];

    %funcs<join> := File::join;
    %Arg_limits<join> := [ 0, -1, "" ];

    %funcs<link> := File::link;
    %Arg_limits<link> := [ 0, -1, "" ];

    %funcs<lstat> := File::lstat;
    %Arg_limits<lstat> := [ 0, -1, "" ];

    %funcs<mkdir> := File::mkdir;
    %Arg_limits<mkdir> := [ 0, -1, "" ];

    %funcs<mtime> := File::mtime;
    %Arg_limits<mtime> := [ 0, -1, "" ];

    %funcs<nativename> := File::nativename;
    %Arg_limits<nativename> := [ 0, -1, "" ];

    %funcs<normalize> := File::normalize;
    %Arg_limits<normalize> := [ 0, -1, "" ];

    %funcs<owned> := File::owned;
    %Arg_limits<owned> := [ 0, -1, "" ];

    %funcs<pathtype> := File::pathtype;
    %Arg_limits<pathtype> := [ 0, -1, "" ];

    %funcs<readable> := File::readable;
    %Arg_limits<readable> := [ 0, -1, "" ];

    %funcs<readlink> := File::readlink;
    %Arg_limits<readlink> := [ 0, -1, "" ];

    %funcs<rename> := File::rename;
    %Arg_limits<rename> := [ 0, -1, "" ];

    %funcs<rootname> := File::rootname;
    %Arg_limits<rootname> := [ 0, -1, "" ];

    %funcs<separator> := File::separator;
    %Arg_limits<separator> := [ 0, -1, "" ];

    %funcs<size> := File::size;
    %Arg_limits<size> := [ 0, -1, "" ];

    %funcs<split> := File::split;
    %Arg_limits<split> := [ 0, -1, "" ];

    %funcs<stat> := File::stat;
    %Arg_limits<stat> := [ 0, -1, "" ];

    %funcs<system> := File::system;
    %Arg_limits<system> := [ 0, -1, "" ];

    %funcs<tail> := File::tail;
    %Arg_limits<tail> := [ 0, -1, "" ];

    %funcs<type> := File::type;
    %Arg_limits<type> := [ 0, -1, "" ];

    %funcs<volumes> := File::volumes;
    %Arg_limits<volumes> := [ 0, -1, "" ];

    %funcs<writable> := File::writable;
    %Arg_limits<writable> := [ 0, -1, "" ];
}

# Parses optional -args, and generates "wrong#args" errors
# Dispatches to fairly normal NQP subs for the detailed work.
our sub dispatch_command(*@args) {
    my $num_args := +@args -1 ; # need option

    if $num_args < 0  {
        error('wrong # args: should be "file subcommand ?argument ...?"');
    }

    my @opts := <atime attributes channels copy delete dirname executable exists extension isdirectory isfile join link lstat mkdir mtime nativename normalize owned pathtype readable readlink rename rootname separator size split stat system tail type volumes writable>;
    my $cmd := _tcl::select_option(@opts, @args.shift, 'subcommand');

    my @limits := %Arg_limits{$cmd};

    if (@limits[1] >= 0 && $num_args > @limits[1]) || $num_args < @limits[0] {
        my $msg := @limits[2];
        $msg := " $msg" unless $msg eq '';
        error("wrong # args: should be \"file $cmd$msg\"")
    }

    my &subcommand := %funcs{$cmd};
    &subcommand(|@args);
}

my sub atime(*@args) {
    ''
}
my sub attributes(*@args) {
    ''
}
my sub channels(*@args) {
    ''
}
my sub copy(*@args) {
    ''
}
my sub delete(*@args) {
    ''
}
my sub dirname($filename) {
    my %PConfig := pir::getinterp[8]; ## .IGLOBALS_CONFIG_HASH
    my $slash := %PConfig<slash>;

    if pir::length($filename) > 1 && pir::substr($filename, -1, 1) eq $slash {
        $filename := pir::chopn__ssi($filename, 1);
    }

    my @array := pir::split($slash, $filename);

    if +@array && @array[+@array-1] ne "" {
        @array.pop();
    }

    if ! +@array {
        return '.'; 
    }

    my @result := pir::new('TclList');
    for @array -> $element {
        if $element ne "" {
            @result.push($element)
        }
    }
    return ($slash ~ @result.join($slash));
}

my sub executable(*@args) {
    ''
}
my sub exists(*@args) {
    ''
}
my sub extension(*@args) {
    ''
}
my sub isdirectory(*@args) {
    ''
}
my sub isfile(*@args) {
    ''
}
my sub join(*@args) {
    ''
}
my sub link(*@args) {
    ''
}
my sub lstat(*@args) {
    ''
}
my sub mkdir(*@args) {
    ''
}
my sub mtime(*@args) {
    ''
}
my sub nativename(*@args) {
    ''
}
my sub normalize(*@args) {
    ''
}
my sub owned(*@args) {
    ''
}
my sub pathtype(*@args) {
    ''
}
my sub readable(*@args) {
    ''
}
my sub readlink(*@args) {
    ''
}
my sub rename(*@args) {
    ''
}
my sub rootname(*@args) {
    ''
}
my sub separator(*@args) {
    ''
}
my sub size(*@args) {
    ''
}
my sub split(*@args) {
    ''
}
my sub stat(*@args) {
    ''
}
my sub system(*@args) {
    ''
}
my sub tail(*@args) {
    ''
}
my sub type(*@args) {
    ''
}
my sub volumes(*@args) {
    ''
}
my sub writable(*@args) {
    ''
}

# vim: expandtab shiftwidth=4 ft=perl6:
