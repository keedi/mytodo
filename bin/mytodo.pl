#!perl
# ABSTRACT: MyTodo command line utility
# PODNAME: mytodo.pl

use 5.010;
use utf8;
use strict;
use warnings;

use Encode qw( decode_utf8 encode_utf8 );
use Time::Piece;

use MyTodo;
use MyTodo::Script;
use MyTodo::Util;

binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';

my $opt = MyTodo::Script->new_with_options;

if ( $opt->schema_sqlite ) {
    say for map { chomp; "$_;" } MyTodo::Util->sql_sqlite;
    exit;
}

my %dbattrs = map { split /=/ } @{ $opt->dbattr };
my $todo = MyTodo->new(
    dsn        => $opt->dsn,
    dbusername => $opt->dbusername,
    dbpassword => $opt->dbpassword,
    dbattr     => \%dbattrs,
);

if ( $opt->list ) {
    my $display_func = sub {
        my $item = shift;

        my $str = sprintf(
            "[%-5s] %5s : #%-2d %s",
            uc $item->status,
            "\x{2605}" x $item->priority . "\x{2606}" x (5 - $item->priority),
            # 2605(★), 2606(☆)
            $item->id,
            decode_utf8($item->content),
        );
        if ($item->deadline) {
            my $deadline = Time::Seconds->new( $item->deadline - time )->pretty;
            $deadline =~ s/minus /-/;
            $deadline =~ s/(\d+) days, /sprintf('%2dD', $1)/e;
            $deadline =~ s/(\d+) hours, /sprintf('%2dH', $1)/e;
            $deadline =~ s/(\d+) minutes, /sprintf('%2dM', $1)/e;
            $deadline =~ s/\d+ seconds$//;
            $str .= " ($deadline)";
        }
        say $str;
    };

    for my $search (
        { status => 'doing' },
        { status => 'todo'  },
        { status => 'done'  },
    )
    {
        my $rs = $todo->list(
            search   => [ $search ],
            order_by => [ '-me.priority' ],
        );
        $display_func->($_) while $_ = $rs->next;
    }
    exit;
}

if ( $opt->add ) {
    my $content = shift;
    my $epoch   = time;

    my %params;
    $params{content}  = $content       if $content;
    $params{priority} = $opt->priority if $opt->priority;
    $params{status}   = $opt->status   if $opt->status && $opt->status =~ /^(todo|doing|done)$/;
    if ($opt->deadline) {
        my $t = Time::Piece->strptime($opt->deadline, "%Y-%m-%dT%H:%M:%S");
        $params{deadline} = $t->epoch;
    }

    $todo->add(%params);

    exit;
}

if ( $opt->delete ) {
    return unless $opt->delete;
    $todo->delete( id => $opt->delete );
    exit;
}

if ( $opt->edit ) {
    my $content = shift;
    my $epoch   = time;

    return unless $opt->edit;

    my %params;
    $params{id}       = $opt->edit;
    $params{content}  = $content       if $content;
    $params{priority} = $opt->priority if $opt->priority;
    $params{status}   = $opt->status   if $opt->status && $opt->status =~ /^(todo|doing|done)$/;
    if ($opt->deadline) {
        my $t = Time::Piece->strptime($opt->deadline, "%Y-%m-%dT%H:%M:%S");
        $params{deadline} = $t->epoch;
    }

    $todo->edit(%params);
    exit;
}

__END__

=head1 SYNOPSIS

    $ mkdir ~/.mytodo
    $ todo --schema_sqlite | sqlite3 ~/.mytodo/mytodo.db
    $ todo -h
    $ todo -a 'writing document for MyTodo'
    $ todo -a 'writing perl example using LibreOffice SDK' -p3 -sdoing
    $ todo -e1 -p5
    $ todo -l
    $ todo -d1 -d2


=head1 DESCRIPTION

...



=head1 SEE ALSO


=cut
