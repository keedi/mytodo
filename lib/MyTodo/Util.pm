package MyTodo::Util;
# ABSTRACT: MyTodo code snippets

sub sql_sqlite {
    return (
        <<'END_SQL',
DROP TABLE IF EXISTS mytodo
END_SQL
        <<'END_SQL',
CREATE TABLE mytodo (
    id INTEGER NOT NULL,
    status     CHARACTER(32) NOT NULL,
    content    INTEGER       NOT NULL,
    priority   INTEGER       DEFAULT 0,
    deadline   DATETIME,
    updated_on DATETIME      NOT NULL,
    created_on DATETIME      NOT NULL,
    PRIMARY KEY (id)
)
END_SQL
    );
}

1;
__END__

=head1 SYNOPSIS

...


=head1 DESCRIPTION

...



=head1 SEE ALSO


=cut
