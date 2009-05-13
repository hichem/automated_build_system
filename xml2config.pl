#!/usr/bin/perl

use Data::Dumper;
use XML::Simple;


if($#ARGV != 0)
{
	die "Fichier de configuration XML manquant."
}

my $WORKING_DIR = `readlink -f $0`;
$WORKING_DIR = `dirname $WORKING_DIR`;
chomp $WORKING_DIR;

my $xml = new XML::Simple;
my $config = $xml->XMLin($ARGV[0]);

my $arch=$config->{target_options}->{target_arch};
my $variant=$config->{target_options}->{target_variant};
my $uarch="\U$arch";
my $abi=$config->{target_options}->{abi};
my $endian=$config->{target_options}->{endiannes};
my $float=$config->{target_options}->{float};
my $sysroot=$config->{toolchain_options}->{sysroot};
my $use_shared_lib=$config->{toolchain_options}->{build_shared_lib};
my $manufacturer=$config->{toolchain_options}->{manufacturer};
my $target_os=$config->{os}->{target_os};
my $kernel_version=$config->{os}->{kernel_version};
my $use_gmp_mpfr=$config->{gmp_mpfr}->{use_gmp_mpfr};
my $gmp_version=$config->{gmp_mpfr}->{gmp_version};
my $mpfr_version=$config->{gmp_mpfr}->{mpfr_version};
my $libbfd=$config->{binutils}->{libbfd};
my $libiberty=$config->{binutils}->{libiberty};
my $binutils_version=$config->{binutils}->{binutils_version};
my $gcc_version=$config->{cc}->{gcc_version};
my $cpp=$config->{cc}->{cpp};
my $fortran=$config->{cc}->{fortran};
my $java=$config->{cc}->{java};
my $libc=$config->{clib}->{libc};
my $clib_version=$config->{clib}->{clib_version};
my $threading_lib=$config->{clib}->{threading_lib};
my $libelf=$config->{tools}->{libelf};
my $sstrip=$config->{tools}->{sstrip};
my $gdb=$config->{debug}->{gdb};
my $dmalloc=$config->{debug}->{dmalloc};
my $duma=$config->{debug}->{duma};
my $ltrace=$config->{debug}->{ltrace};
my $strace=$config->{debug}->{strace};


my $sed_script = "sed -i '";


## Target options

$sed_script = "$sed_script" . "s/.*CT_ARCH\[= \].*/CT_ARCH=\"$arch\"/;";

	## Architecture features
	if($arch eq 'sh')
	{
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_SUPPORTS_BOTH_ENDIAN\[= \].*/CT_ARCH_SUPPORTS_BOTH_ENDIAN=y/;";
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_DEFAULT_LE.*/CT_ARCH_DEFAULT_LE=y/;";
	}
	elsif($arch eq 'alpha')
	{
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_CPU\[= \].*/CT_ARCH_SUPPORT_CPU=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_TUNE\[= \].*/CT_ARCH_SUPPORT_TUNE=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_CPU\[= \].*/CT_ARCH_CPU=\"\"/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_TUNE\[= \].*/CT_ARCH_TUNE=\"\"/;";
	}
	elsif($arch eq 'arm')
	{
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_CPU\[= \].*/CT_ARCH_SUPPORT_CPU=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_CPU\[= \].*/CT_ARCH_CPU=\"\"/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_TUNE\[= \].*/CT_ARCH_SUPPORT_TUNE=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_TUNE\[= \].*/CT_ARCH_TUNE=\"\"/;";
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_SUPPORTS_BOTH_ENDIAN\[= \].*/CT_ARCH_SUPPORTS_BOTH_ENDIAN=y/;";
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_DEFAULT_LE.*/CT_ARCH_DEFAULT_LE=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_ARCH\[= \].*/CT_ARCH_SUPPORT_ARCH=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_FPU\[= \].*/CT_ARCH_SUPPORT_FPU=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_FPU\[= \].*/CT_ARCH_FPU=\"\"/;";
	}
	elsif($arch eq 'mips')
	{
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_CPU\[= \].*/CT_ARCH_SUPPORT_CPU=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_TUNE\[= \].*/CT_ARCH_SUPPORT_TUNE=y/;";
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_SUPPORTS_BOTH_ENDIAN\[= \].*/CT_ARCH_SUPPORTS_BOTH_ENDIAN=y/;";
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_DEFAULT_BE.*/CT_ARCH_DEFAULT_BE=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_ARCH\[= \].*/CT_ARCH_SUPPORT_ARCH=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_CPU\[= \].*/CT_ARCH_CPU=\"\"/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_TUNE\[= \].*/CT_ARCH_TUNE=\"\"/;";
	}
	elsif($arch eq 'ia64')
	{
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_SUPPORTS_BOTH_ENDIAN\[= \].*/CT_ARCH_SUPPORTS_BOTH_ENDIAN=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_64\[= \].*/CT_ARCH_64=y/;";
	}
	elsif($arch eq 'powerpc')
	{
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_CPU\[= \].*/CT_ARCH_SUPPORT_CPU=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_TUNE\[= \].*/CT_ARCH_SUPPORT_TUNE=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_ABI\[= \].*/CT_ARCH_SUPPORT_ABI=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_CPU\[= \].*/CT_ARCH_CPU=\"\"/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_TUNE\[= \].*/CT_ARCH_TUNE=\"\"/;";
	}
	elsif($arch eq 'x86_64')
	{
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_CPU\[= \].*/CT_ARCH_SUPPORT_CPU=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_TUNE\[= \].*/CT_ARCH_SUPPORT_TUNE=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_ARCH\[= \].*/CT_ARCH_SUPPORT_ARCH=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_64\[= \].*/CT_ARCH_64=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_CPU\[= \].*/CT_ARCH_CPU=\"\"/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_TUNE\[= \].*/CT_ARCH_TUNE=\"\"/;";
	}
	elsif($arch eq 'x86')
	{
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_CPU\[= \].*/CT_ARCH_SUPPORT_CPU=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_TUNE\[= \].*/CT_ARCH_SUPPORT_TUNE=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_ARCH\[= \].*/CT_ARCH_SUPPORT_ARCH=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_CPU\[= \].*/CT_ARCH_CPU=\"\"/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_TUNE\[= \].*/CT_ARCH_TUNE=\"\"/;";
	}

if ($variant ne 'none')
{
	if(($arch eq 'sh')||($arch eq 'alpha'))
	{
		$sed_script = "$sed_script" . "s/.*CT_ARCH_${uarch}_"."\U$variant"."\[= \].*/CT_ARCH_${uarch}_"."\U$variant"."=y/;";
		$sed_script = "$sed_script" . "s/.*CT_ARCH_${uarch}_VARIANT\[= \].*/CT_ARCH_${uarch}_VARIANT=\"$variant\"/;";
	}
	else
	{
		$sed_script = "$sed_script" . "s/.*CT_ARCH_ARCH\[= \].*/CT_ARCH_ARCH=\"$variant\"/;";
	}
}

$sed_script = "$sed_script" .  "s/.*CT_ARCH_$arch\[= \].*/CT_ARCH_$arch=y/;";
if($abi eq 'eabi')
{
	#$sed_script = "$sed_script" . "s/.*CT_ARCH_ABI\[= \].*/CT_ARCH_ABI=\"\"/;";
	$sed_script = "$sed_script" .  "s/.*CT_ARCH_ARCH_EABI.*/CT_ARCH_${uarch}_EABI=y/;";
}
elsif ($abi eq 'abi')
{
	$sed_script = "$sed_script" . "s/.*CT_ARCH_SUPPORT_ABI\[= \].*/CT_ARCH_SUPPORT_ABI=y/;";
	$sed_script = "$sed_script" . "s/.*CT_ARCH_ABI\[= \].*/CT_ARCH_ABI=\"\"/;";
	if($arch eq 'arm')
	{
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_ARM_ABI_OK.*/CT_ARCH_ARM_ABI_OK=y/;";	
	}
}

if($endian ne 'none')
{	
	if($endian eq 'little')
	{
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_LE.*/CT_ARCH_LE=y/;";
	}
	elsif ($endian eq 'big')
	{
		$sed_script = "$sed_script" .  "s/.*CT_ARCH_BE.*/CT_ARCH_BE=y/;";
	}
}
if($float eq 'software')
{
	$sed_script = "$sed_script" .  "s/.*CT_ARCH_SUPPORT_FPU.*/CT_ARCH_SUPPORT_FPU=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_ARCH_FLOAT_SW.*/CT_ARCH_FLOAT_SW=y/;";
}
elsif($float eq 'hardware')
{	
	$sed_script = "$sed_script" .  "s/.*CT_ARCH_FLOAT_HW.*/CT_ARCH_FLOAT_HW=y/;";
}
## Toolchain options

if($sysroot eq 'yes'){$sed_script = "$sed_script" .  "s/.*CT_USE_SYSROOT.*/CT_USE_SYSROOT=y/;";}
if($use_shared_lib eq 'yes'){$sed_script = "$sed_script" .  "s/.*CT_SHARED_LIBS.*/CT_SHARED_LIBS=y/;";}
$sed_script = "$sed_script" .  "s/.*CT_TARGET_VENDOR.*/CT_TARGET_VENDOR=\"$manufacturer\"/;";

## Target OS

$sed_script = "$sed_script" .  "s/.*CT_KERNEL\[= \].*/CT_KERNEL=\"$target_os\"/;";

if($target_os eq 'linux')
{
	$sed_script = "$sed_script" .  "s/.*CT_KERNEL_VERSION.*/CT_KERNEL_VERSION=\"$kernel_version\"/;";
	$sed_script = "$sed_script" .  "s/.*CT_KERNEL_linux.*/CT_KERNEL_linux=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_KERNEL_LINUX_INSTALL\[= \].*/CT_KERNEL_LINUX_INSTALL=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_KERNEL_LINUX_INSTALL_CHECK.*/CT_KERNEL_LINUX_INSTALL_CHECK=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_KERNEL_LINUX_VERBOSITY_0.*/CT_KERNEL_LINUX_VERBOSITY_0=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_KERNEL_LINUX_VERBOSE_LEVEL.*/CT_KERNEL_LINUX_VERBOSE_LEVEL=0/;";
	if($kernel_version =~ m/2\.6\.(\d+)\.(\d+)/)
	{
		$sed_script = "$sed_script" .  "s/.*CT_KERNEL_V_2_6_$1_$2\[= \].*/CT_KERNEL_V_2_6_$1_$2=y/;";
	}
	elsif($kernel_version =~ m/2\.6\.(\d+)/)
	{
		$sed_script = "$sed_script" .  "s/.*CT_KERNEL_V_2_6_$1\[= \].*/CT_KERNEL_V_2_6_$1=y/;";
	}
}
else
{
	$sed_script = "$sed_script" .  "s/.*CT_BARE_METAL.*/CT_BARE_METAL=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_KERNEL_bare_metal.*/CT_KERNEL_bare_metal=y/;";		
}

## GMP and MPFR

if($use_gmp_mpfr eq 'yes')
{
	$sed_script = "$sed_script" .  "s/.*CT_GMP_MPFR\[= \].*/CT_GMP_MPFR=y/;";
	#$sed_script = "$sed_script" .  "s/.*CT_GMP_MPFR_TARGET\[= \].*/CT_GMP_MPFR_TARGET=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_GMP_CHECK.*/CT_GMP_CHECK=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_MPFR_CHECK.*/CT_MPFR_CHECK=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_GMP_VERSION.*/CT_GMP_VERSION=\"$gmp_version\"/;";	
	$sed_script = "$sed_script" .  "s/.*CT_MPFR_VERSION.*/CT_MPFR_VERSION=\"$mpfr_version\"/;";
	if($gmp_version =~ m/4\.2\.(\d+)/)
	{
		$sed_script = "$sed_script" .  "s/.*CT_GMP_V_4_2_$1.*/CT_GMP_V_4_2_$1=y/;";
	}
	if($mpfr_version =~ m/2\.3\.(\d+)/)
	{
		$sed_script = "$sed_script" .  "s/.*CT_MPFR_V_2_3_$1.*/CT_MPFR_V_2_3_$1=y/;";
	}
}
## Binutils

if(($libbfd eq 'yes')||($libiberty eq 'yes'))
{
	$sed_script = "$sed_script" .  "s/.*CT_BINUTILS_FOR_TARGET\[= \].*/CT_BINUTILS_FOR_TARGET=y/;";
}
if($libbfd eq 'yes')
{
	$sed_script = "$sed_script" .  "s/.*CT_BINUTILS_FOR_TARGET_BFD\[= \].*/CT_BINUTILS_FOR_TARGET_BFD=y/;";
}
if($libiberty eq 'yes')
{
	$sed_script = "$sed_script" .  "s/.*CT_BINUTILS_FOR_TARGET_IBERTY\[= \].*/CT_BINUTILS_FOR_TARGET_IBERTY=y/;";
}
$sed_script = "$sed_script" .  "s/.*CT_BINUTILS_VERSION\[= \].*/CT_BINUTILS_VERSION=\"$binutils_version\"/;";
if($binutils_version =~ m/2\.(\d+)\.(\d+)\.0.(\d+)/)
{
	$sed_script = "$sed_script" .  "s/.*CT_BINUTILS_V_2_$1_$2_0_$3\[= \].*/CT_BINUTILS_V_2_$1_$2_0_$3=y/;";
}
elsif($binutils_version =~ m/2\.(\d+)\.(\d+)\.(\d+)/)
{
	$sed_script = "$sed_script" .  "s/.*CT_BINUTILS_V_2_$1_$2_$3\[= \].*/CT_BINUTILS_V_2_$1_$2_$3=y/;";
}
elsif($binutils_version =~ m/2\.(\d+)/)
{
	$sed_script = "$sed_script" .  "s/.*CT_BINUTILS_V_2_$1\[= \].*/CT_BINUTILS_V_2_$1=y/;";
}

## C compiler
if($cpp eq 'yes'){$sed_script = "$sed_script" .  "s/.*CT_CC_LANG_CXX\[= \].*/CT_CC_LANG_CXX=y/;";}
if($fortran eq 'yes'){$sed_script = "$sed_script" .  "s/.*CT_CC_LANG_FORTRAN\[= \].*/CT_CC_LANG_FORTRAN=y/;";}
if($java eq 'yes'){$sed_script = "$sed_script" .  "s/.*CT_CC_LANG_JAVA\[= \].*/CT_CC_LANG_JAVA=y/;";}
$sed_script = "$sed_script" .  "s/.*CT_CC_VERSION\[= \].*/CT_CC_VERSION=\"$gcc_version\"/;";
if($gcc_version =~ m/(\d+)\.(\d+).*/)	## Check whether the compiler version is greater than the 4.3
{
	if(($1 > 4)||(($1 == 4) && ($2 >= 3)))
	{
		$sed_script = "$sed_script" .  "s/.*CT_CC_GCC_4_3_or_later\[= \].*/CT_CC_GCC_4_3_or_later=y/;";
	}
}
if($libc ne 'none')
{
	if($abi eq 'eabi')
	{
		$sed_script = "$sed_script" .  "s/.*CT_CC_SJLJ_EXCEPTIONS_DONT_USE\[= \].*/CT_CC_SJLJ_EXCEPTIONS_DONT_USE=y/;";
	}
	else
	{
		$sed_script = "$sed_script" .  "s/.*CT_CC_SJLJ_EXCEPTIONS_CONFIGURE\[= \].*/CT_CC_SJLJ_EXCEPTIONS_CONFIGURE=y/;";
	}
}
if($gcc_version =~ m/(\d+)\.(\d+)\.(\d+)/)
{
	$sed_script = "$sed_script" .  "s/.*CT_CC_V_$1_$2_$3\[= \].*/CT_CC_V_$1_$2_$3=y/;";	
}

## C library

$sed_script = "$sed_script" .  "s/.*CT_LIBC\[= \].*/CT_LIBC=\"$libc\"/;";
if($libc ne 'none')
{
	if($libc eq 'glibc')
	{
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_glibc\[= \].*/CT_LIBC_glibc=y/;";	
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_GLIBC_KERNEL_VERSION_AS_HEADERS\[= \].*/CT_LIBC_GLIBC_KERNEL_VERSION_AS_HEADERS=y/;";
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_GLIBC_MIN_KERNEL\[= \].*/CT_LIBC_GLIBC_MIN_KERNEL=\"2.6.26.8\"/;";
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_GLIBC_EXTRA_CONFIG\[= \].*/CT_LIBC_GLIBC_EXTRA_CONFIG=\"\"/;";
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_GLIBC_EXTRA_CFLAGS\[= \].*/CT_LIBC_GLIBC_EXTRA_CFLAGS=\"\"/;";
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_EXTRA_CC_ARGS\[= \].*/CT_LIBC_EXTRA_CC_ARGS=\"\"/;";
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_ADDONS_LIST\[= \].*/CT_LIBC_ADDONS_LIST=\"\"/;";
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_GLIBC_USE_PORTS\[= \].*/CT_LIBC_GLIBC_USE_PORTS=y/;";
		
	}
	elsif ($libc eq 'uClibc')
	{
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_uClibc\[= \].*/CT_LIBC_uClibc=y/;";
		#$sed_script = "$sed_script" .  "s/.*CT_LIBC_UCLIBC_VERBOSITY_0\[= \].*/CT_LIBC_UCLIBC_VERBOSITY_0=y/;";	
		$sed_script = "$sed_script" .  "s,.*CT_LIBC_UCLIBC_CONFIG_FILE.*,CT_LIBC_UCLIBC_CONFIG_FILE=\"\${CT_LIB_DIR}/samples/\${CT_TARGET}/\${CT_LIBC}-\${CT_LIBC_VERSION}\.config\",;";
	}
	elsif ($libc eq 'eglibc')
	{
		$sed_script = "$sed_script" .  "s/.*CT_LIBC_eglibc\[= \].*/CT_LIBC_eglibc=y/;";	
		$sed_script = "$sed_script" .  "s/.*CT_EGLIBC_REVISION\[= \].*/CT_EGLIBC_REVISION=\"HEAD\"/;";	
		$sed_script = "$sed_script" .  "s/.*CT_EGLIBC_CHECKOUT\[= \].*/CT_EGLIBC_CHECKOUT=y/;";	
	}
}

my $eg = '';
if($libc eq 'eglibc')
{
	$eg = 'EG';
}
if($libc ne 'none')
{
	$sed_script = "$sed_script" .  "s/.*CT_LIBC_VERSION\[= \].*/CT_LIBC_VERSION=\"$clib_version\"/;";
	if($clib_version =~ m/(\d+)\.(\d+)\.(\d+)/)
	{
		$sed_script = "$sed_script" .  "s/.*CT_${eg}LIBC_V_$1_$2_$3\[= \].*/CT_LIBC_V_$1_$2_$3=y/;";	
	}
	elsif($clib_version =~ m/(\d+)\.(\d+)/)
	{
		$sed_script = "$sed_script" .  "s/.*CT_${eg}LIBC_V_$1_$2\[= \].*/CT_LIBC_V_$1_$2=y/;";	
	}
}
$sed_script = "$sed_script" .  "s/.*CT_THREADS\[= \].*/CT_THREADS=\"$threading_lib\"/;";
if($threading_lib eq 'nptl')
{
	$sed_script = "$sed_script" .  "s/.*CT_THREADS_NPTL.*/CT_THREADS_NPTL=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_LIBC_SUPPORT_NPTL\[= \].*/CT_LIBC_SUPPORT_NPTL=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_LIBC_SUPPORT_LINUXTHREADS\[= \].*/CT_LIBC_SUPPORT_LINUXTHREADS=y/;";
}
elsif ($threading_lib eq 'linuxthreads')
{
	$sed_script = "$sed_script" .  "s/.*CT_THREADS_LINUXTHREADS\[= \].*/CT_THREADS_LINUXTHREADS=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_LIBC_SUPPORT_LINUXTHREADS\[= \].*/CT_LIBC_SUPPORT_LINUXTHREADS=y/;";
}
else
{
	$sed_script = "$sed_script" .  "s/.*CT_THREADS_NONE\[= \].*/CT_THREADS_NONE=y/;";
}

## Tools

if($libelf eq 'yes')
{
	$sed_script = "$sed_script" .  "s/.*CT_TOOL_libelf\[= \].*/CT_TOOL_libelf=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_LIBELF_V_0_8_10\[= \].*/CT_LIBELF_V_0_8_10=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_LIBELF_VERSION\[= \].*/CT_LIBELF_VERSION=\"0\.8\.10\"/;";
}
if($sstrip eq 'yes')
{
	$sed_script = "$sed_script" .  "s/.*CT_TOOL_sstrip\[= \].*/CT_TOOL_sstrip=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_SSTRIP_BUILDROOT\[= \].*/CT_SSTRIP_BUILDROOT=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_SSTRIP_FROM\[= \].*/CT_SSTRIP_FROM=\"buildroot\"/;";
}

## Debug

if($dmalloc eq 'yes'){
	$sed_script = "$sed_script" .  "s/.*CT_DEBUG_dmalloc\[= \].*/CT_DEBUG_dmalloc=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_DMALLOC_VERSION\[= \].*/CT_DMALLOC_VERSION=\"5\.5\.2\"/;";
	$sed_script = "$sed_script" .  "s/.*CT_DMALLOC_V_5_5_2\[= \].*/CT_DMALLOC_V_5_5_2=y/;";
}
if($duma eq 'yes'){
	$sed_script = "$sed_script" .  "s/.*CT_DEBUG_duma\[= \].*/CT_DEBUG_duma=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_DUMA_A\[= \].*/CT_DUMA_A=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_DUMA_SO\[= \].*/CT_DUMA_SO=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_DUMA_VERSION\[= \].*/CT_DUMA_VERSION=\"2_5_14\"/;";
	$sed_script = "$sed_script" .  "s/.*CT_DUMA_V_2_5_14\[= \].*/CT_DUMA_V_2_5_14=y/;";
}
if($gdb eq 'yes')
{
	$sed_script = "$sed_script" .  "s/.*CT_GDB_GDBSERVER[\= \].*/CT_GDB_GDBSERVER=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_GDB_GDBSERVER_STATIC\[= \].*/CT_GDB_GDBSERVER_STATIC=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_GDB_NATIVE\[= \].*/CT_GDB_NATIVE=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_GDB_CROSS\[= \].*/CT_GDB_CROSS=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_GDB_V_6_8\[= \].*/CT_GDB_V_6_8=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_GDB_VERSION\[= \].*/CT_GDB_VERSION=\"6\.8\"/;";
}
if($ltrace eq 'yes')
{
	$sed_script = "$sed_script" .  "s/.*CT_DEBUG_ltrace\[= \].*/CT_DEBUG_ltrace=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_LTRACE_V_0_5\[= \].*/CT_LTRACE_V_0_5=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_LTRACE_VERSION\[= \].*/CT_LTRACE_VERSION=\"0\.5\"/;";
}
if($strace eq 'yes')
{
	$sed_script = "$sed_script" .  "s/.*CT_DEBUG_strace\[= \].*/CT_DEBUG_strace=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_STRACE_V_4_5_17\[= \].*/CT_STRACE_V_4_5_17=y/;";
	$sed_script = "$sed_script" .  "s/.*CT_STRACE_VERSION\[= \].*/CT_STRACE_VERSION=\"4\.5\.17\"/;";
}

system("cp $WORKING_DIR/template.config .config");
$sed_script = "$sed_script" . "' .config";

$res = system($sed_script);
if($res == 0)
{
	print "Config file created successfully\n";
}
else
{
	print "Failed to generate config file\n";
}
