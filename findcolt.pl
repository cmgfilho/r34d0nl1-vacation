#!/opt/perl/5.8.0/bin/perl


BEGIN
{
   my $MPERL= "/opt/perl/5.8.0";

}
require "sybutil.pl";
require "ctime.pl";
require "flush.pl";
use Sybase::DBlib;


$USERNAME = "acctread";
$PASSWORD =  "raus030";
$SERVER = "ACCTS_PROD";
$DBNAME = "ActDbAct";


($dbh = Sybase::DBlib->dblogin($USERNAME, $PASSWORD, $SERVER))
   or die "Login to SERVER failed";
($dbh->dbuse($DBNAME) == &SUCCEED)
   or die "dbcmd error $!\n";

open FILE, "<all_valid_numbers.txt" or die $!;

while (<FILE>) {
	chomp;

	my $SQL= qq{
		select ActAltI from ActDbAct..ActAltITb where ActAltITyp='COLT' and ActAltI = '$_'
	};
($dbh->dbcmd($SQL) == &SUCCEED) or die "dbcmd error $! [$SQL]\n";
($dbh->dbsqlexec == &SUCCEED) or die "dbsqlexec error $! [$SQL] \n";

while($dbh->dbresults != NO_MORE_RESULTS) {
    while(@data = $dbh->dbnextrow) {
        print "$data[0]\n";
    }
}

#print $SQL;
}
