//****************************************************************
// zeSave.pas - Fluent interface for uniform workbook saving
// Based on original by "the Arioch", licensed under zLib
// Modernized for Delphi 10.4+:
//   - TAnsiToCPConverter removed (UTF-8 only)
//   - CZxZipGens / zeZippy removed (System.Zip only)
//   - CharSet / BOM / ZipWith API stubs preserved for compatibility
//   - Registry-based format detection preserved
//****************************************************************
unit zeSave;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Contnrs, zexmlss, zsspxml;

type
  EZXSaveException = class(Exception);

  TZxPageInfo = record
    name: string;
    no: integer;
  end;

  IZXMLSSave = interface
    function ExportFormat(const fmt: string): IZXMLSSave;
    function As_(const fmt: string): IZXMLSSave;
    function ExportTo(const fname: TFileName): IZXMLSSave;
    function To_(const fname: TFileName): IZXMLSSave;
    function Pages(const pages: array of TZxPageInfo): IZXMLSSave; overload;
    function Pages(const numbers: array of integer): IZXMLSSave; overload;
    function Pages(const titles: array of string): IZXMLSSave; overload;

    // Charset/BOM stubs — UTF-8 is always used; kept for API compatibility
    function CharSet(const cs: AnsiString): IZXMLSSave; overload;
    function CharSet(const codepage: word): IZXMLSSave; overload;
    function BOM(const Unicode_BOM: AnsiString): IZXMLSSave;
    function NoZip: IZXMLSSave;
    function Save: integer; overload;
    function Save(const FileName: TFileName): integer; overload;
    procedure Discard;
  end;

  IZXMLSSaveImpl = interface(IZXMLSSave)
    ['{DAB9A318-ADD4-466C-AFE3-CE8623EC8977}']
    function InternalSave: integer;
  end;

  TZXMLSSave = class;

  CZXMLSSaveClass = class of TZXMLSSave;

  TZXMLSSave = class(TInterfacedObject, IZXMLSSave, IZXMLSSaveImpl)
  protected
    function DoSave: integer; virtual;
    class function FormatDescriptions: TStringDynArray; virtual;

  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function From(const zxbook: TZEXMLSS): IZXMLSSave; virtual;

  protected
    constructor Create(const zxbook: TZEXMLSS); overload;
    constructor Create(const zxsaver: TZXMLSSave); overload; virtual;

    function ExportFormat(const fmt: string): IZXMLSSave;
    function As_(const fmt: string): IZXMLSSave;
    function ExportTo(const fname: TFileName): IZXMLSSave;
    function To_(const fname: TFileName): IZXMLSSave;

    function Pages(const APages: array of TZxPageInfo): IZXMLSSave; overload;
    function Pages(const numbers: array of integer): IZXMLSSave; overload;
    function Pages(const titles: array of string): IZXMLSSave; overload;

    // Charset/BOM — UTF-8 always; stubs return Self for chaining
    function CharSet(const cs: AnsiString): IZXMLSSave; overload;
    function CharSet(const codepage: word): IZXMLSSave; overload;
    function BOM(const Unicode_BOM: AnsiString): IZXMLSSave;

    function NoZip: IZXMLSSave;

    function OnErrorRaise: IZXMLSSave;
    function OnErrorRetCode: IZXMLSSave;

    function Save: integer; overload;
    function Save(const FileName: TFileName): integer; overload;
    procedure Discard; virtual;
    function InternalSave: integer;

  protected
    fBook: TZEXMLSS;
    fPages: array of TZxPageInfo;
    FFile: TFileName;
    FPath: TFileName;
    FDoNotDestroyMe: Boolean;
    FRaiseOnError: Boolean;

    function GetPageNumbers: TIntegerDynArray;
    function GetPageTitles: TStringDynArray;
    function CreateSaverForDescription(const desc: string): IZXMLSSave;
    procedure CheckSaveRetCode(AResult: integer);

    class procedure RegisterFormat(const sv: CZXMLSSaveClass);
    class procedure UnRegisterFormat(const sv: CZXMLSSaveClass);
  public
    class procedure Register;
    class procedure UnRegister;
  end;

implementation

uses
  Winapi.Windows, System.Win.Registry, System.StrUtils;

var
  SaveClasses: TClassList;

