//****************************************************************
// compver.inc - Compiler version definitions
// Modernized for Delphi XE10+ (System.Zip available)
// Target: Delphi XE10 (10 Seattle) and above
//****************************************************************

// All Delphi XE8+ have full Unicode string support
{$DEFINE DELPHI_UNICODE}

// Deprecated string type aliases available
{$DEFINE USE_DEPRECATED_STRING}

// Shared define for Unicode-capable compilers
{$DEFINE FPC_OR_DELPHI_UNICODE}

// FormatSettings record (Delphi 2010+)
{$DEFINE Z_USE_FORMAT_SETTINGS}

// Version-specific defines
{$IF CompilerVersion >= 29.0}
  {$DEFINE DELPHI_XE8_UP}    // System.Zip available
{$IFEND}

{$IF CompilerVersion >= 30.0}
  {$DEFINE DELPHI_100_UP}    // Delphi 10 Seattle (XE10)
{$IFEND}

{$IF CompilerVersion >= 31.0}
  {$DEFINE DELPHI_101_UP}    // Delphi 10.1 Berlin
{$IFEND}

{$IF CompilerVersion >= 32.0}
  {$DEFINE DELPHI_102_UP}    // Delphi 10.2 Tokyo
{$IFEND}

{$IF CompilerVersion >= 33.0}
  {$DEFINE DELPHI_103_UP}    // Delphi 10.3 Rio
{$IFEND}

{$IF CompilerVersion >= 34.0}
  {$DEFINE DELPHI_104_UP}    // Delphi 10.4 Sydney
{$IFEND}

{$IF CompilerVersion >= 35.0}
  {$DEFINE DELPHI_11_UP}     // Delphi 11 Alexandria
{$IFEND}

{$IF CompilerVersion >= 36.0}
  {$DEFINE DELPHI_12_UP}     // Delphi 12 Athens
{$IFEND}

