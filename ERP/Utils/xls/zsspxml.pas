//****************************************************************
// zsspxml: XML reader
// Created in Mozyr, 2009
// Author: Ruslan V. Neborak
// e-mail: avemey(at)tut(dot)by
// URL:    http://avemey.com
// Ver:    0.0.7
// License: zlib
// Last update: 2014.07.20
//----------------------------------------------------------------
// This software is provided "as-is", without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from the
// use of this software.
//****************************************************************
unit zsspxml;

interface

{$I zexml.inc}
{$I compver.inc}

uses
  SysUtils, Classes;

const
  BOMUTF8 = #239#187#191; // EF BB BF
  BOMUTF16BE = #254#255;     // FE FF
  BOMUTF16LE = #255#254;     // FF FE
  BOMUTF32BE = #0#0#254#255; // 00 00 FE FF
  BOMUTF32LE = #255#254#0#0; // FF FE 00 00

const
  TAG_TYPE_UNKNOWN = 0; // unknown
  TAG_TYPE_DECLARE = 1; // <?...?> processing instruction
  TAG_TYPE_CDATA = 2; // <![CDATA[..]]> CDATA section
  TAG_TYPE_COMMENT = 3; // <!--..--> comment
  TAG_TYPE_START = 4; // <...>    opening tag   (4 and 4 = 4)
  TAG_TYPE_CLOSED = 5; // <.../>   self-closing  (5 and 4 = 4)
  TAG_TYPE_END = 6; // </...>   closing tag   (6 and 4 = 4)

