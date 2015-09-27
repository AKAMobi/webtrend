#!/usr/bin/perl -w
use DBI ;

$dbh = DBI->connect ( "DBI:mysql:test:localhost", 'root' ) or die "connect" ;
$sth = $dbh->prepare ( q{
SELECT DISTINCT date_hour 
FROM pageview_tb
WHERE date_hour < '1999-2-1'
} ) or die "prepare" ;
$sth->execute ;
while ( $old_date = $sth->fetchrow_array ){
	$old_date =~ /\d+-(.+$)/ ;
	$date = "2000-$1" ;
	print "$old_date=>$date\n" ;
	#last ;
}
