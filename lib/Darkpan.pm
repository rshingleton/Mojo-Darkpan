package Darkpan;
use v5.20;
use Data::Dumper;
use FindBin;
use Mojo::Base 'Mojolicious', -signatures;
use Darkpan::Config;

sub startup($self) {
    # https://metacpan.org/pod/Mojolicious::Plugin::BasicAuthPlus
    $self->plugin('basic_auth_plus');
    $self->plugin('DirectoryHandler',
        delivery_path => Darkpan::Config->new->path);

    #----------
    # Router
    #----------
    my $r = $self->routes;
    my $index = $r->any('/');
    # $index->get('/')->to(controller => 'index', action => 'index');
    $index->get('/list')->to(controller => 'index', action => 'list');

    my $uploader = $r->any('/publish');
    $uploader->post('/')->to(controller => 'publish', action => 'upload');

}

our $VERSION = "0.01";

1;
__END__

=encoding utf-8

=head1 NAME

Darkpan - A Mojolicious web service frontend leveraging OrePAN2

=head1 DESCRIPTION

Darkpan is a webservice build on Mojolicious to frontend L<OrePAN2|https://metacpan.org/pod/OrePAN2>. This module was inspired
by L<OrePAN2::Server|https://metacpan.org/pod/OrePAN2::Server'> but built on 
Mojolicious to take advantage of it's robust framework of tools. A good bit of the documentation
was also taken from OrePAN2::Server as the functionality is similar if not identical.

=head1 SYNOPSIS

=head2 Running the server

    # start a server with default configurations on port 8080
    darkpan --port 8080
    
    # start a server with AD backed basic auth
    # config.json
    {
      "basic_auth": {
        "Realm Name": {
          "host": "ldaps://my.ldap.server.org",
          "port": 636,
          "basedn": "DC=my,DC=compoany,DC=org",
          "binddn": "bind_name",
          "bindpw": "bond_pw",
          "filter": "(&(objectCategory=*)(sAMAccountName=%s)(|(objectClass=user)(objectClass=group)))"
        }
      }
    }
    
    darkpan --config ./config.json

=head4 Options:

=over 2

=item B<-c,--config> I<default: undef>: 
    JSON configuration file location

=item B<-p,--port> I<default: 3000>: 
    Web application port

=back 

=head2 Configuring the server

Configurations can be done using environment variables or by creating a json config file.

=head3 environment variables

Environment variables are at a higher order than values set in the json configuration 
file and will take precedence if set. The B<DARKPAN_CONFIG_FILE> env variable can be 
set instead of using the command line option to denote the path of the config file.

=over 2

=item B<DARKPAN_CONFIG_FILE>: 
    Location of a json configuration file, same as passing the --config option

=item B<DARKPAN_DIRECTORY>:
     Directory where uploads will be stored.

=item B<DARKPAN_PATH>:
    URL path to function as cpan repository resolver/mirror endpoint.
    
=item B<DARKPAN_COMPRESS_INDEX>:
    Setting whether to compress (gzip) the 02packages.details.txt file.

=item B<DARKPAN_AUTH_REALM>:
    Basic auth realm name. This variable needs to be set to enable parsing of additional
    auth settings using the following the format DARKPAN_AUTH_[setting].
    
=item B<DARKPAN_AUTH_[setting]>:
    Additional basic auth settings can be passed using this format. The settings
    will be parsed and applied to your basic auth configurations. See
    L<Mojolicious::Plugin::BasicAuthPlus|https://metacpan.org/pod/Mojolicious::Plugin::BasicAuthPlus> 
    for additional details on configurations.

=back

=head3 config.json

The config.json file contains customizations for the darkpan web application. It can be
referenced by absolute path or relative to where the application is run from.

    {
      "directory": "darkpan",
      "compress_index": true,
      "path": "darkpan,
      "basic_auth": {
        "Realm Name": {
          "host": "ldaps://my.ldap.server.org",
          "port": 636,
          "basedn": "DC=my,DC=compoany,DC=org",
          "binddn": "bind_name",
          "bindpw": "bond_pw",
          "filter": "(&(objectCategory=*)(sAMAccountName=%s)(|(objectClass=user)(objectClass=group)))"
        }
      }
    }

=head4 config.json options

=over 2

=item B<directory> I<default: darkpan>: 
    Directory where uploads will be stored.

=item B<path> I<default: darkpan>: 
    URL path to function as cpan repository resolver/mirror endpoint.

=item B<compress_index> I<default: true>: 
    Setting whether to compress (gzip) the 02packages.details.txt file.

=item B<basic_auth> I<default: undef>: 
    Basic authentication settings, see configurations for L<Mojolicious::Plugin::BasicAuthPlus|https://metacpan.org/pod/Mojolicious::Plugin::BasicAuthPlus>. When not provided
    no authentication is necessary to post modules to the service.

=back

=head3 Authentication

Authentication is handled by L<Mojolicious::Plugin::BasicAuthPlus|https://metacpan.org/pod/Mojolicious::Plugin::BasicAuthPlus>.
To configure basic auth, see the configuration options for L<Mojolicious::Plugin::BasicAuthPlus|https://metacpan.org/pod/Mojolicious::Plugin::BasicAuthPlus>
and add your settings to the basic auth section of the config.json file.     

=head2 How to Deploy 

=head3 Deploying with POST

Publishing to darkpan can be done using a post request and a URL to git or bitbucket repo.
    
    #upload git managed module to my darkpan by curl 
    curl --data-urlencode 'module=git@github.com:Songmu/p5-App-RunCron.git' --data-urlencode 'author=SHINGLER' http://localhost:3000/publish
    curl --data-urlencode 'module=git+ssh://git@mygit/home/git/repos/MyModule.git' --data-urlencode 'author=SHINGLER' http://localhost:3000/publish
    curl --data-urlencode 'module=git+file:///home/hirobanex/project/MyModule.git' --data-urlencode 'author=SHINGLER' http://localhost:3000/publish

=head3 Deploying with L<Minilla|https://metacpan.org/pod/Minilla>

Minilla is a cpan authoring tool, see L<Minilla|https://metacpan.org/pod/Minilla> for more details.

=head4 minil.toml

Add a reference to a pause configruation file in your minil.toml that points to your darkpan instance. 
The configuration can reference a relative path as follows:
    
    [release]
    pause_config=".pause"

=head4 .pause file

The .pause file is a configuration file for uploading modules to CPAN or your own Darkpan Repository.
See L<CPAN::Uploader|https://metacpan.org/pod/CPAN::Uploader> for more detail.

    upload_uri http://my-darkpan.server/publish
    user myUsername
    password myPassword
    
I<** if you don't set the upload_uri, you will upload to CPAN>

If basic auth is enabled, the username and password set in the .pause file will be
used as basic auth credentials.
 
=head1 LICENSE

Copyright (C) shingler.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

shingler E<lt>shingler@oclc.orgE<gt>

=cut

