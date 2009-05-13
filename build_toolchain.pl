#!/usr/bin/perl

## Howto
##
##	build_toolchain.pl xml_config_file user_name
##
##	xml_config_file		:	an xml_config_file of a toolchain
##	user_name			:	the name of the user that requested the cross toolchain to be built
##
##	This file builds a crosstool-ng toolchain using a reduced number of parameters given within an xml configuration file
##
#########


use DBI;

## Retrieving the work directory
my $WORKING_DIR = `readlink -f $0`;
$WORKING_DIR = `dirname $WORKING_DIR`;
chomp $WORKING_DIR;

if($#ARGV == 1)
{
	$xml_config_file = $ARGV[0];
	if( -f $xml_config_file)
	{}
	else
	{
		die 'The config file does not exist';
	}
	$user_name = $ARGV[1];
	if( -d "$WORKING_DIR/home/$user_name")
	{}
	else
	{
		die 'This user does not exist';
	}
}
else
{
	die 'Wrong number of parameters';
}
if($xml_config_file =~ m/.*\/(.*)\.xml$/)
{
	$xml_file_name = $1;
}

$DIR_CROSSTOOL_NG="crosstool-ng-1.3.2";
$DIR_TARBALLS="tarballs";
$DIR_USER_TOOLCHAINS="user_toolchains";


chdir "$WORKING_DIR/$DIR_CROSSTOOL_NG";

## Copying sstrip with the correct name in the src directory to avoid a bug in crosstool-ng
system ("mkdir -p targets/src/sstrip");
system("cp ../tarballs/sstrip.c targets/src/sstrip/");


## Generating the .config file from the xml config file and modifying some parameters
system("perl ../xml2config.pl $xml_config_file");
my $sed_script = "sed -i '";
$sed_script = "$sed_script" . "s,CT_LOCAL_TARBALLS_DIR=.*,CT_LOCAL_TARBALLS_DIR=\"$WORKING_DIR/$DIR_TARBALLS\",;";
$sed_script = "$sed_script" . "s,CT_INSTALL_DIR_RO=.*,# CT_INSTALL_DIR_RO is not set,;";
$sed_script = "$sed_script" . "s,CT_PREFIX_DIR=.*,CT_PREFIX_DIR=\"$WORKING_DIR/$DIR_USER_TOOLCHAINS/$xml_file_name\",' .config";
system($sed_script);

## Building the toolchain
$res = system("./ct-ng build");


my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)  = localtime(time);
my $date_fin = "$mday/".($mon+1)."/$year";
if($res == 0)
{
	$status = 'Chaine prête';
	#system("cp $WORKING_DIR/home/$user_name/mytoolchains/$xml_file_name.xml $WORKING_DIR/config-toolchains");
}
else
{
	$status = 'Echec de la génération';
}

$dsn   = "dbi:mysql:vlab";
$login = "apache";
$mdp   = "myvlab";

$dbh = DBI->connect($dsn, $login, $mdp) or die "Connection failure\n";

$request = "update toolchain set statut='$status', date_fin='$build_date' where name='$xml_file_name'";
$sth = $dbh->prepare($request);
$sth->execute();


## Cleaning up the source and build files
Clean:
#system("./ct-ng distclean");
