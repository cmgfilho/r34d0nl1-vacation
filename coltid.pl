#!/opt/perl/5.8.0/bin/perl


BEGIN
{
   my $MPERL= "/opt/perl/5.8.0";

}
require "sybutil.pl";
require "ctime.pl";
require "flush.pl";
use Sybase::DBlib;
use warnings;
use strict;




#my $USERNAME = "acctread";
#my $PASSWORD =  "########";
#my $SERVER = "ACCTS_PROD";


my $USERNAME = "temp_dbo";
my $PASSWORD =  "#########";
my $SERVER = "ACCTS1_DEV";

my $DBNAME = "ActDbAct";
my $dbh;


($dbh = Sybase::DBlib->dblogin($USERNAME, $PASSWORD, $SERVER))
   or die "Login to SERVER failed";
($dbh->dbuse($DBNAME) == &SUCCEED)
   or die "dbcmd error $!\n";
   
   
#my $curr="AAAZ";
#my $next=&get_next_number($curr);
#print $next;

my $start_range='';
my $end_range='';
my $range_count=0;
my $last_status=-1;

while (<>) {
	chomp;
	my $dbSeq=$_;
	
	my $if_seq_used=&isUsed($dbSeq);
	
	if ($if_seq_used == 0) {
		if ($start_range eq '') {
			$start_range=$dbSeq;
		} else {
			$end_range=$dbSeq;
			$range_count++;
		}
	}
	
	
	if ( ($if_seq_used==1) ) {
			if ($range_count > 1) {
				print "start range:\t $start_range \t  end \t  $end_range  \t  total \t $range_count \n";
				$start_range='';
				$end_range='';
				$range_count=0;
			} else {
				$range_count=0;
				$start_range='';
				$end_range='';
			}
	}
		
		#print "actual ($dbSeq) :: start [$start_range] :: end [$end_range] :: if_seq [$if_seq_used]  :: range [$range_count] \n";
}
	



sub isUsed($) {
	my $id=$_[0];
	my $SQL= qq{
		select ActAltI from ActDbAct..ActAltITb where ActAltITyp='COLT' and ActAltI = '$id'
	};
	($dbh->dbcmd($SQL) == &SUCCEED) or die "dbcmd error $! [$SQL]\n";
	($dbh->dbsqlexec == &SUCCEED) or die "dbsqlexec error $! [$SQL] \n";

	my $found=0;
	while($dbh->dbresults != NO_MORE_RESULTS) {
    while(my @data = $dbh->dbnextrow) {
        $found=1;
    }
	}
	return $found;	
}

sub get_next_number($) {
	my $list36 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	my $startSeq=$_[0];	


	print "(actual) : [$startSeq]\n";

	my $char_pos4=substr($startSeq,3,1);
	my $pos4 = index $list36, $char_pos4;
				
	my $char_pos3=substr($startSeq,2,1);
	my $pos3 = index $list36, $char_pos3;
				
				
	my $char_pos2=substr($startSeq,1,1);
	my $pos2 = index $list36, $char_pos2;
				
				
	my $char_pos1=substr($startSeq,0,1);
	my $pos1 = index $list36, $char_pos1;
				
			
#				print "Start seq: [$startSeq]\n";
#				print "positions: char1 [$char_pos1] pos1 [$pos1]\n";
#				print "positions: char2 [$char_pos2] pos2 [$pos2]\n";
#				print "positions: char3 [$char_pos3] pos3 [$pos3]\n";
#				print "positions: char4 [$char_pos4] pos4 [$pos4]\n";

	my $next_char1=$char_pos1;
	my $next_char2=$char_pos2;
	my $next_char3=$char_pos3;
	my $next_char4=$char_pos4;
				
				
	if ($pos4 != 35) {
		$next_char4= substr $list36, $pos4+1, 1;


		} elsif ($pos3 != 35) {

			$next_char3= substr $list36, $pos3+1, 1;
			$next_char4 = substr $list36, 0, 1;

		} elsif($pos2 != 35) {
			$next_char2= substr $list36, $pos2+1, 1;
			$next_char3 = substr $list36, 0, 1;
			$next_char4 = substr $list36, 0, 1;
					
		} elsif ($pos1 != 35) {
			$next_char1= substr $list36, $pos1+1, 1;
					
			$next_char2 = substr $list36, 0, 1;
			$next_char3 = substr $list36, 0, 1;
			$next_char4 = substr $list36, 0, 1;

		} else {
					
			print "end of sequences";
			print "next seq= [". $next_char1 . $next_char2 . $next_char3 . $next_char4 . "]\n";
			return -1;
		}
				
		my $id = $next_char1 . $next_char2 . $next_char3 . $next_char4;
		return $id;	
}
