#!/usr/bin/perl -w

use DBI ;
use POSIX qw(strftime);
#use strict ;
$|=1 ;
#$pageview_tb{''}{''}{''} = '' ;
#$ip_range_tb{''}{''} = '' ;

my $dbh;                     # 建立数据库连接
$dbh = DBI->connect("DBI:mysql:web_log_db:localhost", "zixia", "IamZixia!") or die "connect" ;

my $now_string; my @now_string ;
$now_string = strftime "%Y-%m-%d", localtime;      # 取得当前时间 $year,$month,$date,$yesterday
@now_string = split("-", $now_string) ;
my $year;my $month;my $date ;
$year = $now_string[0] ;
$month = $now_string[1] ;
$date = $now_string[2] ;

my $deadline ;
$deadline = strftime "%G-%m-%d %H:00:00", localtime; 

$sth_select_from_access_log_tb = $dbh->prepare(<<_SQL_) or die "prepare" ;
SELECT visitor_ip,host_name,date_time,user_id FROM access_log_tb 
WHERE date_time < '$deadline' order by date_time
_SQL_
$sth_exist_in_pageview_tb = $dbh->prepare ( <<_SQL_ ) or die "prepare" ;
SELECT COUNT(*) FROM pageview_tb
WHERE date_hour=? and product=? and is_chinaren=?
_SQL_
$sth_exist_in_ip_range_tb = $dbh->prepare ( <<_SQL_ ) or die "prepare" ;
SELECT COUNT(*) FROM ip_range_tb
WHERE date_hour=? and net=?
_SQL_

$sth_select_from_access_log_tb->execute or die "execute" ;     # 取得新的 access_log_tb 中的昨天以前的数据

my $visitor_ip;my $host_name;my $date_time;my $date_hour;my $user_id;
while( ($visitor_ip,$host_name,$date_time,$user_id)=$sth_select_from_access_log_tb->fetchrow_array ){
    $visitor_ip =~ s/\.\d+\.\d+$// ;
    $date_time =~ s/:\d+:\d+$/:00:00/ ;
    $date_hour = $date_time ;
    if ( $user_id ){
	$user_id = 'Y' ;
    }else{
	$user_id = 'N' ;
    }
    next if ( !($host_name && $visitor_ip) ) ;
    
    $pageview_tb{$host_name}{$date_hour}{$user_id} ++ ;  #host_name is not include .chinaren.* and user_id is a bool (Y,N)
    $ip_range_tb{$visitor_ip}{$date_hour} ++ ; # $visitor_ip is a b class ip (like 202.112)
}

    &pageview_tb_inc_row ;
    &ip_range_tb_inc_row ;
#!!!!!!!!!!


$sth_exist_in_pageview_tb->finish ;
$sth_exist_in_ip_range_tb->finish ;
$dbh->do("DELETE FROM access_log_tb WHERE date_time < '$deadline'") or die "do" ;
$dbh->disconnect ;
exit 0 ;
########

sub ip_range_tb_inc_row
{
    my $date_hour ;
    local ( $net ) ;
    local ( $i,$j,$k ) ;
 
	foreach $net ( keys %ip_range_tb ){
		foreach $date_hour ( keys %{$ip_range_tb{$net}} ){
			$k = $ip_range_tb{$net}{$date_hour} ;
    		$sth_exist_in_ip_range_tb->execute($date_hour,$net) or die "execute" ;
    		$i = $sth_exist_in_ip_range_tb->fetchrow_array ;
    		if ( 0==$i ){
				$dbh->do("INSERT INTO ip_range_tb (date_hour,net,num_chinaren) values ('$date_hour','$net','$k')") or die "do" ;
	    	}else{
				$sth = $dbh->prepare("SELECT num_chinaren FROM ip_range_tb WHERE date_hour='$date_hour' and net='$net'" ) or die "prepare" ;
				$sth->execute or die "execute" ;
				$j = $sth->fetchrow_array or die "fetchrow_array" ;
				$sth->finish ;
				$j += $k ;
				$dbh->do("UPDATE ip_range_tb set num_chinaren='$j' WHERE date_hour='$date_hour' and net='$net'" ) or die "do" ;
    		}
    	}
    }
	
}

sub pageview_tb_inc_row
{
    my $date_hour ;
    local ( $product,$is_chinaren ) ;
    my $i;my $j;my $k ;

	foreach $product ( keys %pageview_tb ){
		foreach $date_hour ( keys %{$pageview_tb{$product}} ){
			foreach $is_chinaren ( keys %{$pageview_tb{$product}{$date_hour}} ){
				$k = $pageview_tb{$product}{$date_hour}{$is_chinaren} ;
    			$sth_exist_in_pageview_tb->execute($date_hour,$product,$is_chinaren) or die "execute" ;
    			$i = $sth_exist_in_pageview_tb->fetchrow_array ;
    			if ( 0 == $i ){
						$dbh->do("INSERT INTO pageview_tb (date_hour,product,is_chinaren,num_chinaren) values ('$date_hour','$product','$is_chinaren','$k')") or die "do" ;
    			}else{
					$sth = $dbh->prepare("SELECT num_chinaren FROM pageview_tb WHERE date_hour='$date_hour' and product='$product' and is_chinaren='$is_chinaren'" ) or die "prepare" ;
					$sth->execute or die "execute" ;
					$j = $sth->fetchrow_array or die "fetchrow_array" ;
					$sth->finish ;
					$j+=$k ;
					$dbh->do("UPDATE pageview_tb set num_chinaren='$j' WHERE date_hour='$date_hour' and product='$product' and is_chinaren='$is_chinaren'" ) or die "do" ;
				}
			}
		}
    }
}

