#!/usr/bin/perl

## Howto
##
##	addRTpatch.pl -n patch_tarball out_xml_file				: creates a new XML file with the list of patches contained in the tarball
##	addRTpatch.pl -a patch_tarball out_xml_file				: appends the list of patches contained in the tarball to an existing list
##
##	The XML file helps to manage the Xenomai and RTAI linux patches. It lists for each of them the set of patches it contains and for 
##	which architecture and kernel version they can be used
##
#########

use Data::Dumper;
use XML::Simple;

## Retrieving the work directory
my $WORKING_DIR = `readlink -f $0`;
$WORKING_DIR = `dirname $WORKING_DIR`;
chomp $WORKING_DIR;

my $rt_patches;
my $xml_file;

if($#ARGV == 2)
{
	if($ARGV[0] eq '-n')
	{
		$rt_patches = {
						'RTextension_version' => []
					  };
		$xml_file = $ARGV[2];
	}
	elsif($ARGV[0] eq '-a')
	{
		my $xml_reader = new XML::Simple(ForceArray => 1);
		$xml_file=$ARGV[2];
		$rt_patches = $xml_reader->XMLin($xml_file);
	}
	else
	{
		die 'Wrong command';
	}
}
else
{
	die 'Wrong number of parameters';
}

## Determine the type of compression
my $tarball = `readlink -f $ARGV[1]`;
if($tarball =~ m/.*\.tar.gz$/)
{
	open(FILE_LIST,"tar -tzf $tarball |");
}
elsif($tarball =~ m/.*\.tar.bz2/)
{
	open(FILE_LIST,"tar -tjf $tarball |");
}
else
{
	die 'This archive is not supported. Please provide a .gz or .bz2 tarball';
}

my @file_list = <FILE_LIST>;
close(FILE_LIST);

## Determine the type of the RT extension
my $extension_type;
if($file_list[0] =~ m/xenomai.*/)
{
	$extension_type = 'Xenomai';
}
elsif($file_list[0] =~ m/rtai.*/)
{
	$extension_type = 'RTAI';
}
else
{
	die 'Please give a valid RT patch';
}

my $rt_extension = {
					'version' => '', 'patch' => []
					};


if($file_list[0] =~ m/.*-(.*)\//)
{
	$rt_extension->{version} = $1;
}

## Checking whether the version already exists
if($ARGV[0] eq '-a')
{
	foreach $rt_version (@{$rt_patches->{RTextension_version}})
	{
		if($rt_version->{version}->[0] eq $rt_extension->{version})
		{
			die 'This version already exists';
		}
	}
}

## Retrieving the patches according to each RT linux extension
if($extension_type eq 'Xenomai')
{
	foreach my $file (@file_list)
	{
		my $patch = {
					'name' => '', 'arch' => '', 'kernel' => ''
				};
		if($file =~ m/.*\/ksrc\/arch\/(\w+)\/patches\/(.*)\.patch/)
		{
			$arch = $1;
			if($1 eq 'ppc'){$arch = 'powerpc';}
			if($1 eq 'i386'){$arch = 'x86';}
			$patch->{arch} = $arch;
			$patch->{name} = $file;
			$patch->{kernel} = $2;
			if($patch->{kernel} =~ s/.*-(\d+\.\d+\.\d+).*/$1/)
			{
				push @{$rt_extension->{patch}},$patch;
			}
		}
	}
}
elsif($extension_type eq 'RTAI')
{
	foreach my $file (@file_list)
	{
		my $patch = {
					'name' => '', 'arch' => '', 'kernel' => ''
				};
		if($file =~ m/.*\/base\/arch\/(\w+)\/patches\/(.*)\.patch/)
		{
			$arch = $1;
			if($1 eq 'ppc'){$arch = 'powerpc';}
			if($1 eq 'i386'){$arch = 'x86';}
			$patch->{arch} = $arch;
			$patch->{name} = $file;
			$patch->{kernel} = $2;
			if($patch->{kernel} =~ s/.*-(\d+\.\d+\.\d+).*/$1/)
			{
				push @{$rt_extension->{patch}},$patch;
			}
		}
	}
}
push @{$rt_patches->{RTextension_version}},$rt_extension;

my $xml_writer = new XML::Simple (NoAttr=>1, XMLDecl=>0, RootName=>"$extension_type".'Patches');
my $data = $xml_writer->XMLout($rt_patches);

#print Dumper($data);
#exit;

## Writing XML
if (! open (XML_FILE, ">$xml_file"))
{
	die "Ensure that the path to the file is correct or that write permission is granted.";
}
$xml_header = "<?xml version='1.0'?>\n";
printf(XML_FILE $xml_header);
printf(XML_FILE $data);
close(XML_FILE);

