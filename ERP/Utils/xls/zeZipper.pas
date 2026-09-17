//****************************************************************
// zeZipper.pas - ZIP archive support
// Modernized: uses System.Zip (Delphi built-in, XE10+)
// All legacy backends removed: KAZip, JCL7Z, Abbrevia, SciZip, Synzip
// Target: Delphi XE10 (10 Seattle) and above
//
// TUnZipper is API-compatible with FPC zipper unit so that
// zexlsx.pas and zeodfs.pas require minimal changes.
//****************************************************************
unit zeZipper;

interface

uses
  System.Classes, System.SysUtils, System.Zip;

type
  EZipError = class(Exception);

  TCompressionLevel = (clNone, clFastest, clDefault, clMax);

  //--------------------------------------------------------------
  // TZipFileEntry - one entry in a ZIP (write side)
  //--------------------------------------------------------------
  TZipFileEntry = class(TCollectionItem)
  private
    FArchiveFileName: string;
    FDiskFileName: string;
    FDateTime: TDateTime;
    FSize: Int64;
    FStream: TStream;
    FCompressionLevel: TCompressionLevel;
    function GetArchiveFileName: string;
    procedure SetArchiveFileName(const AValue: string);
    procedure SetDiskFileName(const AValue: string);
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    property Stream: TStream read FStream write FStream;
  published
    property ArchiveFileName: string read GetArchiveFileName write SetArchiveFileName;
    property DiskFileName: string read FDiskFileName write SetDiskFileName;
    property Size: Int64 read FSize write FSize;
    property DateTime: TDateTime read FDateTime write FDateTime;
    property CompressionLevel: TCompressionLevel read FCompressionLevel write FCompressionLevel;
  end;

  TZipFileEntries = class(TCollection)
  private
    function GetZ(AIndex: Integer): TZipFileEntry;
  public
    function AddFileEntry(const ADiskFileName: string): TZipFileEntry; overload;
    function AddFileEntry(const ADiskFileName, AArchiveFileName: string): TZipFileEntry; overload;
    function AddFileEntry(const AStream: TStream; const AArchiveFileName: string): TZipFileEntry; overload;
    property Entries[AIndex: Integer]: TZipFileEntry read GetZ; default;
  end;

  //--------------------------------------------------------------
  // TFullZipFileEntry - entry used during extraction (read side)
  // Compatible with FPC zipper TFullZipFileEntry for event signatures
  //--------------------------------------------------------------
  TFullZipFileEntry = class(TCollectionItem)
  private
    FArchiveFileName: string;
    FSize: Int64;
    FCompressedSize: Int64;
    procedure SetArchiveFileName(const AValue: string);
  public
    property ArchiveFileName: string read FArchiveFileName write SetArchiveFileName;
    property Size: Int64 read FSize write FSize;
    property CompressedSize: Int64 read FCompressedSize write FCompressedSize;
  end;

  TFullZipFileEntries = class(TCollection)
  private
    function GetZ(AIndex: Integer): TFullZipFileEntry;
  public
    constructor Create;
    function Add: TFullZipFileEntry;
    property Entries[AIndex: Integer]: TFullZipFileEntry read GetZ; default;
  end;

  // Event type - same signature as FPC zipper TStreamEvent
  TStreamEvent = procedure(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry) of object;

  //--------------------------------------------------------------
  // TZipper - creates ZIP archives
  //--------------------------------------------------------------
  TZipper = class
  private
    FFileName: string;
    FEntries: TZipFileEntries;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ZipAllFiles;
    property FileName: string read FFileName write FFileName;
    property Entries: TZipFileEntries read FEntries;
  end;

  //--------------------------------------------------------------
  // TUnZipper - extracts ZIP archives
  // Fully compatible with FPC zipper TUnZipper
  //--------------------------------------------------------------
  TUnZipper = class
  private
    FFileName: string;
    FOutputPath: string;
    FEntries: TFullZipFileEntries;
    FOnCreateStream: TStreamEvent;
    FOnDoneStream: TStreamEvent;
    procedure ExtractOne(AZipFile: TZipFile; const AArchiveName: string; AEntry: TFullZipFileEntry);
    function FindInZip(AZipFile: TZipFile; const AArchiveName: string): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    // Populate Entries from ZIP central directory (no extraction)
    procedure Examine;

    // Extract all files to OutputPath
    procedure UnZipAllFiles;

    // Extract named files; fires OnCreateStream / OnDoneStream per file
    procedure UnZipFiles(AFiles: TStrings);

    // Extract one file directly into AStream (no events)
    procedure UnZipFileToStream(const AArchiveName: string; AStream: TStream);

    property FileName: string read FFileName write FFileName;
    property OutputPath: string read FOutputPath write FOutputPath;
    property Entries: TFullZipFileEntries read FEntries;
    property OnCreateStream: TStreamEvent read FOnCreateStream write FOnCreateStream;
    property OnDoneStream: TStreamEvent read FOnDoneStream write FOnDoneStream;
  end;

