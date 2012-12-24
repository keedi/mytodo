#!/usr/bin/env perl

use 5.010;
use utf8;
use Mojolicious::Lite;
use Time::Piece;

use MyTodo;

plugin 'Config';
plugin 'haml_renderer';

my $mytodo = MyTodo->new(
    dsn        => app->config->{dsn},
    dbusername => app->config->{dbusername},
    dbpassword => app->config->{dbpassword},
    dbattr     => app->config->{dbattr},
);

get '/' => sub {
    my $self = shift;

    my $todo = $mytodo->list(
        order_by => [ '-me.priority' ],
        search   => [{ status => 'todo' }],
    );

    my $doing = $mytodo->list(
        order_by => [ '-me.priority' ],
        search   => [{ status => 'doing' }],
    );

    my $done = $mytodo->list(
        order_by => [ '-me.priority' ],
        search   => [{ status => 'done' }],
    );

    my $all = $mytodo->list(
        order_by => [ '-me.priority' ],
    );

    $self->render(
        'list',
        todo  => $todo,
        doing => $doing,
        done  => $done,
        all   => $all,
    );
};

get '/detail/:_id' => sub {
    my $self = shift;

    my $id         = $self->param('_id');
    my $item       = $mytodo->_dbix->table('mytodo')->find($id);
    my $created_on = localtime($item->created_on);
    my $updated_on = localtime($item->updated_on);

    $self->render_json({
        content    => $item->content,
        priority   => $item->priority,
        star       => "\x{2605}" x $item->priority . "\x{2606}" x (5 - $item->priority),
        _status    => uc($item->status),
        created_on => $created_on->ymd . ' ' . $created_on->hms,
        updated_on => $updated_on->ymd . ' ' . $updated_on->hms,
    });
};

app->start;

__DATA__

@@ list.html.ep
% layout 'list', navbar => 1, back => 0;
% title 'MyTodo';
<!-- CONTENT -->


@@ layouts/list.html.haml
!!! 5
%html
  %head
    %title= title
    = include 'layouts/default/meta'
    = include 'layouts/default/css'
    = include 'layouts/default/js'

  %body
    = include 'layouts/default/items', id => 'todo',  items => $todo
    = include 'layouts/default/items', id => 'doing', items => $doing
    = include 'layouts/default/items', id => 'done',  items => $done
    = include 'layouts/default/detail'


@@ layouts/default/items.html.ep
<!-- <%= uc $id %> -->
    <div id="<%= $id %>" data-role="page">
      %= include 'layouts/default/header', navbar => 1, new => 1
      <div data-role="content">
        <!-- CONTENT -->
        <div data-role="fieldcontain">
          <ul data-role="listview" data-split-icon="arrow-r">
            % while ( my $item = $items->next ) {
              <li>
                <a href="#" style="padding-top: 0px;padding-bottom: 0px;padding-right: 42px;padding-left: 0px;">
                  <label style="border-top-width: 0px;margin-top: 0px;border-bottom-width: 0px;margin-bottom: 0px;border-left-width: 0px;border-right-width: 0px;" data-corners="false">
                    <fieldset data-role="controlgroup" >
                      <input type="checkbox" name="checkbox-2b" id="checkbox-2b" />
                      <label for="checkbox-2b" style="border-top-width: 0px;margin-top: 0px;border-bottom-width: 0px;margin-bottom: 0px;border-left-width: 0px;border-right-width: 0px;">
                        <label  style="padding:0;">
                          <h3><%= $item->content %></h3>
                        </label>
                      </label>
                    </fieldset>
                  </label>
                </a>
                <a class="slide-reload" href="#detail" id="todo-item-<%= $item->id %>" data-transition="slide">Show details</a>
              </li>
            % }
          </ul>
        </div>
      </div>
      %= include 'layouts/default/footer'
    </div>


@@ layouts/default/detail.html.ep
<!-- DETAIL -->
    <div id="detail" data-role="page" data-add-back-btn="true">
      %= include 'layouts/default/header', navbar => 0, new => 0
      <div data-role="content">
        <h1 class="todo-content"></h1>
        <h2 class="todo-status"></h2>
        <h2 class="todo-priority"></h2>
        <div class="todo-etc"></div>
      </div>
      %= include 'layouts/default/footer'
    </div>


@@ layouts/default/meta.html.haml
/ META
    %meta{:charset => "utf-8"}
    %meta{:name => "author",      content => "Keedi Kim"}
    %meta{:name => "description", content => "MyTodo"}
    %meta{:name => "viewport",    content => "width=device-width, initial-scale=1"}


@@ layouts/default/css.html.ep
<!-- CSS -->
    <link rel="stylesheet" href="http://code.jquery.com/mobile/1.2.0/jquery.mobile-1.2.0.min.css" />


@@ layouts/default/js.html.ep
<!-- Javascript -->
    <script src="http://code.jquery.com/jquery-1.8.2.min.js"></script>
    <script src="http://code.jquery.com/mobile/1.2.0/jquery.mobile-1.2.0.min.js"></script>
    <script>
      $(document).ready(function() {
        $('a.force-reload').live('click', function(e) {
          var url = $(this).attr('href');
          $.mobile.changePage( url, { reloadPage: true, transition: "none"} );
        });
        $('a.slide-reload').live('click', function(e) {
          var url = $(this).attr('href');
          var id  = this.id.replace( /.*todo-item-/, "" );
          $.get(
            '/detail/' + id,
            function(_data) {
              $("#detail .todo-content").text(_data.content);
              $("#detail .todo-status").text(_data._status);
              $("#detail .todo-priority").text(_data.star);
              $("#detail .todo-etc").text('');
              $("#detail .todo-etc").append("<p>created: " + _data.created_on + "</p>");
              $("#detail .todo-etc").append("<p>updated: " + _data.updated_on + "</p>");
            },
            'json'
          );
        });
      });
    </script>


@@ layouts/default/navbar.html.ep
<!-- NAVBAR -->
        <div data-role="navbar">
          <ul>
            <li><a data-transition="none" class="<%= $id eq 'todo'  ? 'ui-btn-active ui-state-persist' : q{} %>" href="#todo">  Todo  </a></li>
            <li><a data-transition="none" class="<%= $id eq 'doing' ? 'ui-btn-active ui-state-persist' : q{} %>" href="#doing"> Doing </a></li>
            <li><a data-transition="none" class="<%= $id eq 'done'  ? 'ui-btn-active ui-state-persist' : q{} %>" href="#done">  Done  </a></li>
          </ul>
        </div>


@@ layouts/default/header.html.ep
<!-- HEADER -->
      <div data-role="header" data-position="fixed">
        % if ($new) {
          <a class="force-reload" href="/" data-icon="refresh">Refresh</a>
        % }
        <h1><%= title %></h1>
        % if ($new) {
          <a href="#" data-icon="plus" class="ui-btn-right">New</a>
        % }
        % if ($navbar) {
          %= include 'layouts/default/navbar'
        % }
      </div>


@@ layouts/default/footer.html.haml
/ FOOTER


@@ xxx.html.ep
    <div data-role="footer" data-position="fixed" class="ui-bar">
        <div data-role="controlgroup" data-type="horizontal">
            <a href="#" data-icon="arrow-u">Up</a>
            <a href="#" data-icon="arrow-d">Down</a>
            <a href="#" data-icon="minus">Remove</a>
        </div>
    </div>

    <div data-role="fieldcontain">
        <input type="text" name="name" id="name" value="" placeholder="What to do next?" />
    </div>