type

  // Converts ANSI text to the required encoding
  TAnsiToCPConverter = function(const AnsiText: ansistring): ansistring;

  TReadCPCharObj = procedure(var RetChar: ansistring; var _eof: boolean) of object;

  TReadCPChar = procedure(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);

  TCPToAnsiConverter = TAnsiToCPConverter;

  TZAttrArray = array[0..1] of ansistring;

  TagsProp = record
    Name: ansistring;
    CloseTagNewLine: boolean;
  end;

  // XML tag attribute builder
  TZAttributes = class(TPersistent)
  private
    FCount: integer;
    FMaxCount: integer;
    FItems: array of TZAttrArray;
    function GetAttrS(const Att: ansistring): ansistring;
    procedure SetAttrS(const Att: ansistring; const Value: ansistring);
    function GetAttrI(num: integer): ansistring;
    procedure SetAttrI(num: integer; const Value: ansistring);
    function GetAttr(num: integer): TZAttrArray;
    procedure SetAttr(num: integer; const Value: TZAttrArray);
  protected
    procedure ResizeItemsArray(NewSize: integer);
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Add(const AttrName: ansistring; const Value: ansistring; TestMatch: boolean = true); overload;
    procedure Add(const Attr: TZAttrArray; TestMatch: boolean = true); overload;
    procedure Add(Att: array of TZAttrArray; TestMatch: boolean = true); overload;
    procedure Assign(Source: TPersistent); override;
    procedure Clear();
    procedure DeleteItem(Index: integer);
    procedure Insert(Index: integer; const AttrName: ansistring; const Value: ansistring; TestMatch: boolean = true); overload;
    procedure Insert(Index: integer; const Attr: TZAttrArray; TestMatch: boolean = true); overload;
    function ToString(quote: ansichar; CheckEntity: boolean; addempty: boolean): ansistring; reintroduce; overload; virtual;
    function ToString(quote: ansichar; CheckEntity: boolean): ansistring; reintroduce; overload; virtual;
    function ToString(quote: ansichar): ansistring; reintroduce; overload; virtual;
    function ToString(CheckEntity: boolean): ansistring; reintroduce; overload; virtual;
    function ToString(): ansistring; reintroduce; overload; virtual;
    function IsContainsAttribute(const AttrName: ansistring; CaseSensitivity: boolean = true): boolean;
    property Count: integer read FCount;
    property Items[num: integer]: TZAttrArray read GetAttr write SetAttr;
    property ItemsByName[const Att: ansistring]: ansistring read GetAttrS write SetAttrS; default;
    property ItemsByNum[num: integer]: ansistring read GetAttrI write SetAttrI;
  end;

  // XML writer
  TZsspXMLWriter = class
  private
    FAttributeQuote: ansichar;
    FAttributes: TZAttributes;
    FTags: array of TagsProp;
    FTagCount: integer;
    FMaxTagCount: integer;
    FBuffer: ansistring;
    FMaxBufferLength: integer;
    FInProcess: boolean;
    FStream: TStream;
    FTextConverter: TAnsiToCPConverter;
    FNewLine: boolean;
    FUnixNLSeparator: boolean;
    FNLSeparator: ansistring;
    FTab: ansistring;
    FTabSymbol: ansistring;
    FTabLength: integer;
    FDestination: byte;
    function GetTag(num: integer): ansistring;
    function GetTabSymbol(): ansichar;
    procedure SetAttributeQuote(Value: ansichar);
    procedure SetMaxBufferLength(Value: integer);
    procedure SetNewLine(Value: boolean);
    procedure SetTabLength(Value: integer);
    procedure SetTabSymbol(Value: ansichar);
    procedure SetTextConverter(Value: TAnsiToCPConverter);
    procedure SetUnixNLSeparator(Value: boolean);
    procedure SetAttributes(Value: TZAttributes);
  protected
    procedure AddText(const Text: ansistring; UseConverter: boolean = true);
    procedure AddNode(const TagName: ansistring; CloseTagNewLine: boolean);
    function GetTab(num: integer = 0): ansistring;
    procedure _AddTag(const _begin: ansistring; text: ansistring; const _end: ansistring; StartNewLine: boolean; _tab: integer = 0);
    procedure ResizeTagArray(NewSize: integer);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    function BeginSaveToStream(Stream: TStream): boolean;
    function BeginSaveToFile(const FileName: string): boolean;
    function BeginSaveToString(): boolean;
    procedure EndSaveTo();
    procedure FlushBuffer();
    procedure WriteCDATA(CDATA: ansistring; CorrectCDATA: boolean; StartNewLine: boolean = true); overload;     //<![CDATA[ bla-bla-bla <><><>...]]>
    procedure WriteCDATA(const CDATA: ansistring); overload;
    procedure WriteComment(const Comment: ansistring; StartNewLine: boolean = true);           //<!-- bla-bla-bla -->
    procedure WriteEmptyTag(const TagName: ansistring; SAttributes: TZAttributes; StartNewLine: boolean; CheckEntity: boolean = true); overload; // <tag a="a"... />
    procedure WriteEmptyTag(const TagName: ansistring; AttrArray: array of TZAttrArray; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteEmptyTag(const TagName: ansistring; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteEmptyTag(const TagName: ansistring; SAttributes: TZAttributes); overload;
    procedure WriteEmptyTag(const TagName: ansistring; AttrArray: array of TZAttrArray); overload;
    procedure WriteEmptyTag(const TagName: ansistring); overload;
    procedure WriteEndTagNode(); overload;
    procedure WriteEndTagNode(isForce: boolean; CloseTagNewLine: boolean); overload;
    procedure WriteInstruction(const InstructionName: ansistring; SAttributes: TZAttributes; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteInstruction(const InstructionName: ansistring; AttrArray: array of TZAttrArray; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteInstruction(const InstructionName: ansistring; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteInstruction(const InstructionName: ansistring; SAttributes: TZAttributes); overload;
    procedure WriteInstruction(const InstructionName: ansistring; AttrArray: array of TZAttrArray); overload;
    procedure WriteInstruction(const InstructionName: ansistring); overload;
    procedure WriteRaw(Text: ansistring; UseConverter: boolean; StartNewLine: boolean = true);
    procedure WriteTag(const TagName: ansistring; const Text: ansistring; SAttributes: TZAttributes; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTag(const TagName: ansistring; const Text: ansistring; AttrArray: array of TZAttrArray; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTag(const TagName: ansistring; const Text: ansistring; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTag(const TagName: ansistring; const Text: ansistring; SAttributes: TZAttributes); overload;
    procedure WriteTag(const TagName: ansistring; const Text: ansistring; AttrArray: array of TZAttrArray); overload;
    procedure WriteTag(const TagName: ansistring; const Text: ansistring); overload;
    procedure WriteTagNode(const TagName: ansistring; SAttributes: TZAttributes; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTagNode(const TagName: ansistring; AttrArray: array of TZAttrArray; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTagNode(const TagName: ansistring; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTagNode(const TagName: ansistring; SAttributes: TZAttributes); overload;
    procedure WriteTagNode(const TagName: ansistring; AttrArray: array of TZAttrArray); overload;
    procedure WriteTagNode(const TagName: ansistring); overload;
    property Attributes: TZAttributes read FAttributes write SetAttributes;
    property AttributeQuote: ansichar read FAttributeQuote write SetAttributeQuote;
    property Buffer: ansistring read FBuffer;
    property InProcess: boolean read FInProcess;
    property MaxBufferLength: integer read FMaxBufferLength write SetMaxBufferLength;
    property NewLine: boolean read FNewLine write SetNewLine;
    property TabLength: integer read FTabLength write SetTabLength;
    property TabSymbol: ansichar read GetTabSymbol write SetTabSymbol;
    property TagCount: integer read FTagCount;
    property Tags[num: integer]: ansistring read GetTag;
    property TextConverter: TAnsiToCPConverter read FTextConverter write SetTextConverter;
    property UnixNLSeparator: boolean read FUnixNLSeparator write SetUnixNLSeparator;
  end;

  // Required encodings:
  //    windows-1251
  //    cp866
  //    UTF-8
  //    UTF-16
  // Challenges: 1. How to detect text encoding?
  //             2. How to read multi-byte encoded text?
  //             3. How to parse multi-byte encoded text?
  //             4. How to handle unknown encodings?

  // XML reader
  TZsspXMLReader = class
  private
    FAttributes: TZAttributes;
    FStream: TStream;
    FTags: array of ansistring;
    FTagCount: integer;
    FMaxTagCount: integer;
    FBuffer: ansistring;
    FMaxBufferLength: integer;
    FInProcess: boolean;
    FSourceType: byte;
    FPFirst: integer;
    FPLast: integer;
    FTextBeforeTag: ansistring;
    FErrorCode: integer;
             // and    1  =    1 - parameter value without quotes (<TAG param=value>)

             // and    4  =    4 - <TAG ... param = value = ...> (unquoted param value)
             // and    8  =    8 - <TAG ... param =/...> (unquoted param value)
             // and   16  =   16 - <TAG ... param = value"...> (missing opening quote)

             // and   64  =   64 - <TAG ... param = value/ ... >
             // and  128  =  128 - <!Unknown... > unexpected comment-like tag
             // and  256  =  256 - <=...>
             // and  512  =  512 - <tag!*...> - '!' in wrong position
             // and 1024  = 1024 - <tag ... param = ?...>
             // and 2048  = 2048 - < tag ... > whitespace after '<'
             // and 4096  = 4096 - < tag ... param param ... > ('=' missing between params)
             // and 8192  = 8192 - </|?tag ... /> unexpected '/' or '?'
             // and 16384 = 16384 - <tag ... ?>
             // and 32768 = 32768 - '<' in unexpected position
             // and 65536 = 65536 - stray quote character in unexpected position
             // and 131072 = 131072 - unexpected end of tag
             // and 262144 = 262144 - closing tag has no matching opening tag
             // and 524288 = 524288 - EOF reached with unclosed tags

    FRawTextTag: ansistring;
//    FRawTextTagNotDecoded: ansistring; // raw undecoded tag text
    FTagName: ansistring;
    FValue: ansistring;
    FTagType: byte;
                                                // 0 - unknown
                                                // 1 - <?...?>
                                                // 2 - <![CDATA[..]]>
                                                // 3 - <!--..-->
                                                // 4 - <...>    (4 and 4 = 4)
                                                // 5 - <.../>   (5 and 4 = 4)
                                                // 6 - </...>   (6 and 4 = 4)
    FCharReader: TReadCPChar;
    FCharConverter: TCPToAnsiConverter;
    FStreamEnd: boolean;
    FIgnoreCase: boolean;
    FQuotesEqual: boolean;
    FAttributesMatch: boolean;
    function GetTag(num: integer): ansistring;
    procedure SetMaxBufferLength(Value: integer);
    procedure AddTag(const Value: ansistring);
    procedure DeleteClosedTag();
    procedure DeleteTag();
    procedure SetIgnoreCase(Value: boolean);
    procedure SetQuotesEqual(Value: boolean);
    procedure SetAttributesMatch(Value: boolean);
  protected
    procedure Clear();
    procedure ClearAll();
    procedure RecognizeEncoding(var txt: ansistring);
    procedure ReadBuffer();
    procedure GetOneChar(var OneChar: ansistring; var err: boolean);
    procedure ResizeTagArray(NewSize: integer);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    function BeginReadFile(FileName: string): integer;
    function BeginReadStream(Stream: TStream): integer;
    function BeginReadString(Source: ansistring; IgnoreCodePage: boolean = true): integer;
    function ReadTag(): boolean;
    procedure EndRead();
    function Eof(): boolean; virtual;
    property Attributes: TZAttributes read FAttributes;
    property AttributesMatch: boolean read FAttributesMatch write SetAttributesMatch;
    property InProcess: boolean read FInProcess;
    property RawTextTag: ansistring read FRawTextTag;
    property ErrorCode: integer read FErrorCode;
    property IgnoreCase: boolean read FIgnoreCase write SetIgnoreCase;
    property TagName: ansistring read FTagName;
    property TagValue: ansistring read FValue;
    property TagType: byte read FTagType;
    property TagCount: integer read FTagCount;
    property Tags[num: integer]: ansistring read GetTag;
    property TextBeforeTag: ansistring read FTextBeforeTag;
    property MaxBufferLength: integer read FMaxBufferLength write SetMaxBufferLength;
    property QuotesEqual: boolean read FQuotesEqual write SetQuotesEqual; // If true, single and double quotes are treated as equivalent.
                                                                          // If false (default): in <tagname attr1="asda' attr2='adsas">
                                                                          //   attr1 gets value "asda' attr2='adsas" (one attribute)
                                                                          // If true: two attributes recognized: attr1="asda" and attr2="adsas".
                                                                          // Default: false.
  end;

// Delphi 10.4+ Unicode API
  TZAttrArrayH = array[0..1] of string;
  // Unicode attribute wrapper class over TZAttributes

  TZAttributesH = class(TPersistent)
  private
    FAttributes: TZAttributes;
    function GetAttrCount(): integer;
    function GetAttrS(Att: string): string;
    procedure SetAttrS(Att: string; const Value: string);
    function GetAttrI(num: integer): string;
    procedure SetAttrI(num: integer; const Value: string);
    function GetAttr(num: integer): TZAttrArrayH;
    procedure SetAttr(num: integer; const Value: TZAttrArrayH);
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Add(const AttrName: string; const Value: string; TestMatch: boolean = true); overload;
    procedure Add(const Attr: TZAttrArrayH; TestMatch: boolean = true); overload;
    procedure Add(Att: array of TZAttrArrayH; TestMatch: boolean = true); overload;
    procedure Assign(Source: TPersistent); override;
    procedure Clear();
    procedure DeleteItem(Index: integer);
    procedure Insert(Index: integer; const AttrName: string; const Value: string; TestMatch: boolean = true); overload;
    procedure Insert(Index: integer; const Attr: TZAttrArrayH; TestMatch: boolean = true); overload;
    function ToString(quote: char; CheckEntity: boolean; addempty: boolean): string; reintroduce; overload; virtual;
    function ToString(quote: char; CheckEntity: boolean): string; reintroduce; overload; virtual;
    function ToString(quote: char): string; reintroduce; overload; virtual;
    function ToString(CheckEntity: boolean): string; reintroduce; overload; virtual;
    function ToString(): string; overload; override;
    function IsContainsAttribute(const AttrName: string; CaseSensitivity: boolean = true): boolean;
    property Count: integer read GetAttrCount;
    property Items[num: integer]: TZAttrArrayH read GetAttr write SetAttr;
    property ItemsByName[Att: string]: string read GetAttrS write SetAttrS; default;
    property ItemsByNum[num: integer]: string read GetAttrI write SetAttrI;
  end;

  // XML writer
  TZsspXMLWriterH = class
  private
    FAttributes: TZAttributesH;
    FXMLWriter: TZsspXMLWriter;
    function GetXMLBuffer(): string;
    function GetAttributeQuote(): char;
    function GetInProcess(): boolean;
    function GetMaxBufferLength(): integer;
    function GetNewLine(): boolean;
    function GetTabLength(): integer;
    function GetTagCount(): integer;
    function GetTextConverter(): TCPToAnsiConverter;
    function GetUnixNLSeparator(): boolean;
    function GetTag(num: integer): string;
    function GetTabSymbol(): char;
    procedure SetAttributeQuote(Value: char);
    procedure SetMaxBufferLength(Value: integer);
    procedure SetNewLine(Value: boolean);
    procedure SetTabLength(Value: integer);
    procedure SetTabSymbol(Value: char);
    procedure SetTextConverter(Value: TAnsiToCPConverter);
    procedure SetUnixNLSeparator(Value: boolean);
    procedure SetAttributes(Value: TZAttributesH);
  protected
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    function BeginSaveToStream(Stream: TStream): boolean;
    function BeginSaveToFile(FileName: string): boolean;
    function BeginSaveToString(): boolean;
    procedure EndSaveTo();
    procedure FlushBuffer();
    procedure WriteCDATA(CDATA: string; CorrectCDATA: boolean; StartNewLine: boolean = true); overload;     //<![CDATA[ bla-bla-bla <><><>...]]>
    procedure WriteCDATA(CDATA: string); overload;
    procedure WriteComment(Comment: string; StartNewLine: boolean = true);           //<!-- bla-bla-bla -->
    procedure WriteEmptyTag(TagName: string; SAttributes: TZAttributesH; StartNewLine: boolean; CheckEntity: boolean = true); overload; // <tag a="a"... />
    procedure WriteEmptyTag(TagName: string; AttrArray: array of TZAttrArrayH; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteEmptyTag(TagName: string; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteEmptyTag(TagName: string; SAttributes: TZAttributesH); overload;
    procedure WriteEmptyTag(TagName: string; AttrArray: array of TZAttrArrayH); overload;
    procedure WriteEmptyTag(TagName: string); overload;
    procedure WriteEndTagNode(); overload;
    procedure WriteEndTagNode(isForce: boolean; CloseTagNewLine: boolean); overload;
    procedure WriteInstruction(InstructionName: string; SAttributes: TZAttributesH; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteInstruction(InstructionName: string; AttrArray: array of TZAttrArrayH; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteInstruction(InstructionName: string; StartNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteInstruction(InstructionName: string; SAttributes: TZAttributesH); overload;
    procedure WriteInstruction(InstructionName: string; AttrArray: array of TZAttrArrayH); overload;
    procedure WriteInstruction(InstructionName: string); overload;
    procedure WriteRaw(Text: string; UseConverter: boolean; StartNewLine: boolean = true); overload;
    procedure WriteRaw(Text: ansistring; UseConverter: boolean; StartNewLine: boolean = true); overload;
    procedure WriteTag(TagName: string; Text: string; SAttributes: TZAttributesH; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTag(TagName: string; Text: string; AttrArray: array of TZAttrArrayH; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTag(TagName: string; Text: string; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTag(TagName: string; Text: string; SAttributes: TZAttributesH); overload;
    procedure WriteTag(TagName: string; Text: string; AttrArray: array of TZAttrArrayH); overload;
    procedure WriteTag(TagName: string; Text: string); overload;
    procedure WriteTagNode(TagName: string; SAttributes: TZAttributesH; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTagNode(TagName: string; AttrArray: array of TZAttrArrayH; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTagNode(TagName: string; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true); overload;
    procedure WriteTagNode(TagName: string; SAttributes: TZAttributesH); overload;
    procedure WriteTagNode(TagName: string; AttrArray: array of TZAttrArrayH); overload;
    procedure WriteTagNode(TagName: string); overload;
    property Attributes: TZAttributesH read FAttributes write SetAttributes;
    property AttributeQuote: char read GetAttributeQuote write SetAttributeQuote;
    property Buffer: string read GetXMLBuffer;
    property InProcess: boolean read GetInProcess;
    property MaxBufferLength: integer read GetMaxBufferLength write SetMaxBufferLength;
    property NewLine: boolean read GetNewLine write SetNewLine;
    property TabLength: integer read GetTabLength write SetTabLength;
    property TabSymbol: char read GetTabSymbol write SetTabSymbol;
    property TagCount: integer read GetTagCount;
    property Tags[num: integer]: string read GetTag;
    property TextConverter: TAnsiToCPConverter read GetTextConverter write SetTextConverter;
    property UnixNLSeparator: boolean read GetUnixNLSeparator write SetUnixNLSeparator;
  end;

  // XML reader
  TZsspXMLReaderH = class
  private
    FAttributes: TZAttributesH;
    FXMLReader: TZsspXMLReader;
    function GetAttributes(): TZAttributesH;
    function GetInProcess(): boolean;
    function GetRawTextTag(): string;
    function GetErrorCode(): integer;
    function GetIgnoreCase(): boolean;
    function GetValue(): string;
    function GetTagType(): byte;
    function GetTagCount(): integer;
    function GetTextBeforeTag(): string;
    function GetTagName(): string;
    function GetTag(num: integer): string;
    procedure SetMaxBufferLength(Value: integer);
    function GetMaxBufferLength(): integer;
    procedure SetIgnoreCase(Value: boolean);
    procedure SetQuotesEqual(Value: boolean);
    function GetQuotesEqual(): boolean;
    procedure SetAttributesMatch(Value: boolean);
    function GetAttributesMatch(): boolean;
  protected
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    function BeginReadFile(FileName: string): integer;
    function BeginReadStream(Stream: TStream): integer;
    function BeginReadString(Source: string; IgnoreCodePage: boolean = true): integer;
    function ReadTag(): boolean;
    procedure EndRead();
    function Eof(): boolean; virtual;
    property Attributes: TZAttributesH read GetAttributes;
    property AttributesMatch: boolean read GetAttributesMatch write SetAttributesMatch;
    property InProcess: boolean read GetInProcess;
    property RawTextTag: string read GetRawTextTag;
    property ErrorCode: integer read GetErrorCode;
    property IgnoreCase: boolean read GetIgnoreCase write SetIgnoreCase;
    property TagName: string read GetTagName;
    property TagValue: string read GetValue;
    property TagType: byte read GetTagType;
    property TagCount: integer read GetTagCount;
    property Tags[num: integer]: string read GetTag;
    property TextBeforeTag: string read GetTextBeforeTag;
    property MaxBufferLength: integer read GetMaxBufferLength write SetMaxBufferLength;
    property QuotesEqual: boolean read GetQuotesEqual write SetQuotesEqual;
  end;

// Character readers
procedure ReadCharUTF8(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);

procedure ReadCharUTF16LE(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);

procedure ReadCharUTF16BE(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);

procedure ReadCharUTF32(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);

procedure ReadCharOneByte(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);

//////////// Encoding converters
function conv_UTF8ToLocal(const Text: ansistring): ansistring;

function conv_UTF16LEToLocal(const Text: ansistring): ansistring;

function conv_UTF16BEToLocal(const Text: ansistring): ansistring;

function conv_UTF32LEToLocal(const Text: ansistring): ansistring;

function conv_UTF32BEToLocal(const Text: ansistring): ansistring;

function conv_WIN1251ToLocal(const Text: ansistring): ansistring;

function conv_CP866ToLocal(const Text: ansistring): ansistring;

// Escapes special XML characters
function CheckStrEntity(const st: ansistring; checkamp: boolean = true): ansistring; overload;

function CheckStrEntity(const st: string; checkamp: boolean = true): string; overload;

// Validates an XML entity starting at position num in the string.
// If invalid, replaces '&' with '&amp;'.
procedure Correct_Entity(const _St: ansistring; num: integer; var _result: ansistring); overload;

procedure Correct_Entity(const _St: string; num: integer; var _result: string); overload;

// Add an attribute (name=value pair)
function ToAttribute(const AttrName: ansistring; const Value: ansistring): TZAttrArray; overload;

function ToAttribute(const AttrName: string; const Value: string): TZAttrArrayH; overload;

// Detects encoding of XML/HTML text
function RecognizeEncodingXML(startpos: integer; var txt: ansistring; out cpfromtext: integer; out cpname: ansistring; out ftype: integer): boolean; overload;

// Detects BOM (Byte Order Mark) of a text stream
function RecognizeBOM(var txt: ansistring): integer;

// Detects encoding of XML/HTML text including BOM
function RecognizeEncodingXML(var txt: ansistring; out BOM: integer; out cpfromtext: integer; out cpname: ansistring; out ftype: integer): boolean; overload;

// Get the default UTF-8 converter (always nil in Unicode Delphi)
function ZEGetDefaultUTF8Converter(): TAnsiToCPConverter;

implementation

{$WARN IMPLICIT_STRING_CAST OFF}
{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

uses
  duansistr;

//// Character readers

procedure ReadCharUTF8(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);
var
  s: ansistring;
  t, i: integer;
  kol: integer;
begin
  _eof := false;
  text := '';
  s := '';
  if Assigned(ReadCPChar) then
  begin
    ReadCPChar(s, _eof);
    text := text + s;
    if _eof then
      exit;
    if length(s) > 0 then
    begin
      t := ord(s[1]);
      if t > 127 then
      begin
        {
        // 5-byte sequences are theoretically possible but not in the standard
        if t and 248 = 248 then
          kol := 4 else} {tut}
        kol := 0;
        if t and 240 = 240 then
          kol := 3
        else if t and 224 = 224 then
          kol := 2
        else if t and 192 = 192 then
          kol := 1;
        for i := 1 to kol do
        begin
          // all subsequent bytes must match 10xxxxxx pattern
          ReadCPChar(s, _eof);
          text := text + s;
          if _eof then
            exit;
        end;
      end; //if
    end;
  end
  else
    _eof := true;
end;

procedure ReadCharUTF16LE(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);
var
  i, num: integer;
  s: ansistring;
begin
  _eof := false;
  text := '';
  s := '';
  if Assigned(ReadCPChar) then
  begin
    ReadCPChar(s, _eof);
    text := text + s;
    if _eof then
      exit;
    num := ord(s[1]) shl 8;
    ReadCPChar(s, _eof);
    text := text + s;
    if _eof then
      exit;
    num := num + ord(s[1]);
    if num >= $d800 then
      for i := 1 to 2 do
      begin
        ReadCPChar(s, _eof);
        text := text + s;
        if _eof then
          exit;
      end;
  end
  else
    _eof := true;
end;

procedure ReadCharUTF16BE(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);
var
  i, num: integer;
  s: ansistring;
begin
  _eof := false;
  text := '';
  s := '';
  if Assigned(ReadCPChar) then
  begin
    ReadCPChar(s, _eof);
    text := text + s;
    if _eof then
      exit;
    num := ord(s[1]);
    ReadCPChar(s, _eof);
    text := text + s;
    if _eof then
      exit;
    {$HINTS OFF}
    num := num + (ord(s[1]) shl 8);
    {$HINTS ON}
    if num >= $d800 then
      for i := 1 to 2 do
      begin
        ReadCPChar(s, _eof);
        text := text + s;
        if _eof then
          exit;
      end;
  end
  else
    _eof := true;
end;

procedure ReadCharUTF32(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);
var
  s: ansistring;
  i: integer;
begin
  _eof := false;
  text := '';
  s := '';
  if Assigned(ReadCPChar) then
    for i := 1 to 4 do
    begin
      ReadCPChar(s, _eof);
      text := text + s;
      if _eof then
        exit;
    end
  else
    _eof := true;
end;

// Single-byte encoding reader
procedure ReadCharOneByte(const ReadCPChar: TReadCPCharObj; var text: ansistring; var _eof: boolean);
begin
  _eof := false;
  text := '';
  if Assigned(ReadCPChar) then
    ReadCPChar(text, _eof)
  else
    _eof := true;
end;

//////////// Encoding converters

{tut}

function CP866ToWin1251(const cp866: ansistring): ansistring;
var
  i, n: integer;
  ch: byte;
begin
  n := length(cp866);
  setlength(result, n);
  for i := 1 to n do
  begin
    ch := ord(cp866[i]);
    if (ch >= 128) and (ch <= 175) then
      inc(ch, 64)
    else if ch = 240 then
      ch := 168
    else if ch = 241 then
      ch := 184
    else if ch = 252 then
      ch := 185
    else if (ch >= 224) and (ch <= 239) then
      inc(ch, 16);
    result[i] := Ansichar(ch);
  end;
end;

// For Delphi (Unicode)

function conv_UTF8ToLocal(const Text: ansistring): ansistring;
begin
  result := Text;
end;

function conv_UTF16LEToLocal(const Text: ansistring): ansistring;
var
  ws: WideString;
  w: word;
  i, l: integer;
begin
  ws := '';
  i := 2;
  // TODO: handle odd-length input gracefully
  l := length(Text);
  while i <= l do
  begin
    w := ord(Text[i]) shl 8;
    w := w + ord(Text[i - 1]);
    ws := ws + WideChar(w);
    inc(i, 2);
  end;
  result := UTF8Encode(PWideChar(ws));
end;

function conv_UTF16BEToLocal(const Text: ansistring): ansistring;
var
  ws: WideString;
  w: word;
  i, l: integer;
begin
  ws := '';
  i := 2;
  // TODO: handle odd-length input gracefully
  l := length(Text);
  while i <= l do
  begin
    w := ord(Text[i - 1]) shl 8;
    w := w + ord(Text[i]);
    ws := ws + WideChar(w);
    inc(i, 2);
  end;
  result := UTF8Encode(PWideChar(ws));
end;

function conv_UTF32LEToLocal(const Text: ansistring): ansistring;
begin
  result := Text;
end;

function conv_UTF32BEToLocal(const Text: ansistring): ansistring;
begin
  result := Text;
end;

function conv_WIN1251ToLocal(const Text: ansistring): ansistring;
begin
  result := Text;
end;

function conv_CP866ToLocal(const Text: ansistring): ansistring;
begin
  result := CP866ToWin1251(Text);
end;
///////////////////////////

// Add an attribute (name=value pair)

function ToAttribute(const AttrName: ansistring; const Value: ansistring): TZAttrArray;
begin
  result[0] := AttrName;
  result[1] := Value;
end;

function ToAttribute(const AttrName: string; const Value: string): TZAttrArrayH;
begin
  result[0] := AttrName;
  result[1] := Value;
end;

// Validates an XML entity starting at position num in the string.
// If invalid, replaces '&' with '&amp;'.
procedure Correct_Entity(const _St: ansistring; num: integer; var _result: ansistring);
var
  b: boolean;
  i, l: integer;
begin
  b := true;
  l := length(_St);
  for i := num + 1 to length(_St) do
    case _St[i] of
      ' ', #13, #10, #9, '<', '>', '''', '"', '&':
        begin
          b := false;
          break;
        end;
      ';':
        break;
    end;
  if num >= l then
    b := false;
  if b then
    _result := _result + _St[num]
  else
    _result := _result + '&amp;';
end;

procedure Correct_Entity(const _St: string; num: integer; var _result: string);
var
  b: boolean;
  i, l: integer;
begin
  b := true;
  l := length(_St);
  for i := num + 1 to length(_St) do
    case _St[i] of
      ' ', #13, #10, #9, '<', '>', '''', '"', '&':
        begin
          b := false;
          break;
        end;
      ';':
        break;
    end;
  if num >= l then
    b := false;
  if b then
    _result := _result + _St[num]
  else
    _result := _result + '&amp;';
end;

// Escapes special XML characters in an AnsiString.
// INPUT:
//   st: ansistring - source string
//   checkamp: boolean - true: always replace & with &amp;
//                       false: leave valid entities as-is
// RETURN:
//   ansistring - processed string with XML entities escaped
function CheckStrEntity(const st: ansistring; checkamp: boolean = true): ansistring;
var
  i, kol: integer;
begin
  result := '';
  kol := length(st);
  for i := 1 to kol do
  begin
    case st[i] of
      '<':
        result := result + '&lt;';
      '&':
        begin
          if checkamp then
            result := result + '&amp;'
          else
            Correct_entity(st, i, result);
        end;
      '>':
        result := result + '&gt;';
      '''':
        result := result + '&apos;';
      '"':
        result := result + '&quot;';
    else
      result := result + st[i];
    end;
  end;
end;

// Escapes special XML characters in a Unicode string.
// INPUT:
//   st: string - source string
//   checkamp: boolean - true: always replace & with &amp;
//                       false: leave valid entities as-is
// RETURN:
//   string - processed string with XML entities escaped
function CheckStrEntity(const st: string; checkamp: boolean = true): string;
var
  i, kol: integer;
begin
  result := '';
  kol := length(st);
  for i := 1 to kol do
  begin
    case st[i] of
      '<':
        result := result + '&lt;';
      '&':
        begin
          if checkamp then
            result := result + '&amp;'
          else
            Correct_entity(st, i, result);
        end;
      '>':
        result := result + '&gt;';
      '''':
        result := result + '&apos;';
      '"':
        result := result + '&quot;';
    else
      result := result + st[i];
    end;
  end;
end; // CheckStrEntity

// Get the default UTF-8 converter (always nil in Unicode Delphi)

function ZEGetDefaultUTF8Converter(): TAnsiToCPConverter;
begin
  result := nil;
end; // ZEGetDefaultUTF8Converter

// Returns encoding index by name (must be UPPERCASE)
// INPUT:
//    txt: ansistring - encoding name in UPPERCASE
// RETURN: integer - encoding index

function CPFromName(txt: ansistring): integer;
begin
  result := 0;
  // If no BOM found, treat UTF-16/32 as big-endian
  if (txt = 'UTF-8') or (txt = 'UTF8') then
    result := 1
  else if txt = 'UTF-16' then
    result := 2
  else
 // if txt = 'UTF-16LE' then result := 3 else
    if txt = 'UTF-32' then
    result := 4
  else
 // if txt = 'UTF-32LE' then result := 5 else
    if txt = 'WINDOWS-1251' then
    result := 6
  else if txt = 'CP866' then
    result := 7;
end;

// Detects encoding of XML/HTML text
// (will attempt to detect)
//INPUT
//    startpos: integer   - start position in text
//    txt: ansistring     - text to analyze
//OUTPUT
//    cpfromtext: integer - detected encoding index from text declaration
//                            0 - undetermined
//                            1 - UTF-8
//                            2 - UTF-16BE
//                            3 - UTF-16LE
//                            4 - UTF-32BE
//                            5 - UTF-32LE
//                            6 - Windows-1251
//                            7 - CP866
//    cpname: ansistring  - encoding name found in text declaration
//    ftype: integer      - file type:
//                            0 - unknown
//                            1 - xml
//                            2 - html
// RETURN: boolean - true if encoding was confidently identified
//                   false if encoding detection is uncertain
function RecognizeEncodingXML(startpos: integer; var txt: ansistring; out cpfromtext: integer; out cpname: ansistring; out ftype: integer): boolean; overload;
var
  i, ll: integer;
  kol16BE: integer;
  kol16LE: integer;
  kol32BE: integer;
  kol32LE: integer;
  s: ansistring;
  _kol: integer;
  _l, _f: integer;

  function checkCPFromText(_name: ansistring; _b: boolean): boolean;
  var
    n: integer;
  begin
    result := _b;
    n := CPFromName(_name);
    // If encoding was not previously determined
    if cpfromtext = 0 then
      cpfromtext := n
    else
    // If encoding was previously determined but name does not match -
    // keep the previously determined encoding index and flag
    // as uncertain
      if cpfromtext <> n then
      result := false;
  end;

begin
  cpfromtext := 0;
  ftype := 0;
  ll := length(txt);
  if (ll <= 0) then
  begin
    result := false;
    exit;
  end;
  result := true;
  kol16BE := 0;
  kol16LE := 0;
  kol32BE := 0;
  kol32LE := 0;
  cpname := '';
  if startpos < 0 then
    startpos := 1;
  if startpos > ll then
    startpos := ll;

  // First check for UTF-16 and UTF-32
  // If every second character is #0 - UTF-16
  // If two consecutive #0 bytes, and 4th is not #0 - UTF-32
  i := startpos;
  while (i <= ll - 1) do
  begin
    if (txt[i] = #0) and (txt[i + 1] <> #0) then
      inc(kol16BE);
    if (txt[i] <> #0) and (txt[i + 1] = #0) then
      inc(kol16LE);
    inc(i, 2);
  end;
  i := startpos;
  while (i <= ll - 3) do
  begin
    if (txt[i] = #0) and (txt[i + 1] = #0) and (txt[i + 3] <> #0) then
      inc(kol32BE);
    if (txt[i + 2] = #0) and (txt[i + 3] = #0) and (txt[i] <> #0) then
      inc(kol32LE);
    inc(i, 4);
  end;
  // Iterate possible encoding values

  if (kol16BE > 0) and (kol16LE = 0) and (kol32BE = 0) and (kol32LE = 0) then
    cpfromtext := 2
  else
if (kol16BE = 0) and (kol16LE > 0) and (kol32BE = 0) and (kol32LE = 0) then
    cpfromtext := 3
  else
if (kol16BE = 0) and (kol16LE = 0) and (kol32BE > 0) and (kol32LE = 0) then
    cpfromtext := 4
  else
if (kol16BE = 0) and (kol16LE = 0) and (kol32BE = 0) and (kol32LE > 0) then
    cpfromtext := 5
  else
if (kol16BE = 0) and (kol16LE = 0) and (kol32BE = 0) and (kol32LE = 0) then
  begin
    cpfromtext := 0;
  end
  else
  begin
    result := false;

    i := kol16BE;
    cpfromtext := 2;
    if i < kol16LE then
    begin
      i := kol16LE;
      cpfromtext := 3;
    end;
    if i < kol32BE * 2 then
    begin
      i := kol32BE * 2;
      cpfromtext := 4;
    end;
    if i < kol32LE * 2 then
      cpfromtext := 5;
  end;

  s := '';
  for i := startpos to ll do
    if txt[i] <> #0 then
      s := s + UpCase(txt[i]);
  // XML declaration?
  // TODO: detect PHP tags
  _l := DUAnsiPos(UTF8Encode('?>'), s);
  if _l <> 0 then
  begin
    ftype := 1;
    _f := DUAnsiPos(UTF8Encode('ENCODING'), s);
    if (_f < _l) and (_f > 0) then
    begin
      _kol := 0;
      for i := _f + 8 to _l do
        case s[i] of
          '"', '''':
            if _kol = 0 then
              inc(_kol)
            else
              break;
        else
          if _kol = 1 then
            cpname := cpname + s[i];
        end;
      result := checkCPFromText(cpname, result);
    end
    else
    begin
      // If XML has no ENCODING declaration, assume UTF-8
      if cpfromtext = 0 then
        cpfromtext := 1
      else if cpfromtext <> 1 then
        result := false;
    end;
  end;
  // HTML?
  if ftype = 0 then
  begin
    _f := DUAnsiPos(UTF8Encode('CHARSET'), s);
    if _f > 0 then
    begin
      _l := DUAnsiPos(UTF8Encode('>'), s); //tut
      while (_l < _f) and (_l > 0) do
      begin
        s[_l] := '"';
        _l := DUAnsiPos(UTF8Encode('>'), s);
      end;
      // Probably HTML
      if (_l > _f) then
      begin
        ftype := 2;
        _kol := 0;
        for i := _f + 7 to _l - 1 do
        begin
          case s[i] of
            '=':
              inc(_kol);
            '>', '<', '"', '''':
              break;
          else
            if (_kol > 0) and not (s[i] in [' ', #13, #10, #9]) then
              cpname := cpname + s[i];
          end;
        end;
        result := checkCPFromText(cpname, result);
      end;
    end
    else
      result := false;
  end;
end;

// Detects BOM (Byte Order Mark) of a text stream


//    UTF-8:    EF BB BF
//    UTF-16BE: FE FF     (00 SS)
//    UTF-16LE: FF FE     (SS 00) - windows
//    UTF-32BE: 00 00 FE FF
//    UTF-32LE: FF FE 00 00
//INPUT

function RecognizeBOM(var txt: ansistring): integer;
var
  ltxt: integer;
begin
  result := 0;
  //    BOM:

  //            1 - UTF-8
  //            2 - UTF-16BE
  //            3 - UTF-16LE
  //            4 - UTF-32BE
  //            5 - UTF-32LE
  ltxt := length(txt);
  if ltxt >= 2 then
  begin

    case txt[1] of
      #239: //UTF-8?
        begin
          if ltxt >= 3 then
            if (txt[2] = #187) and (txt[3] = #191) then
              result := 1;
        end;
      #254: //UTF-16BE?
        begin
          if txt[2] = #255 then
            result := 2;
        end;
      #255: //UTF-16LE/UTF-32LE?
        begin
          if txt[2] = #254 then
          begin
            result := 3;
            if ltxt >= 4 then
            begin

              if (txt[3] = #0) and (txt[4] = #0) then
                result := 5;
            end;
          end;
        end;
      #0:   //UTF-32BE?
        begin
          if ltxt >= 4 then
            if (txt[2] = #0) and (txt[3] = #254) and (txt[4] = #255) then
              result := 4;
        end;
    end;
  end;
end;

// Detects encoding of XML/HTML text including BOM
// (will attempt to detect)
//INPUT
//    txt: ansistring     - text to analyze
//OUTPUT

//    cpfromtext: integer - detected encoding index from text declaration
//                            0 - undetermined
//                            1 - UTF-8
//                            2 - UTF-16BE
//                            3 - UTF-16LE
//                            4 - UTF-32BE
//                            5 - UTF-32LE
//                            6 - Windows-1251
//                            7 - CP866
//    cpname: ansistring  - encoding name found in text declaration
//    ftype: integer      - file type:
//                            0 - unknown
//                            1 - xml
//                            2 - html
// RETURN: boolean - true if encoding was confidently identified
//                   false if encoding detection is uncertain
function RecognizeEncodingXML(var txt: ansistring; out BOM: integer; out cpfromtext: integer; out cpname: ansistring; out ftype: integer): boolean; overload;
var
  t: integer;
begin
  BOM := RecognizeBOM(txt);
  t := 1;
  case BOM of
    1:
      t := 4;    //utf-8
    2, 3:
      t := 3; //utf-16
    4, 5:
      t := 5; //utf-32
  end;
  result := RecognizeEncodingXML(t, txt, cpfromtext, cpname, ftype);
end;

////::::::::::::: TZAttributes :::::::::::::::::////

constructor TZAttributes.Create();
begin
  inherited;
  FMaxCount := 15;
  SetLength(FItems, FMaxCount);
end;

destructor TZAttributes.Destroy();
begin
  SetLength(FItems, 0);
  FItems := nil;
  inherited;
end;


//INPUT

procedure TZAttributes.ResizeItemsArray(NewSize: integer);
var
  delta: integer;
begin
//  delta := 0;
  if (NewSize >= FMaxCount) then
  begin
    delta := NewSize;
    if (NewSize < 50) then
      delta := delta * 4
    else if (NewSize < 100) then
      delta := delta * 2
    else
      delta := delta + 20;
    SetLength(FItems, delta);
  end
  else if (NewSize > 50) then
  begin
    if (FMaxCount - NewSize > 200) then
    begin
      delta := NewSize + 100;
      SetLength(FItems, delta);
    end;
  end;
//  if (delta > 0) then
//    SetLength(FItems, delta);
end; //ResizeItemsArray

procedure TZAttributes.Clear();
begin
  FCount := 0;
  ResizeItemsArray(0);
end;

function TZAttributes.GetAttrS(const Att: ansistring): ansistring;
var
  i: integer;
begin
  result := '';
  for i := 0 to FCount - 1 do
    if FItems[i][0] = Att then
    begin
      result := FItems[i][1];
      break;
    end;
end;

procedure TZAttributes.SetAttrS(const Att: ansistring; const Value: ansistring);
begin
  Add(Att, Value, true);
end;

function TZAttributes.GetAttrI(num: integer): ansistring;
begin
  result := '';
  if (num >= 0) and (num < FCount) then
    result := FItems[num][1];
end;

procedure TZAttributes.SetAttrI(num: integer; const Value: ansistring);
begin
  if (num >= 0) and (num < FCount) then
    FItems[num][1] := Value;
end;

function TZAttributes.GetAttr(num: integer): TZAttrArray;
begin
  result[0] := '';
  result[1] := '';
  if (num >= 0) and (num < FCount) then
    result := FItems[num];
end;

procedure TZAttributes.SetAttr(num: integer; const Value: TZAttrArray);
begin
  if (num >= 0) and (num < FCount) then
    FItems[num] := Value;
end;

procedure TZAttributes.DeleteItem(Index: integer);
var
  i: integer;
begin
  if (Index >= 0) and (Index < Count) then
  begin
    for i := Index to Count - 2 do
      FItems[i] := FItems[i + 1];
    dec(FCount);
    ResizeItemsArray(FCount);
  end;
end;

procedure TZAttributes.Insert(Index: integer; const AttrName: ansistring; const Value: ansistring; TestMatch: boolean = true);
var
  i: integer;
begin
  if TestMatch then
  begin
    for i := 0 to FCount - 1 do
      if FItems[i][0] = AttrName then
      begin
        FItems[i][1] := Value;
        exit;
      end;
  end;
  if (Index >= 0) and (Index < Count) then
  begin
    inc(FCount);
    ResizeItemsArray(FCount);
    for i := FCount - 2 downto Index do
      FItems[i + 1] := FItems[i];
    FItems[Index][0] := AttrName;
    FItems[Index][1] := Value;
  end
  else if Count = 0 then
    Add(AttrName, Value, TestMatch);
end;

procedure TZAttributes.Insert(Index: integer; const Attr: TZAttrArray; TestMatch: boolean = true);
begin
  Insert(Index, Attr[0], Attr[1], TestMatch);
end;


//  Input

procedure TZAttributes.Add(const AttrName: ansistring; const Value: ansistring; TestMatch: boolean = true);
var
  i: integer;
begin
  if length(AttrName) = 0 then
    exit;
  if TestMatch then
  begin
    for i := 0 to FCount - 1 do
      if FItems[i][0] = AttrName then
      begin
        FItems[i][1] := Value;
        exit;
      end;
  end;
  ResizeItemsArray(FCount + 1);
  FItems[FCount][0] := AttrName;
  FItems[FCount][1] := Value;
  inc(FCount);
end;


//  Input

procedure TZAttributes.Add(const Attr: TZAttrArray; TestMatch: boolean = true);
begin
  Add(Attr[0], Attr[1], TestMatch);
end;


//  Input

procedure TZAttributes.Add(Att: array of TZAttrArray; TestMatch: boolean = true);
var
  i: integer;
begin
  for i := low(Att) to High(Att) do
    Add(Att[i], TestMatch);
end;

function TZAttributes.ToString(quote: ansichar; CheckEntity: boolean; addempty: boolean): ansistring;
var
  i: integer;
begin
  if (quote <> '"') and (quote <> '''') then
    quote := '"';
  result := '';
  if CheckEntity then
  begin

    for i := 0 to Count - 1 do
      if (length(FItems[i][1]) > 0) or (addempty) then
        result := result + ' ' + FItems[i][0] + '=' + quote + CheckStrEntity(FItems[i][1]) + quote;
  end
  else
  begin
    for i := 0 to Count - 1 do
      if (length(FItems[i][1]) > 0) or (addempty) then
        result := result + ' ' + FItems[i][0] + '=' + quote + FItems[i][1] + quote;
  end;
end;

function TZAttributes.ToString(quote: ansichar; CheckEntity: boolean): ansistring;
begin
  result := ToString(quote, CheckEntity, true);
end;

function TZAttributes.ToString(quote: ansichar): ansistring;
begin
  result := ToString(quote, true);
end;

function TZAttributes.ToString(CheckEntity: boolean): ansistring;
begin
  result := ToString('"', CheckEntity);
end;

function TZAttributes.ToString(): ansistring;
begin
  result := ToString('"', true);
end;

{$WARN IMPLICIT_STRING_CAST OFF}
function TZAttributes.IsContainsAttribute(const AttrName: ansistring; CaseSensitivity: boolean = true): boolean;
var
  i: integer;
  s: string;
begin
  Result := false;
  if (not CaseSensitivity) then
    s := UpperCase(AttrName)
  else
    s := AttrName;

  for i := 0 to FCount - 1 do
  begin
    if (CaseSensitivity) then
    begin
      if (FItems[i][1] = s) then
        Result := true;
    end
    else if (UpperCase(FItems[i][1]) = s) then
      Result := true;

    if (Result) then
      break;
  end;
end;

procedure TZAttributes.Assign(Source: TPersistent);
var
  t: TZAttributes;
  i: integer;
begin
  if Source is TZAttributes then
  begin
    t := Source as TZAttributes;
    //Clear();
    FCount := t.Count;
    ResizeItemsArray(FCount + 1);
    for i := 0 to t.Count - 1 do
      FItems[i] := t.Items[i];
      //Add(t.items[i][0], t.items[i][1], false);
  end
  else
    inherited Assign(Source);
end;

////::::::::::::: TZsspXMLWriter :::::::::::::::::////

constructor TZsspXMLWriter.Create();
begin
  inherited;
  FAttributeQuote := '"';
  FBuffer := '';
  FMaxBufferLength := 4096;
  FInProcess := false;
  FNewLine := False;
  FUnixNLSeparator := false;
  FTabLength := 0;
  FTab := '';
  FTabSymbol := ' ';
  FNLSeparator := #13#10;
  FAttributes := TZAttributes.Create();
  FMaxTagCount := 20;
  SetLength(FTags, FMaxTagCount);
end;

destructor TZsspXMLWriter.Destroy();
begin

  if InProcess then
    EndSaveTo();
  setlength(FTags, 0);
  FTags := nil;
  FreeAndNil(FAttributes);
  inherited;
end;


//INPUT

procedure TZsspXMLWriter.ResizeTagArray(NewSize: integer);
var
  delta: integer;
begin
  delta := 0;
  if (NewSize >= FMaxTagCount) then
  begin
    delta := NewSize;
    if (NewSize < 50) then
      delta := delta * 4
    else if (NewSize < 100) then
      delta := delta * 2
    else
      delta := delta + 20;
  end
  else if (NewSize > 50) then
  begin
    if (FMaxTagCount - NewSize > 200) then
      delta := NewSize + 100;
  end;
  if (delta > 0) then
    SetLength(FTags, delta);
end; //ResizeTagArray

procedure TZsspXMLWriter.SetAttributes(Value: TZAttributes);
begin
  if Value <> nil then
    FAttributes.Assign(Value);
end;

function TZsspXMLWriter.GetTag(num: integer): ansistring;
begin
  if (num >= 0) and (num < TagCount) then
    result := FTags[num].Name
  else
    result := '';
end;

procedure TZsspXMLWriter.SetAttributeQuote(Value: ansichar);
begin
  if (Value = '''') or (Value = '"') then
    FAttributeQuote := Value;
end;

procedure TZsspXMLWriter.SetMaxBufferLength(Value: integer);
begin
  if Value > 0 then
    if not InProcess then
      FMaxBufferLength := Value;
end;

procedure TZsspXMLWriter.SetTabLength(Value: integer);
var
  i: integer;
begin
  if Value > 0 then
    if not InProcess then
    begin
      FTabLength := Value;
      FTab := '';
      for i := 1 to FTabLength do
        FTab := FTab + FTabSymbol;
    end;
end;


//  Input
//           Value: boolean

procedure TZsspXMLWriter.SetNewLine(Value: boolean);
begin
  if not InProcess then
    FNewLine := Value;
end;

procedure TZsspXMLWriter.SetUnixNLSeparator(Value: boolean);
begin
  if not InProcess then
  begin
    FUnixNLSeparator := Value;
    if Value then
      FNLSeparator := #10
    else
      FNLSeparator := #13#10;
  end;
end;

procedure TZsspXMLWriter._AddTag(const _begin: ansistring; Text: ansistring; const _end: ansistring; StartNewLine: boolean; _tab: integer = 0);
begin
  if not FInProcess then
    exit;
  Text := _begin + Text + _end;
  if StartNewLine and NewLine then
    Text := FNLSeparator + GetTab(_tab) + Text;
  AddText(Text);
end;


//  Input:

procedure TZsspXMLWriter.WriteCDATA(CDATA: ansistring; CorrectCDATA: boolean; StartNewLine: boolean = true);
var
  p: integer;
begin
  if CorrectCDATA then
  begin
    p := DUAnsiPos(']]>', CDATA);
    while p <> 0 do
    begin
      delete(CDATA, p, 3);
      insert(']]&gt;', CDATA, p);
      p := DUAnsiPos(']]>', CDATA);
    end;
  end;
  _AddTag('<![CDATA[', CDATA, ']]>', StartNewLine);
end;


//  Input:

procedure TZsspXMLWriter.WriteCDATA(const CDATA: ansistring);
begin
  WriteCDATA(CDATA, true, true);
end;


//  Input:

procedure TZsspXMLWriter.WriteComment(const Comment: ansistring; StartNewLine: boolean = true);
begin
  _AddTag('<!-- ', Comment, ' -->', StartNewLine);
end;


//  Input:

procedure TZsspXMLWriter.WriteRaw(Text: ansistring; UseConverter: boolean; StartNewLine: boolean = true);
begin
  if not FInProcess then
    exit;
  if StartNewLine and NewLine then
    Text := FNLSeparator + Text;
  AddText(Text, UseConverter);
end;


//  Input:

//  Output:

function TZsspXMLWriter.BeginSaveToStream(Stream: TStream): boolean;
begin
  if FInProcess then
  begin
    result := false;
  end
  else if Stream <> nil then
  begin
    FBuffer := '';
    FStream := Stream;
    FInProcess := true;
    if FDestination = 111 then
      FDestination := 1
    else
      FDestination := 0;
    result := true;
  end
  else
  begin
    FInProcess := false;
    result := false;
  end;
end;


//  Input:

//  Output:

function TZsspXMLWriter.BeginSaveToFile(const FileName: string): boolean;
var
  Stream: TStream;
begin
  if InProcess then
    result := false
  else
  try
    Stream := TFileStream.Create(FileName, fmCreate);
    FDestination := 111;
    result := BeginSaveToStream(Stream);
  except
    FInProcess := false;
    FreeAndNil(Stream);
    result := false;
  end;
end;



//  Output:

//           false - O_o
function TZsspXMLWriter.BeginSaveToString(): boolean;
begin
  if FInProcess then
  begin
    result := false;
  end
  else
  begin
    FDestination := 2;
    FBuffer := '';
    FInProcess := true;
    result := true;
  end;
end;

procedure TZsspXMLWriter.EndSaveTo();
begin
  while TagCount > 0 do
    WriteEndTagNode();
  if NewLine then
    AddText(FNLSeparator, true);
  FlushBuffer();
  if FDestination = 1 then
    FStream.Free();
  FStream := nil;
  FInProcess := false;
end;

procedure TZsspXMLWriter.FlushBuffer();
begin
  if not FInProcess then
    exit;
  if FStream <> nil then
    if FDestination <> 2 then
    begin
      FStream.WriteBuffer(Pointer(FBuffer)^, Length(FBuffer));
      FBuffer := '';
    end;
end;

procedure TZsspXMLWriter.SetTextConverter(Value: TAnsiToCPConverter);
begin
  if not InProcess then
    FTextConverter := Value;
end;


//  Input:

procedure TZsspXMLWriter.WriteTag(const TagName: ansistring; const Text: ansistring; AttrArray: array of TZAttrArray; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
var
  t: TZAttributes;
begin
  t := TZAttributes.Create();
  try
    t.Add(AttrArray, true);
    WriteTag(TagName, Text, t, StartNewLine, CloseTagNewLine, CheckEntity);
  finally
    FreeAndNil(t);
  end;
end;


//  Input:

procedure TZsspXMLWriter.WriteTag(const TagName: ansistring; const Text: ansistring; SAttributes: TZAttributes; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
var
  s: ansistring;
begin
  if not FInProcess then
    exit;
  WriteTagNode(TagName, SAttributes, StartNewLine, CloseTagNewLine, CheckEntity);
  s := Text;
  if CheckEntity then
    s := CheckStrEntity(Text);
  WriteRaw(s, true, CloseTagNewLine);
  WriteEndTagNode();
end;


//  Input:

procedure TZsspXMLWriter.WriteTag(const TagName: ansistring; const Text: ansistring; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
begin
  WriteTag(TagName, Text, Attributes, StartNewLine, CloseTagNewLine, CheckEntity);
end;


// StartNewLine = true, CloseTagNewLine = false, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteTag(const TagName: ansistring; const Text: ansistring; SAttributes: TZAttributes);
begin
  WriteTag(TagName, Text, SAttributes, true, false, true);
end;


// StartNewLine = true, CloseTagNewLine = false, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteTag(const TagName: ansistring; const Text: ansistring; AttrArray: array of TZAttrArray);
var
  t: TZAttributes;
begin
  t := TZAttributes.Create();
  try
    t.Add(AttrArray, true);
    WriteTag(TagName, Text, t, true, false, true);
  finally
    FreeAndNil(t);
  end;
end;


// StartNewLine = true, CloseTagNewLine = false, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteTag(const TagName: ansistring; const Text: ansistring);
begin
  WriteTag(TagName, Text, Attributes, true, false, true);
end;


// StartNewLine = true, CloseTagNewLine = false, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteTagNode(const TagName: ansistring; SAttributes: TZAttributes);
begin
  WriteTagNode(TagName, SAttributes, true, false, true);
end;


// StartNewLine = true, CloseTagNewLine = false, CheckEntity = true);
//  Input:

procedure TZsspXMLWriter.WriteTagNode(const TagName: ansistring; AttrArray: array of TZAttrArray);
begin
  WriteTagNode(TagName, AttrArray, true, false, true);
end;


// StartNewLine = true, CloseTagNewLine = false, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteTagNode(const TagName: ansistring);
begin
  WriteTagNode(TagName, Attributes, true, false, true);
end;


//  Input:

procedure TZsspXMLWriter.WriteTagNode(const TagName: ansistring; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
begin
  WriteTagNode(TagName, Attributes, StartNewLine, CloseTagNewLine, CheckEntity);
end;


//  Input:

procedure TZsspXMLWriter.WriteTagNode(const TagName: ansistring; SAttributes: TZAttributes; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
var
  s: ansistring;
begin
  if not FInProcess then
    exit;
  s := '';
  if FNewLine and StartNewLine then
  begin
    s := s + FNLSeparator;
    s := s + GetTab();
  end;
  s := s + '<' + TagName;
  if SAttributes <> nil then
    if SAttributes.Count > 0 then
      s := s + SAttributes.ToString(FAttributeQuote, CheckEntity);
  s := s + '>';
  AddText(s);
  AddNode(TagName, CloseTagNewLine);
end;


//  Input:

procedure TZsspXMLWriter.WriteTagNode(const TagName: ansistring; AttrArray: array of TZAttrArray; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
var
  t: TZAttributes;
begin
  t := TZAttributes.Create();
  try
    t.Add(AttrArray, true);
    WriteTagNode(TagName, t, StartNewLine, CloseTagNewLine, CheckEntity);
  finally
    FreeAndNil(t);
  end;
end;

procedure TZsspXMLWriter.WriteEndTagNode();
begin
  if not FInProcess then
    exit;
  if TagCount > 0 then
  begin
    _AddTag('</', FTags[TagCount - 1].Name, '>', FTags[TagCount - 1].CloseTagNewLine, -1);
    Dec(FTagCount);
    ResizeTagArray(FTagCount);
  end;
end;


//INPUT

//      CloseTagNewLine: boolean  -
procedure TZsspXMLWriter.WriteEndTagNode(isForce: boolean; CloseTagNewLine: boolean);
var
  b: boolean;
begin
  if not FInProcess then
    exit;
  if TagCount > 0 then
  begin
    b := FTags[TagCount - 1].CloseTagNewLine;
    if (isForce) then
      b := CloseTagNewLine;
    _AddTag('</', FTags[TagCount - 1].Name, '>', b, -1);
    Dec(FTagCount);
    ResizeTagArray(FTagCount);
  end;
end;


//  Input:

procedure TZsspXMLWriter.WriteEmptyTag(const TagName: ansistring; SAttributes: TZAttributes; StartNewLine: boolean; CheckEntity: boolean = true);
begin
  _AddTag('<' + TagName, SAttributes.ToString(AttributeQuote, CheckEntity), '/>', StartNewLine)
end;


//  Input:

procedure TZsspXMLWriter.WriteEmptyTag(const TagName: ansistring; AttrArray: array of TZAttrArray; StartNewLine: boolean; CheckEntity: boolean = true);
var
  t: TZAttributes;
begin
  t := TZAttributes.Create();
  try
    t.Add(AttrArray, true);
    WriteEmptyTag(TagName, t, StartNewLine, CheckEntity);
  finally
    FreeAndNil(t);
  end;
end;


//  Input:

procedure TZsspXMLWriter.WriteEmptyTag(const TagName: ansistring; StartNewLine: boolean; CheckEntity: boolean = true);
begin
  WriteEmptyTag(TagName, Attributes, StartNewLine, CheckEntity);
end;


//StartNewLine = true, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteEmptyTag(const TagName: ansistring; SAttributes: TZAttributes);
begin
  WriteEmptyTag(TagName, SAttributes, true, true);
end;


//StartNewLine = true, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteEmptyTag(const TagName: ansistring; AttrArray: array of TZAttrArray);
begin
  WriteEmptyTag(TagName, AttrArray, true, true);
end;


//StartNewLine = true, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteEmptyTag(const TagName: ansistring);
begin
  WriteEmptyTag(TagName, Attributes, true, true);
end;

procedure TZsspXMLWriter.AddText(const Text: ansistring; Useconverter: boolean = true);
var
  b: boolean;
begin
  b := false;
  if Useconverter then
    if Assigned(TextConverter) then
      b := true;
  if (b) then
    FBuffer := Fbuffer + TextConverter(Text)
  else
    FBuffer := FBuffer + Text;
  if FDestination <> 2 then
    if Length(FBuffer) >= MaxBufferLength then
      FlushBuffer;
end;


//  Input:

function TZsspXMLWriter.GetTab(num: integer = 0): ansistring;
var
  i: integer;
begin
  result := '';
  for i := 1 to TagCount + num do
    result := result + FTab;
end;


//  Input:

procedure TZsspXMLWriter.AddNode(const TagName: ansistring; CloseTagNewLine: boolean);
begin
  ResizeTagArray(FTagCount + 1);
  FTags[FTagCount].Name := TagName;
  FTags[FTagCount].CloseTagNewLine := CloseTagNewLine;
  inc(FTagCount);
end;

function TZsspXMLWriter.GetTabSymbol(): ansichar;
begin
  result := #0;
  if length(FTabSymbol) >= 1 then
    result := FTabSymbol[1];
end;

procedure TZsspXMLWriter.SetTabSymbol(Value: ansichar);
begin
  if not InProcess then
    if (Value = #9) or (Value = #32) then
    begin
      FTabSymbol := Value;
      SetTabLength(TabLength);
    end;
end;


//  Input:

procedure TZsspXMLWriter.WriteInstruction(const InstructionName: ansistring; SAttributes: TZAttributes; StartNewLine: boolean; CheckEntity: boolean = true);
begin
  _AddTag('<?' + InstructionName, SAttributes.ToString(AttributeQuote, CheckEntity), '?>', StartNewLine)
end;


//  Input:

procedure TZsspXMLWriter.WriteInstruction(const InstructionName: ansistring; AttrArray: array of TZAttrArray; StartNewLine: boolean; CheckEntity: boolean = true);
var
  t: TZAttributes;
begin
  t := TZAttributes.Create();
  try
    t.Add(AttrArray, true);
    WriteInstruction(InstructionName, t, StartNewLine, CheckEntity);
  finally
    FreeAndNil(t);
  end;
end;


//  Input:

procedure TZsspXMLWriter.WriteInstruction(const InstructionName: ansistring; StartNewLine: boolean; CheckEntity: boolean = true);
begin
  WriteInstruction(InstructionName, Attributes, StartNewLine, CheckEntity);
end;


//StartNewLine = true, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteInstruction(const InstructionName: ansistring; SAttributes: TZAttributes);
begin
  WriteInstruction(InstructionName, SAttributes, true, true);
end;


//StartNewLine = true, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteInstruction(const InstructionName: ansistring; AttrArray: array of TZAttrArray);
begin
  WriteInstruction(InstructionName, AttrArray, true, true);
end;


//StartNewLine = true, CheckEntity = true
//  Input:

procedure TZsspXMLWriter.WriteInstruction(const InstructionName: ansistring);
begin
  WriteInstruction(InstructionName, Attributes, true, true);
end;

////::::::::::::: TZsspXMLReader :::::::::::::::::////

constructor TZsspXMLReader.Create();
begin
  inherited Create();
  FAttributes := TZAttributes.Create();
  FMaxBufferLength := 4096;
  FBuffer := '';
  ClearAll();
  FIgnoreCase := false;
  FQuotesEqual := false;
  FMaxTagCount := 20;
  FAttributesMatch := true;
  SetLength(FTags, FMaxTagCount);
end;

destructor TZsspXMLReader.Destroy();
begin
  EndRead();
  FreeAndNil(FAttributes);
  SetLength(FTags, 0);
  FTags := nil;
  inherited Destroy();
end;


//INPUT

procedure TZsspXMLReader.ResizeTagArray(NewSize: integer);
var
  delta: integer;
begin
  delta := 0;
  if (NewSize >= FMaxTagCount) then
  begin
    delta := NewSize;
    if (NewSize < 50) then
      delta := delta * 4
    else if (NewSize < 100) then
      delta := delta * 2
    else
      delta := delta + 20;
  end
  else if (NewSize > 50) then
  begin
    if (FMaxTagCount - NewSize > 200) then
      delta := NewSize + 100;
  end;
  if (delta > 0) then
    SetLength(FTags, delta);
end; //ResizeTagArray

procedure TZsspXMLReader.SetAttributesMatch(Value: boolean);
begin
  if (not FInProcess) then
    FAttributesMatch := Value;
end;

function TZsspXMLReader.Eof(): boolean;
begin
  result := false;
  if InProcess then
  begin
    if FPFirst > FPLast then
    begin
      ReadBuffer();
      if FPFirst > FPLast then
        result := true;
    end;
  end
  else
    result := true;
end;

procedure TZsspXMLReader.SetQuotesEqual(Value: boolean);
begin
  if (not InProcess) then
    FQuotesEqual := Value;
end;

function TZsspXMLReader.GetTag(num: integer): ansistring;
begin
  if (num >= 0) and (num < TagCount) then
    result := FTags[num]
  else
    result := '';
end;

procedure TZsspXMLReader.SetMaxBufferLength(Value: integer);
begin
  if Value > 513 then
    if not InProcess then
    begin
      FMaxBufferLength := Value;
      SetString(FBuffer, nil, FMaxBufferLength);
      //SetLength(FBuffer, FMaxBufferLength);
      //FPFirst := 0;
      //FPlast := 0;
    end;
end;


//Input:

//Output:



//                      3 - Stream = nil
function TZsspXMLReader.BeginReadFile(FileName: string): integer;
var
  Stream: TStream;
begin
  if InProcess then
    result := 1
  else
  begin
    result := 0;
    Stream := nil;
    try
      try
        Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      except
        result := 2;
      end;
      if result = 0 then
      begin
        FSourceType := 111;
        result := BeginReadStream(Stream);
      end;
    finally
    //  if Stream <> nil then
   //     Stream.Free;
    end;
  end;
end;


//Input:

//Output:



//                      3 - Stream = nil
function TZsspXMLReader.BeginReadStream(Stream: TStream): integer;
var
  s: ansistring;
begin
  if InProcess then
    result := 1
  else
  begin
    result := 0;
    try
      FStream := Stream;
    except
      result := 2;
    end;
    if FStream = nil then
      result := 3;
    if result = 0 then
    begin
      FInProcess := true;
      if FSourceType = 111 then
        FSourceType := 1
      else
        FSourceType := 2;
      ClearAll();
      ReadBuffer();

      s := copy(FBuffer, 1, FPlast);
      RecognizeEncoding(s);
    end;
  end;
end;


//Input:


//Output:



//                      3 - Stream = nil
function TZsspXMLReader.BeginReadString(Source: ansistring; IgnoreCodePage: boolean = true): integer;
begin
  if InProcess then
    result := 1
  else
  begin
    FBuffer := Source;
    FInProcess := true;
    FSourceType := 3;
    result := 0;
    ClearAll();
  end;
end;

procedure TZsspXMLReader.EndRead();
begin
  if InProcess then
  begin
    FInProcess := false;
    //if FSourceType = 1 then
    //FStream := nil;
    if FSourceType = 1 then
      FreeAndNil(FStream);
  end;
end;

procedure TZsspXMLReader.Clear();
begin
  FTextBeforeTag := '';
  FRawTextTag := '';
  FTagName := '';
  FTagType := TAG_TYPE_UNKNOWN;
  FValue := '';
  FErrorCode := 0;
  FAttributes.Clear();
end;

procedure TZsspXMLReader.ClearAll();
var
  t: integer;
begin
  Clear();
  if FSourceType <> 3 then
    SetString(FBuffer, nil, MaxBufferLength)
  else
  begin
    t := Length(FBuffer);
    if t > 0 then
    begin
      MaxBufferLength := t;
      FPFirst := 1;
      FPLast := t;
    end;
  end;
  FTagCount := 0;
  ResizeTagArray(0);
  FStreamEnd := false;
end;

procedure TZsspXMLReader.GetOneChar(var OneChar: ansistring; var err: boolean);
begin
  err := false;
  OneChar := '';
  if FPFirst <= FPLast then
  begin
    OneChar := FBuffer[FPFirst];
    inc(FPFirst);
  end
  else
  begin
    ReadBuffer();
    if FPFirst <= FPLast then
    begin
      OneChar := FBuffer[FPFirst];
      inc(FPFirst);
    end
    else
      err := true;
  end;
end;

procedure TZsspXMLReader.ReadBuffer();
var
  t: integer;
begin
  if InProcess then
    if (FSourceType = 1) or (FSourceType = 2) then
    begin
      t := 0;
    //SetString(FBuffer, nil, MaxBufferLength);
      if Assigned(FStream) and (not FStreamEnd) then
      begin
        t := FStream.Read(Pointer(FBuffer)^, MaxBufferLength);
        if t < MaxBufferLength then
          FStreamEnd := true;
      end;
      if t >= 1 then
      begin
        FPFirst := 1;
        FPLast := t;
      end
      else
      begin
        FPFirst := 1;
        FPLast := 0;
      end;
    end;
end;



//INPUT:

procedure TZsspXMLReader.RecognizeEncoding(var txt: ansistring);
var
  BOM: integer;
  cpname: ansistring;
  recognized: boolean;
  codepagenum: integer;
  ftype: integer;
begin

  //    codepagenum:

  //            1 - UTF-8
  //            2 - UTF-16BE
  //            3 - UTF-16LE
  //            4 - UTF-32BE
  //            5 - UTF-32LE
  //            6 - Windows-1251
  //            7 - CP866
  recognized := RecognizeEncodingXML(txt, BOM, codepagenum, cpname, ftype);
  if recognized then
  begin
    FCharReader := nil;
    case codepagenum of
      1:
        begin
          FCharReader := @ReadCharUTF8;
          FCharConverter := @conv_UTF8ToLocal;
          if BOM = 1 then
            self.FPFirst := 4;
        end;
      2:
        begin
          FCharReader := @ReadCharUTF16BE;
          FCharConverter := @conv_UTF16BEToLocal;
          if BOM = 2 then
            self.FPFirst := 3;
        end;
      3:
        begin
          FCharReader := @ReadCharUTF16LE;
          FCharConverter := @conv_UTF16LEToLocal;
          if BOM = 3 then
            self.FPFirst := 3;
        end;
      4:
        begin
          FCharReader := @ReadCharUTF32;
          FCharConverter := @conv_UTF32BEToLocal;
        end;
      5:
        begin
          FCharReader := @ReadCharUTF32;
          FCharConverter := @conv_UTF32LEToLocal;
        end;
      6:
        FCharConverter := @conv_WIN1251ToLocal;
      7:
        FCharConverter := @conv_CP866ToLocal;
    end;
  end
  else
  begin
    {tut}
    FCharReader := nil;
    case codepagenum of
      1:
        begin
          FCharReader := @ReadCharUTF8;
          FCharConverter := @conv_UTF8ToLocal;
          if BOM = 1 then
            self.FPFirst := 4;
        end;
      2:
        begin
          FCharReader := @ReadCharUTF16BE;
          FCharConverter := @conv_UTF16BEToLocal;
          if BOM = 2 then
            self.FPFirst := 3;
        end;
      3:
        begin
          FCharReader := @ReadCharUTF16LE;
          FCharConverter := @conv_UTF16LEToLocal;
          if BOM = 3 then
            self.FPFirst := 3;
        end;
      4:
        begin
          FCharReader := @ReadCharUTF32;
          FCharConverter := @conv_UTF32BEToLocal;
        end;
      5:
        begin
          FCharReader := @ReadCharUTF32;
          FCharConverter := @conv_UTF32LEToLocal;
        end;
      6:
        FCharConverter := @conv_WIN1251ToLocal;
      7:
        FCharConverter := @conv_CP866ToLocal;
    end;
  end;
end;

function TZsspXMLReader.ReadTag(): boolean;
var
  Ch: ansistring;
  ss: ansistring;
  err: boolean;
  RawEncodingBeforeTag: ansistring;
  RawTextTagNonDecoded: ansistring;
  end_tag: boolean;
  _isClosedTag: boolean;
  _isInstruction: boolean;

  procedure _get_char();
  begin
    if assigned(FCharReader) then
      FCharReader(GetOneChar, Ch, err)
    else
      GetOneChar(Ch, err);
    if err then
      exit;
    if Assigned(FCharConverter) then
      ss := FCharConverter(Ch)
    else
      ss := Ch;
  end;

  procedure RawTag();
  begin
    RawTextTagNonDecoded := RawTextTagNonDecoded + Ch;
    if ss[1] <> #0 then
      FRawTextTag := FRawTextTag + ss;
  end;

  function GetParamValue(): ansistring;
  var
    count_quote: byte;
    _openquote: ansistring;
  begin
    count_quote := 0;
    result := '';
    while true do
    begin
      _get_char();
      if err then
        break;
      if length(ss) >= 1 then
      begin
        RawTag();
        case ss[1] of
          ' ', #13, #10, #9:
            begin
              if count_quote = 1 then
                result := result + ss[1]
              else if length(result) > 0 then
              begin
                FErrorCode := FErrorCode or 1;
                break;
              end
            end;
          '>':
            begin
              if count_quote = 1 then
                result := result + ss[1]  //tut
              else
              begin
                if length(result) > 0 then
                  FErrorCode := FErrorCode or 1
                else
                  FErrorCode := FErrorCode or 2;
                end_tag := true;
                break;
              end;
            end;
          '=':
            begin
              if count_quote = 1 then
                result := result + ss[1]
              else
              begin
                if length(result) > 0 then
                  FErrorCode := FErrorCode or 4
                else
                  FErrorCode := FErrorCode or 2;
                break;
              end;
            end;
          '?':
            begin
              if count_quote = 1 then
                result := result + ss[1]
              else
              begin
                if length(result) > 0 then
                  _isInstruction := true
                else
                  FErrorCode := FErrorCode or 1024;
                break;
              end;
            end;
          '/':
            begin
              if count_quote = 1 then
                result := result + ss[1]
              else
              begin
                if length(result) > 0 then
                  _isClosedTag := true
                else
                  FErrorCode := FErrorCode or 8;
                break;
              end;
            end;
          '<':
            begin
              if count_quote = 1 then
                result := result + ss
              else

                FErrorCode := FErrorCode or 32;
            end;
          '"', '''':
            begin
              if count_quote = 0 then
              begin
                if length(result) > 0 then // <tag ... param = value"...>
                begin
                  FErrorCode := FErrorCode or 16;
                  break;
                end
                else
                begin
                  _openquote := ss[1];
                  inc(count_quote);
                end;
              end
              else
              begin
                if (QuotesEqual or (ss[1] = _openquote)) then
                  break
                else
                  result := result + ss;
              end;
            end;
        else
          result := result + ss;
        end;
      end; //if
    end;  //while
  end;

  procedure Delete2end(var svalue: ansistring);
  var
    t: integer;
  begin
    t := length(svalue);
    if t >= 2 then
      delete(svalue, t - 1, 2);
  end;

  function GetCommentCDATA(): integer;
  var
    _type_comment: integer;
    _tmp: integer;
    _last2: ansistring;
    s, sl: ansistring;
  begin
    setlength(_last2, 2);
    _last2[1] := #0;
    _last2[2] := #0;
    _type_comment := 0;
    s := '';
    sl := '';
    while true do
    begin
      if end_tag then
        break;
      _get_char();
      if err then
        break;
      if length(ss) >= 1 then
      begin
        RawTag();
        case ss[1] of
          '>':
            begin
              case _type_comment of
                -1:
                  begin
                    end_tag := true;
                    break;
                  end;
                0:   // O_o <!ta>...
                  begin
                    end_tag := true;
                    FErrorCode := FErrorCode or 128;
                    break;
                  end;
                1:   // <!--...-->
                  begin
                    if _last2 = '--' then
                    begin
                      delete2end(FValue);
                      end_tag := true;
                      break;
                    end
                    else
                      FValue := FValue + ss;
                  end;
                2:   // <![CDATA[...]]>
                  begin
                    if _last2 = ']]' then
                    begin
                      delete2end(FValue);
                      end_tag := true;
                      break;
                    end
                    else
                      FValue := FValue + ss;
                  end;
              end;
            end;
        else
          begin
            if _type_comment <> 0 then
              FValue := FValue + ss
            else
            begin
              _tmp := length(s);
              if _tmp = 2 then
              begin
                if s = '--' then
                begin
                  _type_comment := 1;
                  FValue := FValue + ss;
                end
                else
                  s := s + UTF8Encode(UpperCase(UTF8ToString(AnsiString(ss[1]))));
              end
              else if _tmp = 7 then
              begin
                if s = '[CDATA[' then
                begin
                  _type_comment := 2;
                  FValue := FValue + ss;
                end
                else
                begin
                  FErrorCode := FErrorCode or 128;
                  _type_comment := -1;
                  FValue := sl + ss;
                end;
                  //FValue := FValue + ss;
              end
              else
              begin
                s := s + UTF8Encode(UpperCase(UTF8ToString(AnsiString(ss[1]))));
                sl := sl + ss[1];
              end;
            end;
          end; //else
        end;    //case

        //'-->' ']]>'
        _last2[2] := _last2[1];
        _last2[1] := ss[1];
      end;
    end;
    result := _type_comment;
  end;

  procedure CheckClose(var some_par: boolean; err_code: integer);
  begin
    if some_par then
    begin
      if not (ss[1] in [' ', #0, #9, #10, #13, '>']) then
      begin
        some_par := false;
        FErrorCode := FErrorCode or err_code;
      end;
    end;
  end;

  procedure ProcessTag();
  var
    _isTagName: byte;
    _isParam: boolean;
    s: ansistring;
    _tmp: integer;
  begin
    _isTagName := 0;
    _isInstruction := false;
    _isParam := false;
    s := '';
    while true do
    begin
      if end_tag then
        break;
      _get_char();
      if err then
        break;
      if length(ss) >= 1 then
      begin
        RawTag();
        CheckClose(_isClosedTag, 64);
        CheckClose(_isInstruction, 1024);

        case ss[1] of
          '>':
            begin
              if _isTagName = 0 then
              begin
                if length(s) > 0 then
                begin
                  FTagName := s;
                  s := '';
                end
                else
                  FErrorCode := FErrorCode or 256;
              end;
              //
              if _isClosedTag then
              begin
                if (FTagType <> TAG_TYPE_DECLARE) and (FTagType <> TAG_TYPE_END) then
                  FTagType := TAG_TYPE_CLOSED
                else
                  FErrorCode := FErrorCode or 8192;
              end
              else if _isInstruction then
              begin
                if FTagType <> TAG_TYPE_DECLARE then
                  FErrorCode := FErrorCode or 16384;
              end;
              end_tag := true;
            end;
          '<':
            FErrorCode := FErrorCode or 32768;         //warning/error/ignore? {tut}
          '=':
            begin
              _isParam := false;
              if _isTagName > 0 then
              begin
                if length(s) > 0 then
                begin
                  Attributes.Add(s, GetParamValue(), FAttributesMatch);
                  s := '';
                end;
              end
              else
              begin
                //< =...>
                if length(s) > 0 then
                begin
                  FTagName := s;
                  s := '';
                  GetParamValue();
                end;
                FErrorCode := FErrorCode or 256;
                _isTagName := 13;
              end;
            end;
          '!':
            begin
              if (_isTagName = 0) and (length(s) = 0) then
              begin
                _tmp := GetCommentCDATA();
                if end_tag then
                  case _tmp of
                    1:
                      FTagType := TAG_TYPE_COMMENT;
                    2:
                      FTagType := TAG_TYPE_CDATA;
                  end;
                break;
              end
              else
              begin
                // <TAG!>
                FErrorCode := FErrorCode or 512;
              end;
            end;
          '?':
            begin
              if (_isTagName = 0) and (length(s) = 0) then
                FTagType := TAG_TYPE_DECLARE
              else
                _isInstruction := true;
            end;
          '/':
            begin

              if (_isTagName = 0) and (length(s) = 0) then
                FTagType := TAG_TYPE_END
              else
              begin
                if _isTagName = 0 then
                  FTagName := s;
                _isClosedTag := true;
              end;
            end;
          '"', '''':
            FErrorCode := FErrorCode or 65536;
          ' ', #13, #10, #9:
            begin
              if (_isTagName = 0) then
              begin
                if length(s) > 0 then
                begin
                  FTagName := s;
                  _isTagName := 1;
                  s := '';
                end
                else
                  FErrorCode := FErrorCode or 2048;
              end
              else
              begin
                if length(s) > 0 then
                  _isParam := true;
              end;
            end;
          #0:
            ;
        else
          begin
            if _isParam then
            begin
              if length(s) > 0 then
              begin
                _isParam := false;
                s := '';
                FErrorCode := FErrorCode or 4096;
              end;
            end;
            s := s + ss;
          end;
        end;//case
      end; //if
    end;  //while
  end;

begin
  result := true;
  end_tag := false;
  _isClosedTag := false;
  RawEncodingBeforeTag := '';
  err := false;
  Clear();
  while true do
  begin
    _get_char();
    if err then
      break;

    if length(ss) >= 1 then
    begin
      case ss[1] of
        '<':
          begin
            FRawTextTag := ss;
            RawTextTagNonDecoded := Ch;
            ProcessTag();

            if err then
              FErrorCode := FErrorCode or 131072
            else if end_tag then
              if (FTagType = TAG_TYPE_UNKNOWN) and (length(FTagName) > 0) then
                FTagType := TAG_TYPE_START;

            Break;
          end;
      else
        begin
          FTextBeforeTag := FTextBeforeTag + ss;
          RawEncodingBeforeTag := RawEncodingBeforeTag + Ch;
        end;
      end;//case
    end; //if
  end;  //while
  if FTagType = TAG_TYPE_START then
    AddTag(FTagName)
  else if FTagType = TAG_TYPE_END then
    DeleteClosedTag();
  if eof() then
    if TagCount > 0 then
      FErrorCode := FErrorCode or 524288;
end;

procedure TZsspXMLReader.AddTag(const Value: ansistring);
begin
  inc(FTagCount);
  ResizeTagArray(FTagCount);
  FTags[FTagCount - 1] := Value;
end;

procedure TZsspXMLReader.SetIgnoreCase(Value: boolean);
begin
  if not InProcess then
    FIgnoreCase := Value
end;

procedure TZsspXMLReader.DeleteTag();
begin
  if TagCount > 0 then
  begin
    dec(FTagCount);
    ResizeTagArray(FTagCount);
  end;
end;

procedure TZsspXMLReader.DeleteClosedTag();
var
  b: boolean;
begin
  b := false;
  if TagCount = 0 then
  begin
    FErrorCode := FErrorCode or 262144;
    exit;
  end;
  if IgnoreCase then
  begin
    if (AnsiUpperCase(UTF8ToString(TagName)) = AnsiUpperCase(UTF8ToString(Tags[TagCount - 1]))) then
      b := true;
  end
  else
  begin
    if TagName = Tags[TagCount - 1] then
      b := true;
  end;
  if b then
    DeleteTag()
  else
    FErrorCode := FErrorCode or 262144;
end;

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////

// Unicode (Delphi 2009+) API

////////////////////////////////////////////////////////////////////////////////
//// TZAttributesH - Unicode tag attribute wrapper class (H = Helper)
////////////////////////////////////////////////////////////////////////////////

constructor TZAttributesH.Create();
begin
  inherited;
  FAttributes := TZAttributes.Create();
end;

destructor TZAttributesH.Destroy();
begin
  FreeAndNil(FAttributes);
  inherited;
end;

procedure TZAttributesH.Assign(Source: TPersistent);
begin
  if (Source is TZAttributesH) then
    self.FAttributes.Assign((Source as TZAttributesH).FAttributes)
  else if (Source is TZAttributes) then
    self.FAttributes.Assign((Source as TZAttributes));
end;

function TZAttributesH.GetAttrCount(): integer;
begin
  result := FAttributes.Count;
end;

function TZAttributesH.GetAttrS(Att: string): string;
begin
  result := UTF8ToString(FAttributes.ItemsByName[UTF8Encode(Att)]);
end;

procedure TZAttributesH.SetAttrS(Att: string; const Value: string);
begin
  FAttributes.ItemsByName[UTF8Encode(Att)] := UTF8Encode(Value);
end;

function TZAttributesH.GetAttrI(num: integer): string;
begin
  result := UTF8ToString(FAttributes.ItemsByNum[num]);
end;

procedure TZAttributesH.SetAttrI(num: integer; const Value: string);
begin
  FAttributes.ItemsByNum[num] := UTF8Encode(Value);
end;

function TZAttributesH.GetAttr(num: integer): TZAttrArrayH;
var
  t: TZAttrArrayH;
  a: TZAttrArray;
  i: integer;
begin
  a := FAttributes.Items[num];
  for i := 0 to 1 do
    t[i] := UTF8ToString(a[i]);
  result := t;
end;

procedure TZAttributesH.SetAttr(num: integer; const Value: TZAttrArrayH);
var
  t: TZAttrArrayH;
  a: TZAttrArray;
  i: integer;
begin
  for i := 0 to 1 do
    a[i] := UTF8Encode(t[i]);
  FAttributes.Items[num] := a;
end;

procedure TZAttributesH.Add(const AttrName: string; const Value: string; TestMatch: boolean = true);
begin
  FAttributes.Add(UTF8Encode(AttrName), UTF8Encode(Value), TestMatch);
end;

procedure TZAttributesH.Add(const Attr: TZAttrArrayH; TestMatch: boolean = true);
begin
  Add(Attr[0], Attr[1], TestMatch);
end;

procedure TZAttributesH.Add(Att: array of TZAttrArrayH; TestMatch: boolean = true);
var
  i: integer;
begin
  for i := Low(Att) to High(Att) do
    Add(Att[i][0], Att[i][1], TestMatch);
end;

procedure TZAttributesH.Clear();
begin
  FAttributes.Clear();
end;

procedure TZAttributesH.DeleteItem(Index: integer);
begin
  FAttributes.DeleteItem(Index);
end;

procedure TZAttributesH.Insert(Index: integer; const AttrName: string; const Value: string; TestMatch: boolean = true);
begin
  FAttributes.Insert(Index, UTF8Encode(AttrName), UTF8Encode(Value), TestMatch);
end;

procedure TZAttributesH.Insert(Index: integer; const Attr: TZAttrArrayH; TestMatch: boolean = true);
begin
  Insert(Index, Attr[0], Attr[1], TestMatch);
end;

function TZAttributesH.ToString(quote: char; CheckEntity: boolean; addempty: boolean): string;
begin
  result := UTF8ToString(FAttributes.ToString(AnsiChar(quote), CheckEntity, addempty));
end;

function TZAttributesH.ToString(quote: char; CheckEntity: boolean): string;
begin
  result := UTF8ToString(FAttributes.ToString(AnsiChar(quote), CheckEntity));
end;

function TZAttributesH.ToString(quote: char): string;
begin
  result := UTF8ToString(FAttributes.ToString(AnsiChar(quote)));
end;

function TZAttributesH.ToString(CheckEntity: boolean): string;
begin
  result := UTF8ToString(FAttributes.ToString(CheckEntity));
end;

function TZAttributesH.ToString(): string;
begin
  result := UTF8ToString(FAttributes.ToString());
end;

function TZAttributesH.IsContainsAttribute(const AttrName: string; CaseSensitivity: boolean = true): boolean;
begin
  Result := FAttributes.IsContainsAttribute(AnsiString(AttrName), CaseSensitivity);
end;

////////////////////////////////////////////////////////////////////////////////
//// TZsspXMLWriterH
////////////////////////////////////////////////////////////////////////////////

constructor TZsspXMLWriterH.Create();
begin
  inherited;
  FXMLWriter := TZsspXMLWriter.Create();
  FAttributes := TZAttributesH.Create();
end;

destructor TZsspXMLWriterH.Destroy();
begin
  FreeAndNil(FXMLWriter);
  FreeAndNil(FAttributes);
  inherited;
end;

function TZsspXMLWriterH.GetXMLBuffer(): string;
begin
  result := UTF8ToString(FXMLWriter.Buffer);
end;

function TZsspXMLWriterH.GetAttributeQuote(): char;
begin
  result := Char(FXMLWriter.AttributeQuote);
end;

function TZsspXMLWriterH.GetInProcess(): boolean;
begin
  result := FXMLWriter.InProcess
end;

function TZsspXMLWriterH.GetMaxBufferLength(): integer;
begin
  result := FXMLWriter.MaxBufferLength;
end;

function TZsspXMLWriterH.GetNewLine(): boolean;
begin
  result := FXMLWriter.NewLine;
end;

function TZsspXMLWriterH.GetTabLength(): integer;
begin
  result := FXMLWriter.TabLength;
end;

function TZsspXMLWriterH.GetTagCount(): integer;
begin
  result := FXMLWriter.TagCount;
end;

function TZsspXMLWriterH.GetTextConverter(): TCPToAnsiConverter;
begin
  result := TextConverter;
end;

function TZsspXMLWriterH.GetUnixNLSeparator(): boolean;
begin
  result := FXMLWriter.UnixNLSeparator;
end;

function TZsspXMLWriterH.GetTag(num: integer): string;
begin
  result := UTF8ToString(FXMLWriter.Tags[num]);
end;

function TZsspXMLWriterH.GetTabSymbol(): char;
begin
  result := Char(FXMLWriter.TabSymbol);
end;

procedure TZsspXMLWriterH.SetAttributeQuote(Value: char);
begin
  FXMLWriter.AttributeQuote := AnsiChar(Value);
end;

procedure TZsspXMLWriterH.SetMaxBufferLength(Value: integer);
begin
  FXMLWriter.MaxBufferLength := Value;
end;

procedure TZsspXMLWriterH.SetNewLine(Value: boolean);
begin
  FXMLWriter.NewLine := Value;
end;

procedure TZsspXMLWriterH.SetTabLength(Value: integer);
begin
  FXMLWriter.TabLength := Value;
end;

procedure TZsspXMLWriterH.SetTabSymbol(Value: char);
begin
  FXMLWriter.TabSymbol := AnsiChar(Value);
end;

procedure TZsspXMLWriterH.SetTextConverter(Value: TAnsiToCPConverter);
begin
  FXMLWriter.TextConverter := Value;
end;

procedure TZsspXMLWriterH.SetUnixNLSeparator(Value: boolean);
begin
  FXMLWriter.UnixNLSeparator := Value;
end;

procedure TZsspXMLWriterH.SetAttributes(Value: TZAttributesH);
begin
  if (Value <> nil) then
    FAttributes.Assign(Value);
end;

function TZsspXMLWriterH.BeginSaveToStream(Stream: TStream): boolean;
begin
  result := FXMLWriter.BeginSaveToStream(Stream);
end;

function TZsspXMLWriterH.BeginSaveToFile(FileName: string): boolean;
begin
  result := FXMLWriter.BeginSaveToFile(FileName);
end;

function TZsspXMLWriterH.BeginSaveToString(): boolean;
begin
  result := FXMLWriter.BeginSaveToString();
end;

procedure TZsspXMLWriterH.EndSaveTo();
begin
  FXMLWriter.EndSaveTo();
end;

procedure TZsspXMLWriterH.FlushBuffer();
begin
  FXMLWriter.FlushBuffer();
end;

procedure TZsspXMLWriterH.WriteCDATA(CDATA: string; CorrectCDATA: boolean; StartNewLine: boolean = true);
begin
  FXMLWriter.WriteCDATA(UTF8Encode(CDATA), CorrectCDATA, StartNewLine);
end;

procedure TZsspXMLWriterH.WriteCDATA(CDATA: string);
begin
  FXMLWriter.WriteCDATA(UTF8Encode(CDATA));
end;

procedure TZsspXMLWriterH.WriteComment(Comment: string; StartNewLine: boolean = true);
begin
  FXMLWriter.WriteComment(UTF8Encode(Comment), StartNewLine);
end;

procedure TZsspXMLWriterH.WriteEmptyTag(TagName: string; SAttributes: TZAttributesH; StartNewLine: boolean; CheckEntity: boolean = true);
begin
  FXMLWriter.WriteEmptyTag(UTF8Encode(TagName), SAttributes.FAttributes, StartNewLine, CheckEntity);
end;

procedure TZsspXMLWriterH.WriteEmptyTag(TagName: string; AttrArray: array of TZAttrArrayH; StartNewLine: boolean; CheckEntity: boolean = true);
var
  a: array of TZAttrArray;
  kol, _start: integer;
  i, num: integer;
begin
  kol := High(AttrArray);
  _start := Low(AttrArray);
  try
    SetLength(a, kol - _start + 1);
    num := 0;
    for i := _start to kol do
    begin
      a[num][0] := UTF8Encode(AttrArray[i][0]);
      a[num][1] := UTF8Encode(AttrArray[i][1]);
    end;
    FXMLWriter.WriteEmptyTag(UTF8Encode(TagName), a, StartNewLine, CheckEntity);
  finally
    SetLength(a, 0);
    a := nil;
  end;
end;

procedure TZsspXMLWriterH.WriteEmptyTag(TagName: string; StartNewLine: boolean; CheckEntity: boolean = true);
begin
  FXMLWriter.WriteEmptyTag(UTF8Encode(TagName), FAttributes.FAttributes, StartNewLine, CheckEntity);
end;

procedure TZsspXMLWriterH.WriteEmptyTag(TagName: string; SAttributes: TZAttributesH);
begin
  FXMLWriter.WriteEmptyTag(UTF8Encode(TagName), SAttributes.FAttributes);
end;

procedure TZsspXMLWriterH.WriteEmptyTag(TagName: string; AttrArray: array of TZAttrArrayH);
begin
  WriteEmptyTag(TagName, AttrArray, true, true);
end;

procedure TZsspXMLWriterH.WriteEmptyTag(TagName: string);
begin
  WriteEmptyTag(TagName, FAttributes, true, true);
end;

procedure TZsspXMLWriterH.WriteEndTagNode();
begin
  FXMLWriter.WriteEndTagNode();
end;

procedure TZsspXMLWriterH.WriteEndTagNode(isForce: boolean; CloseTagNewLine: boolean);
begin
  FXMLWriter.WriteEndTagNode(isForce, CloseTagNewLine);
end;

procedure TZsspXMLWriterH.WriteInstruction(InstructionName: string; SAttributes: TZAttributesH; StartNewLine: boolean; CheckEntity: boolean = true);
begin
  FXMLWriter.WriteInstruction(UTF8Encode(InstructionName), SAttributes.FAttributes, StartNewLine, CheckEntity);
end;

procedure TZsspXMLWriterH.WriteInstruction(InstructionName: string; AttrArray: array of TZAttrArrayH; StartNewLine: boolean; CheckEntity: boolean = true);
var
  a: array of TZAttrArray;
  kol, _start: integer;
  i, num: integer;
begin
  kol := High(AttrArray);
  _start := Low(AttrArray);
  try
    SetLength(a, kol - _start + 1);
    num := 0;
    for i := _start to kol do
    begin
      a[num][0] := UTF8Encode(AttrArray[i][0]);
      a[num][1] := UTF8Encode(AttrArray[i][1]);
    end;
    FXMLWriter.WriteInstruction(UTF8Encode(InstructionName), a, StartNewLine, CheckEntity);
  finally
    SetLength(a, 0);
    a := nil;
  end;
end;

procedure TZsspXMLWriterH.WriteInstruction(InstructionName: string; StartNewLine: boolean; CheckEntity: boolean = true);
begin
  FXMLWriter.WriteInstruction(UTF8Encode(InstructionName), FAttributes.FAttributes, StartNewLine, CheckEntity);
end;

procedure TZsspXMLWriterH.WriteInstruction(InstructionName: string; SAttributes: TZAttributesH);
begin
  FXMLWriter.WriteInstruction(UTF8Encode(InstructionName), SAttributes.FAttributes);
end;

procedure TZsspXMLWriterH.WriteInstruction(InstructionName: string; AttrArray: array of TZAttrArrayH);
begin
  WriteInstruction(InstructionName, AttrArray, true, true);
end;

procedure TZsspXMLWriterH.WriteInstruction(InstructionName: string);
begin
  FXMLWriter.WriteInstruction(UTF8Encode(InstructionName), FAttributes.FAttributes);
end;

procedure TZsspXMLWriterH.WriteRaw(Text: string; UseConverter: boolean; StartNewLine: boolean = true);
begin
  FXMLWriter.WriteRaw(UTF8Encode(Text), UseConverter, StartNewLine);
end;

procedure TZsspXMLWriterH.WriteRaw(Text: ansistring; UseConverter: boolean; StartNewLine: boolean = true);
begin
  FXMLWriter.WriteRaw(Text, UseConverter, StartNewLine);
end;

procedure TZsspXMLWriterH.WriteTag(TagName: string; Text: string; SAttributes: TZAttributesH; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
begin
  FXMLWriter.WriteTag(UTF8Encode(TagName), UTF8Encode(Text), SAttributes.FAttributes, StartNewLine, CloseTagNewLine, CheckEntity);
end;

procedure TZsspXMLWriterH.WriteTag(TagName: string; Text: string; AttrArray: array of TZAttrArrayH; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
var
  a: array of TZAttrArray;
  kol, _start: integer;
  i, num: integer;
begin
  kol := High(AttrArray);
  _start := Low(AttrArray);
  try
    SetLength(a, kol - _start + 1);
    num := 0;
    for i := _start to kol do
    begin
      a[num][0] := UTF8Encode(AttrArray[i][0]);
      a[num][1] := UTF8Encode(AttrArray[i][1]);
    end;
    FXMLWriter.WriteTag(UTF8Encode(TagName), UTF8Encode(Text), a, StartNewLine, CloseTagNewLine, CheckEntity);
  finally
    SetLength(a, 0);
    a := nil;
  end;
end;

procedure TZsspXMLWriterH.WriteTag(TagName: string; Text: string; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
begin
  WriteTag(TagName, Text, FAttributes, StartNewLine, CloseTagNewLine, CheckEntity);
end;

procedure TZsspXMLWriterH.WriteTag(TagName: string; Text: string; SAttributes: TZAttributesH);
begin
  FXMLWriter.WriteTag(UTF8Encode(TagName), UTF8Encode(Text), FAttributes.FAttributes);
end;

procedure TZsspXMLWriterH.WriteTag(TagName: string; Text: string; AttrArray: array of TZAttrArrayH);
begin
  WriteTag(TagName, Text, AttrArray, true, false, true);
end;

procedure TZsspXMLWriterH.WriteTag(TagName: string; Text: string);
begin
  WriteTag(TagName, Text, FAttributes, true, false, true);
end;

procedure TZsspXMLWriterH.WriteTagNode(TagName: string; SAttributes: TZAttributesH; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
begin
  FXMLWriter.WriteTagNode(UTF8Encode(TagName), SAttributes.FAttributes, StartNewLine, CloseTagNewLine, CheckEntity);
end;

procedure TZsspXMLWriterH.WriteTagNode(TagName: string; AttrArray: array of TZAttrArrayH; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
var
  a: array of TZAttrArray;
  kol, _start: integer;
  i, num: integer;
begin
  kol := High(AttrArray);
  _start := Low(AttrArray);
  try
    SetLength(a, kol - _start + 1);
    num := 0;
    for i := _start to kol do
    begin
      a[num][0] := UTF8Encode(AttrArray[i][0]);
      a[num][1] := UTF8Encode(AttrArray[i][1]);
    end;
    FXMLWriter.WriteTagNode(UTF8Encode(TagName), a, StartNewLine, CloseTagNewLine, CheckEntity);
  finally
    SetLength(a, 0);
    a := nil;
  end;
end;

procedure TZsspXMLWriterH.WriteTagNode(TagName: string; StartNewLine: boolean; CloseTagNewLine: boolean; CheckEntity: boolean = true);
begin
  WriteTagNode(TagName, FAttributes, StartNewLine, CloseTagNewLine, CheckEntity);
end;

procedure TZsspXMLWriterH.WriteTagNode(TagName: string; SAttributes: TZAttributesH);
begin
  WriteTagNode(TagName, SAttributes, true, false, true);
end;

procedure TZsspXMLWriterH.WriteTagNode(TagName: string; AttrArray: array of TZAttrArrayH);
begin
  WriteTagNode(TagName, AttrArray, true, false, true);
end;

procedure TZsspXMLWriterH.WriteTagNode(TagName: string);
begin
  WriteTagNode(TagName, FAttributes, true, false, true);
end;

////////////////////////////////////////////////////////////////////////////////
//// TZsspXMLReaderH
////////////////////////////////////////////////////////////////////////////////

constructor TZsspXMLReaderH.Create();
begin
  inherited;
  FAttributes := TZAttributesH.Create();
  FXMLReader := TZsspXMLReader.Create();
end;

destructor TZsspXMLReaderH.Destroy();
begin
  FreeandNil(FXMLReader);
  FreeAndNil(FAttributes);
  inherited;
end;

procedure TZsspXMLReaderH.SetAttributesMatch(Value: boolean);
begin
  FXMLReader.AttributesMatch := Value;
end;

function TZsspXMLReaderH.GetAttributesMatch: boolean;
begin
  result := FXMLReader.AttributesMatch;
end;

procedure TZsspXMLReaderH.SetQuotesEqual(Value: boolean);
begin
  FXMLReader.QuotesEqual := Value;
end;

function TZsspXMLReaderH.GetQuotesEqual(): boolean;
begin
  result := FXMLReader.QuotesEqual;
end;

function TZsspXMLReaderH.GetAttributes(): TZAttributesH;
begin
  result := FAttributes;
end;

function TZsspXMLReaderH.GetInProcess(): boolean;
begin
  result := FXMLReader.InProcess;
end;

function TZsspXMLReaderH.GetRawTextTag(): string;
begin
  result := UTF8ToString(FXMLReader.RawTextTag);
end;

function TZsspXMLReaderH.GetErrorCode(): integer;
begin
  result := FXMLReader.ErrorCode;
end;

function TZsspXMLReaderH.GetIgnoreCase(): boolean;
begin
  result := FXMLReader.IgnoreCase;
end;

function TZsspXMLReaderH.GetValue(): string;
begin
  result := UTF8ToString(FXMLReader.TagValue);
end;

function TZsspXMLReaderH.GetTagType(): byte;
begin
  result := FXMLReader.TagType;
end;

function TZsspXMLReaderH.GetTagCount(): integer;
begin
  result := FXMLReader.TagCount;
end;

function TZsspXMLReaderH.GetTextBeforeTag(): string;
begin
  result := UTF8ToString(FXMLReader.TextBeforeTag);
end;

function TZsspXMLReaderH.GetTagName(): string;
begin
  result := UTF8ToString(FXMLReader.TagName);
end;

function TZsspXMLReaderH.GetTag(num: integer): string;
begin
  result := UTF8ToString(FXMLReader.Tags[num]);
end;

procedure TZsspXMLReaderH.SetMaxBufferLength(Value: integer);
begin
  FXMLReader.MaxBufferLength := Value;
end;

function TZsspXMLReaderH.GetMaxBufferLength(): integer;
begin
  result := FXMLReader.MaxBufferLength;
end;

procedure TZsspXMLReaderH.SetIgnoreCase(Value: boolean);
begin
  FXMLReader.IgnoreCase := Value;
end;

function TZsspXMLReaderH.BeginReadFile(FileName: string): integer;
begin
  result := FXMLReader.BeginReadFile(FileName);
end;

function TZsspXMLReaderH.BeginReadStream(Stream: TStream): integer;
begin
  result := FXMLReader.BeginReadStream(Stream);
end;

function TZsspXMLReaderH.BeginReadString(Source: string; IgnoreCodePage: boolean = true): integer;
begin
  result := FXMLReader.BeginReadString(UTF8Encode(Source), IgnoreCodePage);
end;

function TZsspXMLReaderH.ReadTag(): boolean;
begin
  result := FXMLReader.ReadTag();
  FAttributes.Assign(FXMLReader.Attributes);
end;

procedure TZsspXMLReaderH.EndRead();
begin
  FXMLReader.EndRead();
end;

function TZsspXMLReaderH.Eof(): boolean;
begin
  result := FXMLReader.Eof();
end;

////////////////////////////////////////////////////////////////////////////////
/////                   End of Unicode wrapper classes                       /////
////////////////////////////////////////////////////////////////////////////////

end.

