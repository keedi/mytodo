package MyTodo;
# ABSTRACT: Personal To-Do management

use Moo;
use MooX::Types::MooseLike::Base qw( Str HashRef Maybe );
use namespace::clean -except => 'meta';

use DBIx::Lite;
#use MyTodo::Patch::DBIx::Lite::ResultSet;

has dsn => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has dbusername => (
    is  => 'ro',
    isa => Maybe[Str],
);

has dbpassword => (
    is  => 'ro',
    isa => Maybe[Str],
);

has dbattr => (
    is  => 'ro',
    isa => Maybe[HashRef],
);

has _dbix => (
    is      => 'lazy',
    builder => '_builder_handle',
);

sub _builder_handle {
    my $self = shift;

    my $dbix = DBIx::Lite->connect(
        $self->dsn,
        $self->dbusername,
        $self->dbpassword,
        $self->dbattr,
    );
    $dbix->schema->table('mytodo')->autopk('id');

    return $dbix;
}

sub BUILD {
    my $self = shift;

    $self->_dbix;
}

sub add {
    my $self = shift;

    my $epoch  = time;
    my %params = (
        status     => 'todo',
        created_on => $epoch,
        updated_on => $epoch,
        @_,
    );

    my $todo = $self->_dbix->table('mytodo')->insert({ %params });

    return $todo;
}

sub delete {
    my ( $self, %params ) = @_;

    my $id = delete $params{id};
    return unless $id;

    $self->_dbix->table('mytodo')
        ->search({ id => $id })
        ->delete;
}

sub edit {
    my ( $self, %params ) = @_;

    my $id = delete $params{id};
    return unless $id;

    $self->_dbix->table('mytodo')
        ->search({ id => $id })
        ->update({ %params, updated_on => time });
}

sub list {
    my $self   = shift;
    my %params = @_;

    my $rs
        = $self->_dbix->table('mytodo')
        ->select(qw/
            id
            status
            content
            priority
            deadline
            created_on
            updated_on
        /);
    $rs = $rs->search($_)   for @{ $params{search} };
    $rs = $rs->order_by($_) for @{ $params{order_by} };

    return $rs;
}

1;
__END__

=head1 SYNOPSIS

    use MyTodo;

    my $todo = MyTodo->new(
        dsn        => 'dbi:mysql:mytodo',
        dbusername => 'mytodo',
        dbpassword => 'mytodo',
        dbattr     => +{
            ...
        },
    );


=head1 DESCRIPTION

...


=attr dsn

=attr dbusername

=attr dbpassword

=attr dbattr


=method add

=method delete

=method edit

=method list


=head1 SEE ALSO


