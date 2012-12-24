package MyTodo::Script;
# ABSTRACT: MyTodo command line utility options processing

use Moo;
use MyTodo::Patch::MooX::Options ( protect_argv => 0 );
use namespace::clean -except => [qw/_options_data _options_config/];

use File::HomeDir;
use File::Spec::Functions;

option add => (
    is    => 'ro',
    short => 'a',
    doc   => 'add todo',
    order => 1,
);

option delete => (
    is        => 'ro',
    short     => 'd',
    format    => 'i@',
    doc       => 'delete todo',
    autosplit => ',',
    order     => 1,
);

option edit => (
    is        => 'ro',
    short     => 'e',
    format    => 'i@',
    doc       => 'edit todo',
    autosplit => ',',
    order     => 1,
);

option list => (
    is    => 'ro',
    short => 'l',
    doc   => 'list todo',
    order => 1,
);

option priority => (
    is     => 'ro',
    short  => 'p',
    format => 'i',
    doc    => 'todo priority',
    order  => 12,
);

option deadline => (
    is     => 'ro',
    format => 's',
    doc    => 'todo deadline (local time)',
    order  => 13,
);

option status => (
    is     => 'ro',
    short  => 's',
    format => 's',
    doc    => 'todo status',
    order  => 14,
);

option dsn => (
    is      => 'ro',
    doc     => 'database dsn',
    format  => 's',
    default => sub {
        my $home = File::HomeDir->my_home;
        my $db   = catfile( $home, '.mytodo', 'mytodo.db' );
        return "dbi:SQLite:$db";
    },
    order   => 21,
);

option dbusername => (
    is     => 'ro',
    doc    => 'database username',
    format => 's',
    order  => 22,
);

option dbpassword => (
    is     => 'ro',
    doc    => 'database password',
    format => 's',
    order  => 23,
);

option dbattr => (
    is      => 'ro',
    doc     => 'database attribute',
    default => sub { [] },
    format  => 's@',
    order   => 24,
);

option schema_sqlite => (
    is    => 'ro',
    doc   => 'schema sql for sqlite',
    order => 99,
);

1;
__END__

=head1 SYNOPSIS

    use MyTodo::Script;

    my $opt = MyTodo::Script->new_with_options;


=head1 DESCRIPTION

...


=attr add

=attr delete

=attr edit

=attr list

=attr priority

=attr deadline

=attr status

=attr dsn

=attr dbusername

=attr dbpassword

=attr dbattr

=attr schema_sqlite


=method new_with_options


=head1 SEE ALSO


=cut