// Lookup charset name from Windows registry by codepage
function ZxCharSetByCodePage(const cp: Word): AnsiString;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Reg.OpenKeyReadOnly('MIME\DataBase\Codepage\' + IntToStr(cp)) then
    begin
      Result := AnsiString(Trim(Reg.ReadString('WebCharset')));
      if Result = '' then
        Result := AnsiString(Trim(Reg.ReadString('BodyCharset')));
      if Result <> '' then
        Exit;
    end;
  finally
    Reg.Free;
  end;
  raise EZXSaveException.Create('No charset (MIME id) found for codepage ' + IntToStr(cp));
end;

{ TZXMLSSave }

class function TZXMLSSave.From(const zxbook: TZEXMLSS): IZXMLSSave;
begin
  Result := TZXMLSSave.Create(zxbook);
end;

constructor TZXMLSSave.Create(const zxbook: TZEXMLSS);
begin
  fBook := zxbook;
end;

constructor TZXMLSSave.Create(const zxsaver: TZXMLSSave);
begin
  fBook := zxsaver.fBook;
  FFile := zxsaver.FFile;
  FPath := zxsaver.FPath;
  fPages := zxsaver.fPages;
  FRaiseOnError := zxsaver.FRaiseOnError;
end;

procedure TZXMLSSave.AfterConstruction;
begin
  if fBook = nil then
    raise EZXSaveException.Create('Cannot export nil book. Do not use inherited TObject.Create');
  inherited;
  FDoNotDestroyMe := True;
end;

procedure TZXMLSSave.BeforeDestruction;
begin
  inherited;
  if FDoNotDestroyMe then
  begin
    FDoNotDestroyMe := False;
    raise EZXSaveException.Create('Premature exporter destroying: export must end with .Save or .Discard');
  end;
end;

procedure TZXMLSSave.Discard;
begin
  FDoNotDestroyMe := False;
end;

// ── Charset / BOM stubs (UTF-8 always) ──────────────────────

function TZXMLSSave.CharSet(const cs: AnsiString): IZXMLSSave;
begin
  Result := Self; // UTF-8 only — parameter accepted but ignored
end;

function TZXMLSSave.CharSet(const codepage: word): IZXMLSSave;
begin
  ZxCharSetByCodePage(codepage); // validate; raises if invalid
  Result := Self;
end;

function TZXMLSSave.BOM(const Unicode_BOM: AnsiString): IZXMLSSave;
begin
  Result := Self; // accepted but ignored; UTF-8 BOM not recommended
end;

function TZXMLSSave.NoZip: IZXMLSSave;
begin
  Result := Self; // System.Zip always used; stub for API compat
end;

// ── Navigation / fluent chain ────────────────────────────────

function TZXMLSSave.ExportFormat(const fmt: string): IZXMLSSave;
begin
  Result := CreateSaverForDescription(fmt);
end;

function TZXMLSSave.As_(const fmt: string): IZXMLSSave;
begin
  Result := ExportFormat(fmt);
end;

function TZXMLSSave.ExportTo(const fname: TFileName): IZXMLSSave;
var
  fp: TFileName;
begin
  fp := ExtractFileDir(fname);
  if not DirectoryExists(fp) then
    raise EZXSaveException.Create('No such path: ' + fp);
  FPath := fp;
  FFile := fname;
  Result := Self;
end;

function TZXMLSSave.To_(const fname: TFileName): IZXMLSSave;
begin
  Result := ExportTo(fname);
end;

// ── Pages ────────────────────────────────────────────────────

function TZXMLSSave.Pages(const APages: array of TZxPageInfo): IZXMLSSave;
var
  i, c: integer;
begin
  c := fBook.Sheets.Count - 1;
  for i := Low(APages) to High(APages) do
    if (APages[i].no < 0) or (APages[i].no > c) then
      raise EZXSaveException.Create('There is no sheet #' + IntToStr(APages[i].no) + ' in the book');
  SetLength(fPages, Length(APages));
  for i := 0 to High(APages) do
    fPages[i] := APages[i];
  Result := Self;
end;

function TZXMLSSave.Pages(const numbers: array of integer): IZXMLSSave;
var
  i, c: integer;
begin
  c := fBook.Sheets.Count - 1;
  for i := Low(numbers) to High(numbers) do
    if (numbers[i] < 0) or (numbers[i] > c) then
      raise EZXSaveException.Create('There is no sheet #' + IntToStr(numbers[i]) + ' in the workbook');
  SetLength(fPages, Length(numbers));
  for i := 0 to High(numbers) do
  begin
    fPages[i].no := numbers[i];
    fPages[i].name := '';
  end;
  Result := Self;
end;

function TZXMLSSave.Pages(const titles: array of string): IZXMLSSave;
var
  i: integer;
begin
  if Length(fPages) <> Length(titles) then
    raise EZXSaveException.Create('Sheet title count does not match sheet count');
  for i := 0 to High(titles) do
    fPages[i].name := titles[i];
  Result := Self;
end;

// ── Error handling ───────────────────────────────────────────

function TZXMLSSave.OnErrorRaise: IZXMLSSave;
begin
  FRaiseOnError := True;
  Result := Self;
end;

function TZXMLSSave.OnErrorRetCode: IZXMLSSave;
begin
  FRaiseOnError := False;
  Result := Self;
end;

procedure TZXMLSSave.CheckSaveRetCode(AResult: integer);
begin
  if (AResult <> 0) and FRaiseOnError then
    raise EZXSaveException.Create('Error #' + IntToStr(AResult) + ': cannot save ' + FFile);
end;

// ── Save ─────────────────────────────────────────────────────

function TZXMLSSave.Save(const FileName: TFileName): integer;
begin
  Result := ExportTo(FileName).Save;
  CheckSaveRetCode(Result);
end;

function TZXMLSSave.Save: integer;
var
  i: integer;
begin
  FDoNotDestroyMe := False;
  if Length(fPages) = 0 then
  begin
    SetLength(fPages, fBook.Sheets.Count);
    for i := 0 to fBook.Sheets.Count - 1 do
    begin
      fPages[i].no := i;
      fPages[i].name := fBook.Sheets[i].Title;
    end;
  end;
  Result := InternalSave;
  CheckSaveRetCode(Result);
end;

function TZXMLSSave.InternalSave: integer;
begin
  FDoNotDestroyMe := False;
  Result := DoSave;
end;

function TZXMLSSave.DoSave: integer;
begin
  Result := (CreateSaverForDescription(ExtractFileExt(FFile)) as IZXMLSSaveImpl).InternalSave;
end;

// ── Page helpers ─────────────────────────────────────────────

function TZXMLSSave.GetPageNumbers: TIntegerDynArray;
var
  i: integer;
begin
  SetLength(Result, Length(fPages));
  for i := 0 to High(Result) do
    Result[i] := fPages[i].no;
end;

function TZXMLSSave.GetPageTitles: TStringDynArray;
var
  i: integer;
begin
  SetLength(Result, Length(fPages));
  for i := 0 to High(Result) do
    Result[i] := fPages[i].name;
end;

// ── Format registry ──────────────────────────────────────────

function TZXMLSSave.CreateSaverForDescription(const desc: string): IZXMLSSave;
var
  tgt: string;
  ss: TStringDynArray;
  cs: CZXMLSSaveClass;
  cc: TClass;
  i, j: integer;
begin
  tgt := UpperCase(Trim(desc));
  for i := 0 to SaveClasses.Count - 1 do
  begin
    cc := SaveClasses[i];
    if not cc.InheritsFrom(TZXMLSSave) then
      Continue;
    cs := CZXMLSSaveClass(cc);
    ss := cs.FormatDescriptions;
    for j := Low(ss) to High(ss) do
      if UpperCase(Trim(ss[j])) = tgt then
      begin
        Result := cs.Create(Self);
        Exit;
      end;
  end;
  raise EZXSaveException.Create('Unknown save format: ' + desc);
end;

class function TZXMLSSave.FormatDescriptions: TStringDynArray;
begin
  Result := nil;
end;

class procedure TZXMLSSave.RegisterFormat(const sv: CZXMLSSaveClass);
begin
  SaveClasses.Add(sv);
end;

class procedure TZXMLSSave.UnRegisterFormat(const sv: CZXMLSSaveClass);
begin
  SaveClasses.Remove(sv);
end;

class procedure TZXMLSSave.Register;
begin
  RegisterFormat(Self);
end;

class procedure TZXMLSSave.UnRegister;
begin
  UnRegisterFormat(Self);
end;

initialization
  SaveClasses := TClassList.Create;


finalization
  SaveClasses.Free;

end.

