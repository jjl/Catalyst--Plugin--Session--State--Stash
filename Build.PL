use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Catalyst::Plugin::Session::State::Stash',
    license             => 'perl',
    dist_author         => "James Laver <perl -e 'print sprintf(qw/%s@%s.com cpan jameslaver/);'>",
    dist_version_from   => 'lib/Catalyst/Plugin/Session/State/Stash.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Catalyst-Plugin-Session-State-Stash-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
