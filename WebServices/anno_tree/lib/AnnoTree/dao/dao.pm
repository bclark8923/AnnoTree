#!usr/bin/perl

use Crypt::SaltedHash;
use strict;
use warnings;
package dao;


use base 'Class::DBI::mysql';
$data_source = '127.0.0.1'
$user = 'root'
$password = 'password'

  sub new
  {
    __PACKAGE__->connection($data_source, $user, $password, \%attr);
  }

  sub create_user {
    $username = $0;
    $password = create_salted_hash($1);
    $first_name = $2;
    $last_name = $3;
    $email = $4
    $lang = $5;
    $time_zone = $6;
    $profile_image_path = $7;
  }
  
  sub create_salted_hash{
    my $password = $0;
    my $password='password';

    #creating the salted hash
    my $crypt=Crypt::SaltedHash->new(algorithm=>'SHA-512');
    $crypt->add($password);
    my $shash=$crypt->generate();
    return $shash;
    }