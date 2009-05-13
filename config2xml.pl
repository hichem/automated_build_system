#!/usr/bin/perl

## Howto
##
##	config2xml.pl config_file xml_file
##	
##	config_file		: the name of a crosstool-ng config file
##	xml_file		: the name of the xml output file (containing a reduced number of parameters)
##
##	This file parses a formal crosstool-ng configuration file into an xml file containing less number of parameters. This file can be used in
##	conjunction with an xsl file to display easily these parameters on a web interface
##
#########

use XML::Simple;

if($#ARGV >= 2)	## the script takes two arguments. The second is optional and it designates the directory to which the output file is saved
{
	die 'Wrong number of parameters';
}

if ( !open (CONF, $ARGV[0]))	# the first parameter is the config file
{
	die "Wrong path or check the read permission."
}
my @config_file = <CONF>;
close(CONF);

my $toolchain_config = {
					'target_options' => {'target_arch' => '', 'target_variant' => '', 'abi' => '', 'endiannes' => '', 'float' => ''},
					'toolchain_options' => {'sysroot' => '', 'build_shared_lib' => '', 'manufacturer' => ''},
					'os' => {'target_os' => '', 'kernel_version' => ''},
					'gmp_mpfr' => {'use_gmp_mpfr' => '', 'gmp_version' => '', 'mpfr_version' => ''},
					'binutils' => {'binutils_version' => '', 'libbfd' => '', 'libiberty' => ''},
					'cc' => {'gcc_version' => '', 'cpp' => '', 'fortran' => '', 'java' => ''},
					'clib' => {'libc' => '', 'clib_version' => '', 'threading_lib' => ''},
					'tools' => {'libelf' => '', 'sstrip' => ''},
					'debug' => {'duma' => '', 'dmalloc' => '', 'gdb' => '', 'ltrace' => '', 'strace' => ''},
					};

my @res;

## Target options

@res=grep(/^CT_ARCH=/, @config_file);
if($res[0] =~ m/^CT_ARCH="(\w+)"/)
{
	$toolchain_config->{target_options}->{target_arch} = $1;
}

$arch = $toolchain_config->{target_options}->{target_arch};
$arch = "\U$arch";

if(("\L$arch" eq 'alpha')||("\L$arch" eq 'sh'))
{
	@res=grep(/^CT_ARCH_${arch}_VARIANT=/, @config_file);
	if($res[0] =~ m/^CT_ARCH_${arch}_VARIANT="(\w+)"/)
	{
		$toolchain_config->{target_options}->{target_variant} = $1;
	}
	else
	{
		$toolchain_config->{target_options}->{target_variant} = 'none';
	}
}
else
{
	@res=grep(/^CT_ARCH_ARCH=/, @config_file);
	if($res[0] =~ m/^CT_ARCH_ARCH="(.+)"/)
	{
		$toolchain_config->{target_options}->{target_variant} = $1;
	}
	else
	{
		$toolchain_config->{target_options}->{target_variant} = 'none';
	}
}

@res=grep(/^CT_ARCH_[LB]E=/, @config_file);
if($res[0] =~ m/^CT_ARCH_([LB])E=y/)
{
	if($1 eq 'L')
	{
		$toolchain_config->{target_options}->{endiannes} = 'little';
	}
	else
	{
		$toolchain_config->{target_options}->{endiannes} = 'big';
	}
}
else
{
	$toolchain_config->{target_options}->{endiannes} = 'none';
}

@res=grep(/^CT_ARCH_FLOAT_[HS]W=/, @config_file);
if($res[0] =~ m/^CT_ARCH_FLOAT_([HS])W=y/)
{
	if($1 eq 'H')
	{
		$toolchain_config->{target_options}->{float} = 'hardware';
	}
	else
	{
		$toolchain_config->{target_options}->{float} = 'software';
	}
}
else
{
	$toolchain_config->{target_options}->{float} = 'none';
}

@res=grep(/^CT_ARCH_SUPPORT_ABI.*/, @config_file);
if($res[0] =~ m/^CT_ARCH_SUPPORT_ABI=y.*/)
{
	$toolchain_config->{target_options}->{abi} = 'abi';
}
else
{
	@res=grep(/^CT_ARCH_${arch}_EABI.*/, @config_file);
	if($res[0] =~ m/^CT_ARCH_${arch}_EABI=y.*/)
	{
		$toolchain_config->{target_options}->{abi} = 'eabi';
	}
	else
	{
		$toolchain_config->{target_options}->{abi} = 'none';
	}
}

## Toolchain options

@res=grep(/^CT_USE_SYSROOT=/, @config_file);
if($res[0] =~ m/^CT_USE_SYSROOT=y/)
{
	$toolchain_config->{toolchain_options}->{sysroot} = 'yes';
}
else
{
	$toolchain_config->{toolchain_options}->{sysroot} = 'no';
}
@res=grep(/^CT_SHARED_LIBS=/, @config_file);
if($res[0] =~ m/^CT_SHARED_LIBS=y/)
{
	$toolchain_config->{toolchain_options}->{build_shared_lib} = 'yes';
}
else
{
	$toolchain_config->{toolchain_options}->{build_shared_lib} = 'no';
}
@res=grep(/^CT_TARGET_VENDOR=/, @config_file);
if($res[0] =~ m/^CT_TARGET_VENDOR="(\w+)"/)
{
	$toolchain_config->{toolchain_options}->{manufacturer} = $1;
}
else
{
	$toolchain_config->{toolchain_options}->{manufacturer} = 'unknown';
}

## Operating system
@res=grep(/^CT_KERNEL=/, @config_file);
if($res[0] =~ m/^CT_KERNEL="(.+)"/)
{
	$toolchain_config->{os}->{target_os} = $1;
}
@res=grep(/^CT_KERNEL_VERSION=/, @config_file);
if($res[0] =~ m/^CT_KERNEL_VERSION="(.*)"/)
{
	$toolchain_config->{os}->{kernel_version} = $1;
}

## GMP and MPFR
	## il faut voir si GMP et MPFR sont utilisés
@res=grep(/^CT_GMP_MPFR=/, @config_file);
if($res[0] =~ m/^CT_GMP_MPFR=y/)
{
	$toolchain_config->{gmp_mpfr}->{use_gmp_mpfr} = 'yes';
	@res=grep(/^CT_GMP_VERSION=/, @config_file);
	if($res[0] =~ m/^CT_GMP_VERSION="(.*)"/)
	{
		$toolchain_config->{gmp_mpfr}->{gmp_version} = $1;
	}
	@res=grep(/^CT_MPFR_VERSION=/, @config_file);
	if($res[0] =~ m/^CT_MPFR_VERSION="(.*)"/)
	{
		$toolchain_config->{gmp_mpfr}->{mpfr_version} = $1;
	}
}
else
{
	$toolchain_config->{gmp_mpfr}->{use_gmp_mpfr} = 'no';
}

## Binutils
@res=grep(/^CT_BINUTILS_VERSION=/, @config_file);
if($res[0] =~ m/^CT_BINUTILS_VERSION="(.*)"/)
{
	$toolchain_config->{binutils}->{binutils_version} = $1;
}
@res=grep(/^CT_BINUTILS_FOR_TARGET_BFD=/, @config_file);
if($res[0] =~ m/^CT_BINUTILS_FOR_TARGET_BFD=y/)
{
	$toolchain_config->{binutils}->{libbfd} = 'yes';
}
else
{
	$toolchain_config->{binutils}->{libbfd} = 'no';
}
@res=grep(/^CT_BINUTILS_FOR_TARGET_IBERTY=/, @config_file);
if($res[0] =~ m/^CT_BINUTILS_FOR_TARGET_IBERTY=y/)
{
	$toolchain_config->{binutils}->{libiberty} = 'yes';
}
else
{
	$toolchain_config->{binutils}->{libiberty} = 'no';
}

## Compilateur C
@res=grep(/^CT_CC_VERSION=/, @config_file);
if($res[0] =~ m/^CT_CC_VERSION="(.*)"/)
{
	$toolchain_config->{cc}->{gcc_version} = $1;
}
@res=grep(/^CT_CC_LANG_CXX=/, @config_file);
if($res[0] =~ m/^CT_CC_LANG_CXX=y/)
{
	$toolchain_config->{cc}->{cpp} = 'yes';
}
else
{
	$toolchain_config->{cc}->{cpp} = 'no';
}
@res=grep(/^CT_CC_LANG_FORTRAN=/, @config_file);
if($res[0] =~ m/^CT_CC_LANG_FORTRAN=y/)
{
	$toolchain_config->{cc}->{fortran} = 'yes';
}
else
{
	$toolchain_config->{cc}->{fortran} = 'no';
}
@res=grep(/^CT_CC_LANG_JAVA=/, @config_file);
if($res[0] =~ m/^CT_CC_LANG_JAVA=y/)
{
	$toolchain_config->{cc}->{java} = 'yes';
}
else
{
	$toolchain_config->{cc}->{java} = 'no';
}

## Bibliothèque C
@res=grep(/^CT_LIBC=/, @config_file);
if($res[0] =~ m/^CT_LIBC="(\w+)"/)
{
	$toolchain_config->{clib}->{libc} = $1;
}
else
{
	$toolchain_config->{clib}->{clib} = 'none';
}
@res=grep(/^CT_LIBC_VERSION=/, @config_file);
if($res[0] =~ m/^CT_LIBC_VERSION="(.*)"/)
{
	$toolchain_config->{clib}->{clib_version} = $1;
}
@res=grep(/^CT_THREADS=/, @config_file);
if($res[0] =~ m/^CT_THREADS="(\w+)"/)
{
	$toolchain_config->{clib}->{threading_lib} = $1;
}
else
{
	$toolchain_config->{clib}->{threading_lib} = 'none';
}

## Tools

@res=grep(/^CT_TOOL_libelf=/, @config_file);
if($res[0] =~ m/^CT_TOOL_libelf=y/)
{
	$toolchain_config->{tools}->{libelf} = 'yes';
}
else
{
	$toolchain_config->{tools}->{libelf} = 'no';
}
@res=grep(/^CT_TOOL_sstrip=/, @config_file);
if($res[0] =~ m/^CT_TOOL_sstrip=y/)
{
	$toolchain_config->{tools}->{sstrip} = 'yes';
}
else
{
	$toolchain_config->{tools}->{sstrip} = 'no';
}

## Debug

@res=grep(/^CT_DEBUG_gdb=/, @config_file);
if($res[0] =~ m/^CT_DEBUG_gdb=y/)
{
	$toolchain_config->{debug}->{gdb} = 'yes';
}
else
{
	$toolchain_config->{debug}->{gdb} = 'no';
}
@res=grep(/^CT_DEBUG_dmalloc=/, @config_file);
if($res[0] =~ m/^CT_DEBUG_dmalloc=y/)
{
	$toolchain_config->{debug}->{dmalloc} = 'yes';
}
else
{
	$toolchain_config->{debug}->{dmalloc} = 'no';
}
@res=grep(/^CT_DEBUG_duma=/, @config_file);
if($res[0] =~ m/^CT_DEBUG_duma=y/)
{
	$toolchain_config->{debug}->{duma} = 'yes';
}
else
{
	$toolchain_config->{debug}->{duma} = 'no';
}
@res=grep(/^CT_DEBUG_ltrace=/, @config_file);
if($res[0] =~ m/^CT_DEBUG_ltrace=y/)
{
	$toolchain_config->{debug}->{ltrace} = 'yes';
}
else
{
	$toolchain_config->{debug}->{ltrace} = 'no';
}
@res=grep(/^CT_DEBUG_strace=/, @config_file);
if($res[0] =~ m/^CT_DEBUG_strace=y/)
{
	$toolchain_config->{debug}->{strace} = 'yes';
}
else
{
	$toolchain_config->{debug}->{strace} = 'no';
}

my $file_name;

if($#ARGV == 1)	## XML output config file
{	
	$config_dir = "$ARGV[1]" . "/";
}

## Compute the tuple of the toolchain
$variant = $toolchain_config->{target_options}->{target_variant};
$endianness = $toolchain_config->{target_options}->{endiannes};
$arch = "\L$arch";
if($arch eq 'x86')
{
	$arch = $variant;
	if($variant eq 'winchip*')
	{
		$arch = 'i486';
	}
	elsif(($variant eq 'pentium')||($variant eq 'pentium-mmx')||($variant eq 'c3*'))
	{
		$arch = 'i586';
	}
	elsif(($variant eq 'pentiumpro')||($variant eq 'pentium*')||($variant eq 'athlon*'))
	{
		$arch = 'i686';
	}
}
elsif ($arch eq 'arm')
{
	if($endianness eq 'big')
	{
		$arch = "$arch" . "eb";
	}
}
elsif($arch eq 'alpha')
{
	$arch = "$arch" . "$variant";
}
elsif($arch eq 'mips')
{
	if($endianness eq 'little')
	{
		$arch = "$arch" . "el";
	}
}
elsif($arch eq 'sh')
{
	$arch = $variant;
	if($endiannes eq 'big')
	{
		$arch = "$arch" . "eb";
	}
}
my $manufacturer = $toolchain_config->{toolchain_options}->{manufacturer};
if($manufacturer eq '')
{
	$manufacturer = 'unknown';
}
my $kernel = $toolchain_config->{os}->{target_os};
if($kernel ne 'linux'){
	$kernel = '';
}
my $lib = $toolchain_config->{clib}->{libc};
my $os;

if(($lib eq 'glibc')||($lib eq 'eglibc'))
{
	$os = 'gnu';
}
elsif ($lib eq 'uClibc')
{
	$os='uclibc';
}
else
{
	$os = 'elf';
}

if(($arch =~ m/arm.*/)&&($toolchain_config->{target_options}->{abi} eq 'eabi'))
{
	if($libc eq 'uClibc')
	{
		$os = "$os" . "gnueabi";
	}
	elsif($lib eq 'none')
	{
		$os = "eabi";
	}
	else
	{
		$os = "$os" . "eabi";
	}
}
elsif($arch eq 'powerpc')
{
	@res=grep(/CT_ARCH_POWERPC_SPE=y/, @config_file);
	if($res[0] =~ m/^CT_ARCH_POWERPC_SPE=y/)
	{
		$os = "$os" . "spe";
	}
}

if($kernel eq '')
{
	$file_name = "$config_dir" . "$arch" . "-" . "$manufacturer" . "-" . "$os" . ".xml";
}
else
{
	$file_name = "$config_dir" . "$arch" . "-" . "$manufacturer" . "-" . "$kernel" . "-" . "$os" . ".xml";
}

$file_name =~ s/.*\/\/.*/.*\/.*/;
if( -f $file_name)
{
	print 'This configuration already exists';
	exit;
}

$xml = new XML::Simple (NoAttr=>1, XMLDecl=>0, RootName=>'ToolchainConfig');
my $data = $xml->XMLout($toolchain_config);

if (! open (XML_FILE, ">$file_name"))
{
	die "Ensure that the path is correct or that write permission is granted.";
}

## Writing XML and XSL headers
$xml_header = "<?xml version='1.0'?>\n";
#$xsl_header = "<?xml-stylesheet type=\"text/xsl\" href=\"config.xsl\"?>\n";
printf(XML_FILE $xml_header);
#printf(XML_FILE $xsl_header);
printf(XML_FILE $data);
close(XML_FILE);
