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
##	This script manages the home directories of users that will use the Vlab
##
#########


## Retrieving the work directory
my $WORKING_DIR = `readlink -f $0`;
$WORKING_DIR = `dirname $WORKING_DIR`;
chomp $WORKING_DIR;

my $user_name;
my $home = "/var/www/html/home";

if(($#ARGV == 2) && ($ARGV[1] eq '-u'))
{
	$user_name = $ARGV[2];
	$home = "$home" . "/" . "$user_name";
	if($ARGV[0] eq 'add')
	{		
		if(system("mkdir -p $home $home/projects $home/mytoolchains") != 0)
		{
			die 'Can\'t create the folders. Check the write permissions please.';
		}
	}
	elsif($ARGV[0] eq 'del')
	{
		if(system("rm -rf $home") != 0)
		{
			die 'Can\'t remove the folders. Check the write permissions please.';
		}
	}
	else
	{
		die 'Wrong parameters';
	}
}
elsif(($#ARGV == 3) && ($ARGV[1] eq '-p'))
{
	$user_name = $ARGV[2];
	$project = $ARGV[3];
	$project_dir = "$home" . "/" . "$user_name" . "/projects/" . "$project";
	if($ARGV[0] eq 'add')
	{
		if(system("mkdir $project_dir") != 0)
		{
			die 'Can\'t create the folders. Check the write permissions please.';
		}
	}
	elsif ($ARGV[0] eq 'del')
	{
		if(system("rm -rf $project_dir") != 0)
		{
			die 'Can\'t remove the folders. Check the write permissions please.';
		}
	}
	else
	{
		die 'Wrong parameters';
	}
}
elsif(($#ARGV == 3) && ($ARGV[1] eq '-t') && ($ARGV[0] eq 'del'))
{
	$user_name = $ARGV[2];
	$toolchain = $ARGV[3];
	if(system("rm -rf $home/$user_name/mytoolchains/$toolchain.xml") != 0)
	{
		die 'Can\'t remove the file. Check the write permissions please.';
	}
}
elsif (($#ARGV == 4) && ($ARGV[1] eq '-c'))
{
	$user_name = $ARGV[2];
	$project = $ARGV[3];
	$configuration = $ARGV[4];
	$config_dir = "$home" . "/" . "$user_name" . "/projects/" . "$project" . "/" . "$configuration";
	if($ARGV[0] eq 'add')
	{
		if(system("mkdir $config_dir") != 0)
		{
			die 'Can\'t create the folders. Check the write permissions please.';
		}
	}
	elsif($ARGV[0] eq 'del')
	{
		if(system("rm -rf $config_dir") != 0)
		{
			die 'Can\'t remove the folders. Check the write permissions please.';
		}
	}
	else
	{
		die 'Wrong parameters';
	}
}
else
{
	die'Wrong number of parameters';
	exit(1);
}
