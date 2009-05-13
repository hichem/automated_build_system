#!/usr/bin/perl

## Howto
##
##	adduser.pl add -u username								: creates a home directory for the user username
##	adduser.pl del -u username								: removes the home directory of the user
##	adduser.pl add -p username project						: creates a project directory for the user
##	adduser.pl del -p username project						: removes the project directory
##	adduser.pl add -c username project configuration		: creates a configuration directory for the project
##	adduser.pl del -c username project configuration		: removes the configuration directory
##
#########

use XML::Simple;


$DIR_TARBALLS="tarballs";
$CROSSTOOL_NG="crosstool-ng-1.3.2.tar.bz2";
$DIR_CROSSTOOL_NG="crosstool-ng-1.3.2";
$DIR_TOOLCHAINS="toolchains";
$DIR_CONFIG_TOOLCHAINS="config-toolchains";

my $WORK_DIR = `readlink -f $0`;
$WORK_DIR = `dirname $WORK_DIR`;
chomp $WORK_DIR;

chdir "$WORK_DIR";

if (system("tar -xvjf $CROSSTOOL_NG") !=0 )
{
	die "Impossible d'extraire l'archive. Vérifiez qu'elle existe ou que vous avez les droits d'écritures dans le dossier courant";
}
chdir "$DIR_CROSSTOOL_NG";

# Installation de crosstool-ng dans le même répertoire

system("./configure --local");
system("make");
system("make install");

# By default crosstool-ng dosen't install correctly sstrip, we have to fix that by hand
system("mkdir targets/src/sstrip");
system("cp ../tarballs/sstrip.c targets/src/sstrip/");



# Get and install all the preconfigured toolchains

if ( -d $DIR_TOOLCHAINS)
{}
else
{
	system("mkdir $DIR_TOOLCHAINS");
}

open(RESULT,"./ct-ng list-samples|");
@TOOLCHAINS=<RESULT>;
close(RESULT);

my $build_result;

for (my $i=0; $i <= $#TOOLCHAINS; $i+=1)
{
	$config = $TOOLCHAINS[$i];
	
	## Configuring and building the toolchain	
	system("./ct-ng $config");
	my $sed_script = "sed -i '";
	$sed_script = "$sed_script" . "s,CT_LOCAL_TARBALLS_DIR=.*,CT_LOCAL_TARBALLS_DIR=\"$WORK_DIR/$DIR_TARBALLS\",;";
	$sed_script = "$sed_script" . "s,CT_INSTALL_DIR_RO=.*,# CT_INSTALL_DIR_RO is not set,;";
	$sed_script = "$sed_script" . "s,CT_PREFIX_DIR=.*,CT_PREFIX_DIR=\"$WORK_DIR/$DIR_TOOLCHAINS/\${CT_TARGET}\",' .config";
	system($sed_script);
	#$build_result = system("./ct-ng build");

	## Saving toolchain information to XML config file
	if($build_result == 0)
	{
		system("perl ../config2xml.pl .config ../$DIR_CONFIG_TOOLCHAINS");
	}		
}

## Cleaning up the source and build files
system("./ct-ng distclean");
