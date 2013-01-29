#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Data::Dumper qw(Dumper);
use Test::More;
use Test::Harness;
use Rose::DBx::TestDB;

BEGIN {
    use lib 't/lib';
    use lib 'lib';
}

plan tests => 4;


our $db = Rose::DBx::TestDB->new;

use_ok( 'User' ) || print "Bail out!\n";

my $r = $db->dbh->do(<<EOSQL

CREATE  TABLE "users" (
   "id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
   "name" VARCHAR NOT NULL  UNIQUE , 
   "password" VARCHAR NOT NULL 
);

EOSQL
);

cmp_ok($r,'==','0E0','create testdb ok');

my $username = 'HansTest';
my $password = 'I know';
my $user = User->new(
   db => $db,
   name => $username,
   password => $password,
);
$user->save;

diag Dumper $user if $ENV{HARNESS_VERBOSE};
cmp_ok($user->id,'==',1,'create user in testdb ok');


subtest 'check password' => sub {

   my $cmp_user = User->new(
      name => $username,
   )->load;

     is( $cmp_user->password_is( $password),1,'password matched');
   isnt( $cmp_user->password_is(!$password),1,'password mismatched');

   diag 'change password now';
   $cmp_user->password('Yes I know');
   $cmp_user->save;

     is( $cmp_user->password_is( 'Yes I know'),1,'changed password matched');
   isnt( $cmp_user->password_is(!'Yes I know'),1,'changed password mismatched');

};

done_testing;

__END__
