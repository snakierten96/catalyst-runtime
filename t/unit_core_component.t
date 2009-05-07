use Test::More tests => 11;
use strict;
use warnings;

use_ok('Catalyst');

my @complist = map { "MyApp::$_"; } qw/C::Controller M::Model V::View/;

{
  package MyApp;

  use base qw/Catalyst/;

  __PACKAGE__->components({ map { ($_, $_) } @complist });

  # this is so $c->log->warn will work
  __PACKAGE__->setup_log;
}

is(MyApp->comp('MyApp::V::View'), 'MyApp::V::View', 'Explicit return ok');

is(MyApp->comp('C::Controller'), 'MyApp::C::Controller', 'Two-part return ok');

is(MyApp->comp('Model'), 'MyApp::M::Model', 'Single part return ok');

# regexp fallback
{
    my $warnings = 0;
    no warnings 'redefine';
    local *Catalyst::Log::warn = sub { $warnings++ };

    is(MyApp->comp('::M::'), 'MyApp::M::Model', 'Regex return ok');
    ok( $warnings, 'regexp fallback for comp() warns' );
}

is_deeply([ MyApp->comp() ], \@complist, 'Empty return ok');

# Is this desired behaviour?
is_deeply([ MyApp->comp('Foo') ], \@complist, 'Fallthrough return ok');

# regexp behavior
{
    is_deeply( [ MyApp->comp( qr{Model} ) ], [ 'MyApp::M::Model'], 'regexp ok' );
}

# multiple returns
{
    my @expected = qw( MyApp::C::Controller MyApp::M::Model );
    is_deeply( [ MyApp->comp( qr{::[MC]::} ) ], \@expected, 'multiple results fro regexp ok' );
}

# failed search
{
    is_deeply( scalar MyApp->comp( qr{DNE} ), 0, 'no results for failed search' );
}

