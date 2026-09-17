//****************************************************************
// zexml.inc - Global compiler directives
// Modernized: System.Zip backend, UTF-8, base RTL libraries only
// Minimum target: Delphi XE10 (10 Seattle) and above (System.Zip dependency)
//****************************************************************

// ZColorStringGrid component — not needed for pure library use
{$DEFINE NOZCOLORSTRINGGRID}

// Conditional formatting support
{$DEFINE ZUSE_CONDITIONAL_FORMATTING}

// Compact XML output (no indents/newlines) - smaller file size
{$DEFINE NOXMLINDENTS}

// Chart support
{$DEFINE ZUSE_CHARTS}

// Drawing/image support
{$DEFINE ZUSE_DRAWINGS}

// ZIP backend: System.Zip (built-in in Delphi XE8+ / XE10+)
{$DEFINE SYSTEMZIP}

// FPC / Lazarus not supported in this modernized version
{$IFDEF FPC}
  {$MESSAGE FATAL 'This modernized version targets Delphi only. Use original ZEXMLSS for FPC/Lazarus.'}
{$ENDIF}

// Minimum: Delphi XE8 / Delphi 10 Seattle (CompilerVersion 29) — System.Zip requirement
{$IF CompilerVersion < 29.0}
  {$MESSAGE FATAL 'Delphi XE10 / XE8 or above required (System.Zip dependency).'}
{$IFEND}

