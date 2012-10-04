module FileHelper {

our  %Arg_limits;
our  %funcs;
our  %Auto_vivify;

INIT {

    ## Negative limit in "max" position => unlimited.
    %funcs<atime> := FileHelper::append;
    %Arg_limits<atime> := [ 0, -1, "" ];

    %funcs<attributes> := FileHelper::attributes;
    %Arg_limits<attributes> := [ 0, -1, "" ];

    %funcs<channels> := FileHelper::channels;
    %Arg_limits<channels> := [ 0, -1, "" ];

    %funcs<copy> := FileHelper::copy;
    %Arg_limits<copy> := [ 0, -1, "" ];

    %funcs<delete> := FileHelper::delete;
    %Arg_limits<delete> := [ 0, -1, "" ];

    %funcs<dirname> := FileHelper::dirname;
    %Arg_limits<dirname> := [ 1, 1, "name" ];

    %funcs<executable> := FileHelper::executable;
    %Arg_limits<executable> := [ 0, -1, "" ];

    %funcs<exists> := FileHelper::exists;
    %Arg_limits<exists> := [ 0, -1, "" ];

    %funcs<extension> := FileHelper::extension;
    %Arg_limits<extension> := [ 0, -1, "" ];

    %funcs<exists> := FileHelper::exists;
    %Arg_limits<exists> := [ 0, -1, "" ];

    %funcs<isdirectory> := FileHelper::isdirectory;
    %Arg_limits<isdirectory> := [ 0, -1, "" ];

    %funcs<isfile> := FileHelper::isfile;
    %Arg_limits<isfile> := [ 0, -1, "" ];

    %funcs<join> := FileHelper::join;
    %Arg_limits<join> := [ 0, -1, "" ];

    %funcs<link> := FileHelper::link;
    %Arg_limits<link> := [ 0, -1, "" ];

    %funcs<lstat> := FileHelper::lstat;
    %Arg_limits<lstat> := [ 0, -1, "" ];

    %funcs<mkdir> := FileHelper::mkdir;
    %Arg_limits<mkdir> := [ 0, -1, "" ];

    %funcs<mtime> := FileHelper::mtime;
    %Arg_limits<mtime> := [ 0, -1, "" ];

    %funcs<nativename> := FileHelper::nativename;
    %Arg_limits<nativename> := [ 0, -1, "" ];

    %funcs<normalize> := FileHelper::normalize;
    %Arg_limits<normalize> := [ 0, -1, "" ];

    %funcs<owned> := FileHelper::owned;
    %Arg_limits<owned> := [ 0, -1, "" ];

    %funcs<pathtype> := FileHelper::pathtype;
    %Arg_limits<pathtype> := [ 0, -1, "" ];

    %funcs<readable> := FileHelper::readable;
    %Arg_limits<readable> := [ 0, -1, "" ];

    %funcs<readlink> := FileHelper::readlink;
    %Arg_limits<readlink> := [ 0, -1, "" ];

    %funcs<rename> := FileHelper::rename;
    %Arg_limits<rename> := [ 0, -1, "" ];

    %funcs<rootname> := FileHelper::rootname;
    %Arg_limits<rootname> := [ 0, -1, "" ];

    %funcs<separator> := FileHelper::separator;
    %Arg_limits<separator> := [ 0, -1, "" ];

    %funcs<size> := FileHelper::size;
    %Arg_limits<size> := [ 0, -1, "" ];

    %funcs<split> := FileHelper::split;
    %Arg_limits<split> := [ 0, -1, "" ];

    %funcs<stat> := FileHelper::stat;
    %Arg_limits<stat> := [ 0, -1, "" ];

    %funcs<system> := FileHelper::system;
    %Arg_limits<system> := [ 0, -1, "" ];

    %funcs<tail> := FileHelper::tail;
    %Arg_limits<tail> := [ 0, -1, "" ];

    %funcs<type> := FileHelper::type;
    %Arg_limits<type> := [ 0, -1, "" ];

    %funcs<volumes> := FileHelper::volumes;
    %Arg_limits<volumes> := [ 0, -1, "" ];

    %funcs<writable> := FileHelper::writable;
    %Arg_limits<writable> := [ 0, -1, "" ];
}

# Parses optional -args, and generates "wrong#args" errors
# Dispatches to fairly normal NQP subs for the detailed work.
our sub dispatch_command(*@args) {
    my $num_args := +@args -1 ; # need option

    if $num_args < 0  {
        self.error('wrong # args: should be "file subcommand ?argument ...?"');
    }

    my @opts := <atime attributes channels copy delete dirname executable exists extension isdirectory isfile join link lstat mkdir mtime nativename normalize owned pathtype readable readlink rename rootname separator size split stat system tail type volumes writable>;
    my $cmd := _tcl::select_option(@opts, @args.shift, 'subcommand');

    my @limits := %Arg_limits{$cmd};

    if (@limits[1] >= 0 && $num_args > @limits[1]) || $num_args < @limits[0] {
        my $msg := @limits[2];
        $msg := " $msg" unless $msg eq '';
        self.error("wrong # args: should be \"file $cmd$msg\"")
    }

    my &subcommand := %funcs{$cmd};
    &subcommand(|@args);
}

our sub atime(*@args) {
    ''
}
our sub attributes(*@args) {
    ''
}
our sub channels(*@args) {
    ''
}
our sub copy(*@args) {
    ''
}
our sub delete(*@args) {
    ''
}
our sub dirname($filename) {
    my %PConfig := pir::getinterp__P()[8]; ## .IGLOBALS_CONFIG_HASH
    my $slash := %PConfig<slash>;

    if nqp::chars($filename) > 1 && nqp::substr($filename, -1, 1) eq $slash {
        $filename := pir::chopn__SSI($filename, 1);
    }

    my @array := nqp::split($slash, $filename);

    if +@array && @array[+@array-1] ne "" {
        @array.pop();
    }

    if ! +@array {
        return '.'; 
    }

    my @result := pir::new__PS('TclList');
    for @array -> $element {
        if $element ne "" {
            @result.push($element)
        }
    }
    return ($slash ~ @result.join($slash));
}

our sub executable(*@args) {
    ''
}
our sub exists(*@args) {
    ''
}
our sub extension(*@args) {
    ''
}
our sub isdirectory(*@args) {
    ''
}
our sub isfile(*@args) {
    ''
}
our sub join(*@args) {
    ''
}
our sub link(*@args) {
    ''
}
our sub lstat(*@args) {
    ''
}
our sub mkdir(*@args) {
    ''
}
our sub mtime(*@args) {
    ''
}
our sub nativename(*@args) {
    ''
}
our sub normalize(*@args) {
    ''
}
our sub owned(*@args) {
    ''
}
our sub pathtype(*@args) {
    ''
}
our sub readable(*@args) {
    ''
}
our sub readlink(*@args) {
    ''
}
our sub rename(*@args) {
    ''
}
our sub rootname(*@args) {
    ''
}
our sub separator(*@args) {
    ''
}
our sub size(*@args) {
    ''
}
our sub split(*@args) {
    ''
}
our sub stat(*@args) {
    ''
}
our sub system(*@args) {
    ''
}
our sub tail(*@args) {
    ''
}
our sub type(*@args) {
    ''
}
our sub volumes(*@args) {
    ''
}
our sub writable(*@args) {
    ''
}

}

# vim: expandtab shiftwidth=4 ft=perl6:
