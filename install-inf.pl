use strict;
use Win32::API;

#...............................................................................

my $infFileName = @ARGV [0] || die ("usage: install-inf.pl <inf-file>\n");

open (my $f, '<', $infFileName) || die ("cannot open $infFileName: $!\n");

my $hwId;
while (my $s = <$f>)
{
	if ($s =~ m/[\s]*;/)
	{
		next;
	}

	if ($s =~ m/([^\s]*VID_[0-9a-f]{4}&PID_[0-9a-f]{4}[^\s]*)/i)
	{
		$hwId = $1;
		last;
	}
}

if (!$hwId)
{
	die ("HWID not found in: $infFileName\n");
}

print ("installing $infFileName for HWID $hwId...\n");

my $UpdateDriverForPlugAndPlayDevicesA = Win32::API->new (
	"newdev.dll",
	"BOOL
	UpdateDriverForPlugAndPlayDevicesA (
		HWND hwndParent,
		LPCSTR HardwareId,
		LPCSTR FullInfPath,
		DWORD InstallFlags,
		PBOOL bRebootRequired
		)"
	) || die ("cannot find newdev.dll:UpdateDriverForPlugAndPlayDevicesA: $!\n");

my $NULL              = 0;
my $INSTALLFLAG_FORCE = 1;

my $result = $UpdateDriverForPlugAndPlayDevicesA->Call (
	$NULL,
	$hwId,
	$infFileName,
	$INSTALLFLAG_FORCE,
	$NULL
	);

if (!$result)
{
	my $error = Win32::GetLastError ();
	my $message = getWinErrorMessage ($error);
	die (sprintf ("error (%d 0x%08x): %s\n", $error, $error, $message));
}

print ("done.\n");

#...............................................................................

sub getWinErrorMessage
{
	my ($error) = @_;

	my $s = Win32::FormatMessage ($error);
	if ($s)
	{
		return $s;
	}

	# try again with HRESULT_FROM_SETUPAPI

	# special handling for setupapi errors is needed --
	# FormatMessage fails unless setupapi errors are converted to HRESULT

	my $FACILITY_WIN32         = 7;
	my $FACILITY_SETUPAPI      = 15;
	my $APPLICATION_ERROR_MASK = 0x20000000;
	my $ERROR_SEVERITY_ERROR   = 0xC0000000;

	my $mask = $APPLICATION_ERROR_MASK | $ERROR_SEVERITY_ERROR;
	if (($error & $mask) == $mask)
	{
		$error = ($error & 0x0000ffff) | ($FACILITY_SETUPAPI << 16) | 0x80000000;
	}
	elsif (!($error & 0x80000000))
	{
		$error = ($error & 0x0000ffff) | ($FACILITY_WIN32 << 16) | 0x80000000;
	}

	my $s = Win32::FormatMessage ($error);
	if ($s)
	{
		return $s;
	}

	return "<undefined-error>";
}

#...............................................................................
