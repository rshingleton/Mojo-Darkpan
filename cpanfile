requires 'perl', 'v5.20';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

requires "IO::Zlib";
requires "Mojolicious";
requires "Mojolicious::Plugin::BasicAuthPlus";
requires "Moo";
requires "OrePAN2";
