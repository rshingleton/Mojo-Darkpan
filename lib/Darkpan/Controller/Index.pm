package Darkpan::Controller::Index;
use v5.20;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use OrePAN2::Indexer;
use Data::Dumper;
use IO::Zlib;
use Darkpan::Util;

sub list($self) {
    my $util = Darkpan::Util->new(controller => $self);

    $self->render(json => $util->list) if ($util->authorized);
}


1;