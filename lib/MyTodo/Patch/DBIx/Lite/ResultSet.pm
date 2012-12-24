package MyTodo::Patch::DBIx::Lite::ResultSet;
# ABSTRACT: Patch DBIx::Lite::ResultSet for MyTodo

{
    package DBIx::Lite::ResultSet;

    use strict;
    use warnings;

    no warnings 'redefine';

    #
    # this code is almost same as DBIx::Lite::ResultSet 0.14
    #
    sub update_sql {
        my $self = shift;
        my $update_cols = shift;
        ref $update_cols eq 'HASH' or croak "update_sql() requires a hashref";
        
        my $update_where = { -and => $self->{where} };
        
        if ($self->{cur_table}{name} ne $self->{table}{name}) {
            my @pk = $self->{cur_table}->pk
                or croak "No primary key defined for " . $self->{cur_table}{name} . "; cannot update using relationships";
            @pk == 1
                or croak "Update across relationships is not allowed with multi-column primary keys";
            
            my $fq_pk = $self->_table_prefix($self->{cur_table}{name}) . "." . $pk[0];
            $update_where = {
                $fq_pk => {
                    -in => \[ $self->select($pk[0])->select_sql ],
                },
            };
        }

        return $self->{dbix_lite}->{abstract}->update(
            $self->{cur_table}{name},
            $update_cols, $update_where,
        );
    }

    1;
}

1;
__END__

=head1 SYNOPSIS

    use DBIx::Lite;
    use MyTodo::Patch::DBIx::Lite::ResultSet;


=head1 DESCRIPTION

This patch fix C<update> method for SQLite database.
SQLite database doesn't support C<AS> for C<UPDATE> statement.
See L<Syntax Diagrams For SQLite, update-stmt|http://www.sqlite.org/syntaxdiagrams.html#update-stmt>.