implementation

//==============================================================
// TZipFileEntry
//==============================================================

constructor TZipFileEntry.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FCompressionLevel := clDefault;
  FDateTime := Now;
end;

procedure TZipFileEntry.Assign(Source: TPersistent);
var
  Src: TZipFileEntry;
begin
  if Source is TZipFileEntry then
  begin
    Src := TZipFileEntry(Source);
    FArchiveFileName := Src.FArchiveFileName;
    FDiskFileName := Src.FDiskFileName;
    FDateTime := Src.FDateTime;
    FSize := Src.FSize;
    FStream := Src.FStream;
    FCompressionLevel := Src.FCompressionLevel;
  end
  else
    inherited Assign(Source);
end;

function TZipFileEntry.GetArchiveFileName: string;
begin
  if FArchiveFileName <> '' then
    Result := FArchiveFileName
  else
    Result := ExtractFileName(FDiskFileName);
end;

procedure TZipFileEntry.SetArchiveFileName(const AValue: string);
begin
  FArchiveFileName := StringReplace(AValue, '\', '/', [rfReplaceAll]);
end;

procedure TZipFileEntry.SetDiskFileName(const AValue: string);
begin
  FDiskFileName := AValue;
  if FArchiveFileName = '' then
    FArchiveFileName := ExtractFileName(AValue);
end;

//==============================================================
// TZipFileEntries
//==============================================================

function TZipFileEntries.GetZ(AIndex: Integer): TZipFileEntry;
begin
  Result := TZipFileEntry(Items[AIndex]);
end;

function TZipFileEntries.AddFileEntry(const ADiskFileName: string): TZipFileEntry;
begin
  Result := TZipFileEntry(Add);
  Result.DiskFileName := ADiskFileName;
end;

function TZipFileEntries.AddFileEntry(const ADiskFileName, AArchiveFileName: string): TZipFileEntry;
begin
  Result := TZipFileEntry(Add);
  Result.DiskFileName := ADiskFileName;
  Result.ArchiveFileName := AArchiveFileName;
end;

function TZipFileEntries.AddFileEntry(const AStream: TStream; const AArchiveFileName: string): TZipFileEntry;
begin
  Result := TZipFileEntry(Add);
  Result.Stream := AStream;
  Result.ArchiveFileName := AArchiveFileName;
end;

//==============================================================
// TFullZipFileEntry / TFullZipFileEntries
//==============================================================

procedure TFullZipFileEntry.SetArchiveFileName(const AValue: string);
begin
  FArchiveFileName := StringReplace(AValue, '\', '/', [rfReplaceAll]);
end;

constructor TFullZipFileEntries.Create;
begin
  inherited Create(TFullZipFileEntry);
end;

function TFullZipFileEntries.GetZ(AIndex: Integer): TFullZipFileEntry;
begin
  Result := TFullZipFileEntry(Items[AIndex]);
end;

function TFullZipFileEntries.Add: TFullZipFileEntry;
begin
  Result := TFullZipFileEntry(inherited Add);
end;

//==============================================================
// TZipper
//==============================================================

constructor TZipper.Create;
begin
  inherited Create;
  FEntries := TZipFileEntries.Create(TZipFileEntry);
end;

destructor TZipper.Destroy;
begin
  FreeAndNil(FEntries);
  inherited Destroy;
end;

procedure TZipper.ZipAllFiles;
var
  ZF: TZipFile;
  i: Integer;
  E: TZipFileEntry;
  FS: TFileStream;
begin
  if FFileName = '' then
    raise EZipError.Create('TZipper.FileName is not set');
  ZF := TZipFile.Create;
  try
    ZF.Open(FFileName, zmWrite);
    for i := 0 to FEntries.Count - 1 do
    begin
      E := FEntries[i];
      if Assigned(E.Stream) then
      begin
        E.Stream.Position := 0;
        ZF.Add(E.Stream, E.ArchiveFileName, zcDeflate);
      end
      else if E.DiskFileName <> '' then
      begin
        FS := TFileStream.Create(E.DiskFileName, fmOpenRead or fmShareDenyWrite);
        try
          ZF.Add(FS, E.ArchiveFileName, zcDeflate);
        finally
          FS.Free;
        end;
      end;
    end;
  finally
    ZF.Free;
  end;
end;

//==============================================================
// TUnZipper
//==============================================================

constructor TUnZipper.Create;
begin
  inherited Create;
  FEntries := TFullZipFileEntries.Create;
  FOutputPath := '';
end;

destructor TUnZipper.Destroy;
begin
  FreeAndNil(FEntries);
  inherited Destroy;
end;

// Case-insensitive file name lookup in ZIP
function TUnZipper.FindInZip(AZipFile: TZipFile; const AArchiveName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to AZipFile.FileCount - 1 do
    if SameText(AZipFile.FileName[i], AArchiveName) then
    begin
      Result := i;
      Exit;
    end;
end;

procedure TUnZipper.Examine;
var
  ZF: TZipFile;
  i: Integer;
  E: TFullZipFileEntry;
  Hdr: TZipHeader;
begin
  FEntries.Clear;
  ZF := TZipFile.Create;
  try
    ZF.Open(FFileName, zmRead);
    for i := 0 to ZF.FileCount - 1 do
    begin
      Hdr := ZF.FileInfo[i];
      E := FEntries.Add;
      E.ArchiveFileName := ZF.FileName[i];
      E.Size := Hdr.UncompressedSize;
      E.CompressedSize := Hdr.CompressedSize;
    end;
  finally
    ZF.Free;
  end;
end;

procedure TUnZipper.UnZipAllFiles;
begin
  if FOutputPath = '' then
    FOutputPath := ExtractFilePath(FFileName);
  TZipFile.ExtractZipFile(FFileName, FOutputPath);
end;

procedure TUnZipper.UnZipFileToStream(const AArchiveName: string; AStream: TStream);
var
  ZF: TZipFile;
  Bytes: TBytes;
  Idx: Integer;
begin
  ZF := TZipFile.Create;
  try
    ZF.Open(FFileName, zmRead);
    Idx := FindInZip(ZF, AArchiveName);
    if Idx >= 0 then
    begin
      ZF.Read(Idx, Bytes);
      if Length(Bytes) > 0 then
        AStream.WriteBuffer(Bytes[0], Length(Bytes));
    end;
  finally
    ZF.Free;
  end;
end;

procedure TUnZipper.ExtractOne(AZipFile: TZipFile; const AArchiveName: string; AEntry: TFullZipFileEntry);
var
  OutStream: TStream;
  Bytes: TBytes;
  Idx: Integer;
begin
  OutStream := nil;

  // 1. Caller allocates the output stream
  if Assigned(FOnCreateStream) then
    FOnCreateStream(Self, OutStream, AEntry);
  if OutStream = nil then
    OutStream := TMemoryStream.Create;

  try
    // 2. Decompress into stream using index-based Read (avoids overload ambiguity)
    Idx := FindInZip(AZipFile, AArchiveName);
    if Idx >= 0 then
    begin
      AZipFile.Read(Idx, Bytes);
      if Length(Bytes) > 0 then
        OutStream.WriteBuffer(Bytes[0], Length(Bytes));
    end;

    // 3. Caller processes the stream
    if Assigned(FOnDoneStream) then
      FOnDoneStream(Self, OutStream, AEntry)
    else
      FreeAndNil(OutStream);
  except
    FreeAndNil(OutStream);
    raise;
  end;
end;

procedure TUnZipper.UnZipFiles(AFiles: TStrings);
var
  ZF: TZipFile;
  i, j: Integer;
  Name: string;
  Entry: TFullZipFileEntry;
  Dummy: TFullZipFileEntry;
begin
  if (AFiles = nil) or (AFiles.Count = 0) then
    Exit;
  ZF := TZipFile.Create;
  try
    ZF.Open(FFileName, zmRead);
    for i := 0 to AFiles.Count - 1 do
    begin
      Name := AFiles[i];
      Entry := nil;
      for j := 0 to FEntries.Count - 1 do
        if SameText(FEntries[j].ArchiveFileName, Name) then
        begin
          Entry := FEntries[j];
          Break;
        end;

      if Entry <> nil then
        ExtractOne(ZF, Name, Entry)
      else
      begin
        Dummy := TFullZipFileEntry.Create(nil);
        try
          Dummy.ArchiveFileName := Name;
          ExtractOne(ZF, Name, Dummy);
        finally
          Dummy.Free;
        end;
      end;
    end;
  finally
    ZF.Free;
  end;
end;

end.

