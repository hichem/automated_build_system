#!/usr/bin/perl

## Howto
##
##	build_system.pl arch toolchain kernel_version kernel_config kernel_patch project_dir
##
##	arch			: the target architecture
##	toolchain		: the toolchain name in the standard format	[arch-manufacturer-kernel-os]
##	kernel_version	: the kernel version
##	kernel_config	: the kernel config file
##	kernel_patch	: the RT patch to apply to the kernel
##	project_dir		: the user directory to which kernel and rootfs images and test results are copied
##
##	This file gathers all the necessary parameters to build and simulate a minimal linux system. It prepares
##	a miniroot configuration file and launches qemu with the adequate options
##
#########

use DBI;

## Retrieving the work directory
my $WORK_DIR = `readlink -f $0`;
$WORK_DIR = `dirname $WORK_DIR`;
chomp $WORK_DIR;
$MINIROOT_DIR = '/home/hichem/modified_miniroot';
$TOOLCHAINS_DIR = "$WORK_DIR/toolchains";
$USER_TOOLCHAINS_DIR = "$WORK_DIR/user_toolchains";
$NFS_SHARE = "$WORK_DIR/nfs_share";

if($#ARGV != 5)
{
	die 'Wrong number of a parameters.';
}

## Parameters passed through a PHP script
my $arch = $ARGV[0];
my $toolchain = $ARGV[1];
my $kernel_version = $ARGV[2];
my $kernel_config = $ARGV[3];
my $patch = $ARGV[4];
my $project_dir = $ARGV[5];

## Guess the type of the RT extension through the patch
my $rt_extension = $patch;
$rt_extension =~ s/(.*)(\/.*){4}\/.*/$1/;

my $extension_type;
if($rt_extension =~ m/xenomai.*/)
{
	$extension_type = 'xenomai';
}
elsif($rt_extension =~ m/rtai.*/)
{
	$extension_type = 'rtai';
}
elsif($rt_extension eq 'none')
{
	$extension_type = 'none';
}
else
{
	$extension_type = 'preempt-rt';
}

## Get the tarballs
my @tarballs = <$WORK_DIR/tarballs/*>;

my @res;
my $rt_tarball;
if($extension_type ne 'none')
{
	@res = grep(/$rt_extension/, @tarballs);
	if($#res != -1)
	{
		$rt_tarball = $res[0];
	}
	else
	{
		die "There is no tarballs that correspond to $rt_extension";
	}
}
else
{
	$rt_tarball = '';
}

@res = grep(/linux-$kernel_version/, @tarballs);
my $linux_tarball;
if( $#res != -1)
{
	$linux_tarball = $res[0];
}
else
{
	die "There is no tarballs that correspond to linux version $kernel_version";
}

my $busybox_tarball ="$WORK_DIR/tarballs/busybox-1.13.2.tar.bz2";
if( ! -f $busybox_tarball)
{
	die "The $busybox_tarball does not exist";
}

## Get the toolchain
my $toolchain_prefix = "$toolchain" . "-";
my $toolchain_path;

if( -d "$WORK_DIR/toolchains/$toolchain")
{
	$toolchain_path = "$WORK_DIR/toolchains/" . "$toolchain";
}
else
{
	if( -d "$WORK_DIR/user_toolchains/$toolchain")
	{
		$toolchain_path = "$WORK_DIR/user_toolchains/" . "$toolchain";
	}
	else
	{
		die "The toolchain $toolchain does not exist";
	}
}

chdir $MINIROOT_DIR;

## Xenomai configuration parameters
my %xenomai_arch_config = ( "x86"		=> "--enable-x86-sep",
							"powerpc"	=> "--build=i686-pc-linux-gnu --host=ppc-unknown-linux-gnu",
							"ia64"		=> "--build=i686-pc-linux-gnu --host=ia64-unknown-linux-gnu",
							"arm"		=> "--host=arm-unknown-linux-gnu --enable-arm-mach=generic --enable-arm-tsc"
							);

## Prepare the config file
print "Preparing the config file";
if($extension_type ne 'preempt-rt')
{
	$patch =~ s/$rt_extension\/(.*)/$1/;
}

$sed_script = "sed -i '";
$sed_script = "$sed_script" . "s,TARGET_ARCH =.*,TARGET_ARCH = $arch,;";
$sed_script = "$sed_script" . "s,TOOLCHAIN_PATH =.*,TOOLCHAIN_PATH = $toolchain_path,;";
$sed_script = "$sed_script" . "s,TOOLCHAIN_PREFIX =.*,TOOLCHAIN_PREFIX = $toolchain_prefix,;";
$sed_script = "$sed_script" . "s,LINUX_SRC =.*,LINUX_SRC = $linux_tarball,;";
$sed_script = "$sed_script" . "s,LINUX_CONFIG =.*,LINUX_CONFIG = ${kernel_config},;";
if($extension_type ne 'none')
{
	$sed_script = "$sed_script" . "s,RT_EXTENSION =.*,RT_EXTENSION = $extension_type,;";
}
$sed_script = "$sed_script" . "s,RT_EXTENSION_SRC =.*,RT_EXTENSION_SRC = $rt_tarball,;";
if($extension_type eq 'preempt-rt')
{
	$sed_script = "$sed_script" . "s,RT_LINUX_PATCH =.*,RT_LINUX_PATCH = $rt_tarball,;";
}
else
{
	$sed_script = "$sed_script" . "s,RT_LINUX_PATCH =.*,RT_LINUX_PATCH = $patch,;";
}
if($extension_type eq 'xenomai')
{
	$sed_script = "$sed_script" . "s,RT_ARCH_CONFIG =.*,RT_ARCH_CONFIG = $xenomai_arch_config{$arch},;";
}
$sed_script = "$sed_script" . "s,BUSYBOX_SRC =.*,BUSYBOX_SRC = $busybox_tarball,;";
$sed_script = "$sed_script" . "' config.mk";

system("cp config-template.mk config.mk");
$res = system($sed_script);
if($res == 0)
{
	print "Config file created successfully\n";
}
else
{
	die "Failed to generate config file\n";
}

## Building the system (kernel + root filesystem)
print "Building the system (kernel + root filesystem)\n";
system("cp $kernel_config $MINIROOT_DIR ; cp $kernel_config $project_dir");
$res = system("make clean ; make");
system("rm $MINIROOT_DIR/*_defconfig");
if($res != 0)
{
	die "There is some build problems\n";
}

## Copying the kernel images to the project directory and the root file system to an nfs share
print "Copying the kernel images and root filesystem\n";
my $linux_build_dir = $linux_tarball;
$linux_build_dir =~ s/$WORK_DIR\/tarballs\/(.*)\.tar.*/$1/;

my @kernel_images = <$MINIROOT_DIR/build/$linux_build_dir/arch/$arch/boot/*Image>;
foreach $image (@kernel_images)
{
	system("cp $image $project_dir");
}

my $rootfs_dir = "$MINIROOT_DIR/build/root";
system("rm -rf $NFS_SHARE/* ; cp -a $rootfs_dir/* $NFS_SHARE");

## QEMU Simulation
print "QEMU Simulation";
my %qemu_programs = ( "x86"		=> "qemu",
					  "x86_64"	=> "qemu-system-x86_64",
					  "sh"		=> "qemu-system-sh4",
					  "arm"		=> "qemu-system-arm",
					  "mips"	=> "qemu-system-mips",
					  "powerpc"	=> "qemu-system-ppc");
my $qemu = $qemu_programs{$arch};
system("$qemu -kernel $project_dir/bzImage -hda /home/hichem/qemu_rootfs.img");
