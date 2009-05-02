use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Catalyst::Plugin::Session::State::Stash',
    license             => 'perl',
    dist_author         => "James Laver <perl -e 'printf(qw/%s@%s.com cpan jameslaver/);'>",
    dist_version_from   => 'lib/Catalyst/Plugin/Session/State/Stash.pm',
    build_requires => {
        'Test::More' => 0,
        'Test::MockObject' => 0,
        'Test::WWW::Mechanize::Catalyst' => 0,
        'URI::Escape' => 0,
    },
    requires => {
        'MRO::Compat' => 0,
        'Catalyst::Plugin::Session::State' => 0,
        'Class::Accessor::Fast' => 0,
    },
    add_to_cleanup      => [ 'Catalyst-Plugin-Session-State-Stash-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
