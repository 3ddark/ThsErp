unit Ths.Erp.Database.Table.UtdDokuman;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , System.DateUtils
  , System.IOUtils
  , System.AnsiStrings
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  , Ths.Erp.Database.Table.SetUtdDokumanTipi
  , Ths.Erp.Database.Table.SetUtdDosyaUzantisi
  ;

type
  TUtdDokuman = class(TTable)
  private
    FSiparisNo: TFieldDB;
    FDokumanTipiID: TFieldDB;
    FDokumanTipi: TFieldDB; //veri tabaný alaný deðil
    FDosyaUzantisiID: TFieldDB;
    FDosyaUzantisi: TFieldDB; //veri tabaný alaný deðil
    FDosyaAdi: TFieldDB;
    FLocalDosyaAdi: TFieldDB; //veri tabaný alaný deðil
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    FDocTip: TSetUtdDokumanTipi;
    FDocExt: TSetUtdDosyaUzantisi;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    function GenerateFileNameFake: string;
    function GetFileName(AFake: Boolean = False): string;
    function ExtractFileNameFromFake(AFileName: string): string;

    Property SiparisNo: TFieldDB read FSiparisNo write FSiparisNo;
    Property DokumanTipiID: TFieldDB read FDokumanTipiID write FDokumanTipiID;
    Property DokumanTipi: TFieldDB read FDokumanTipi write FDokumanTipi;  //veri tabaný alaný deðil
    Property DosyaUzantisiID: TFieldDB read FDosyaUzantisiID write FDosyaUzantisiID;
    Property DosyaUzantisi: TFieldDB read FDosyaUzantisi write FDosyaUzantisi;  //veri tabaný alaný deðil
    Property DosyaAdi: TFieldDB read FDosyaAdi write FDosyaAdi;
    Property LocalDosyaAdi: TFieldDB read FLocalDosyaAdi write FLocalDosyaAdi;  //veri tabaný alaný deðil
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TUtdDokuman.Create(ADatabase: TDatabase);
begin
  TableName := 'utd_dokuman';
  TableSourceCode := '7411';
  inherited Create(ADatabase);

  FDocTip := TSetUtdDokumanTipi.Create(Database);
  FDocExt := TSetUtdDosyaUzantisi.Create(Database);

  FSiparisNo := TFieldDB.Create('siparis_no', ftString, '', Self, '');
  FDokumanTipiID := TFieldDB.Create('dokuman_tipi_id', ftInteger, 0, Self, '');
  FDokumanTipi := TFieldDB.Create(FDocTip.DokumanTipi.FieldName, FDocTip.DokumanTipi.DataType, '', Self, '');
  FDosyaUzantisiID := TFieldDB.Create('dosya_uzantisi_id', ftInteger, 0, Self, '');
  FDosyaUzantisi := TFieldDB.Create(FDocExt.DosyaUzantisi.FieldName, FDocExt.DosyaUzantisi.DataType, '', Self, '');
  FDosyaAdi := TFieldDB.Create('dosya_adi', ftString, '', Self, '');
  FLocalDosyaAdi := TFieldDB.Create('local_dosya_adi', ftString, '', Self, '');
end;

destructor TUtdDokuman.Destroy;
begin
  FreeAndNil(FDocTip);
  FreeAndNil(FDocExt);
  inherited;
end;

function TUtdDokuman.ExtractFileNameFromFake(AFileName: string): string;
var
  LPos1, LPos2: SmallInt;
begin
  LPos1 := Pos('_', AFileName);
  LPos2 := Pos('.', AFileName);
  Result := Copy(AFileName, LPos1+1, LPos2 - LPos1-1);
end;

function TUtdDokuman.GenerateFileNameFake: string;
var
  LDocTip: TSetUtdDokumanTipi;
  LDocExt: TSetUtdDosyaUzantisi;
  LTime: TTime;
begin
  Result := '';
  LDocTip := TSetUtdDokumanTipi.Create(Database);
  LDocExt := TSetUtdDosyaUzantisi.Create(Database);
  try
    LDocTip.SelectToList(' AND ' + LDocTip.TableName + '.' + LDocTip.Id.FieldName + '=' + IntToStr(FormatedVariantVal(FDokumanTipiID)), False, False);
    LDocExt.SelectToList(' AND ' + LDocExt.TableName + '.' + LDocExt.Id.FieldName + '=' + IntToStr(FormatedVariantVal(FDosyaUzantisiID)), False, False);

    LTime := Now();

    Result := FormatedVariantVal(GSysUygulamaAyariDiger.PathUTD) + PathDelim
            + FormatedVariantVal(Self.FSiparisNo) + PathDelim
            + FormatedVariantVal(LDocTip.AltKlasor) + '_' + IntToHex(Trunc(LTime)) + '.' + FormatedVariantVal(LDocExt.FakeDosyaUzantisi);
  finally
    FreeAndNil(LDocTip);
    FreeAndNil(LDocExt);
  end;
end;

function TUtdDokuman.GetFileName(AFake: Boolean): string;
var
  LDocTip: TSetUtdDokumanTipi;
  LDocExt: TSetUtdDosyaUzantisi;
  LExtension: string;
begin
  Result := '';
  LDocTip := TSetUtdDokumanTipi.Create(Database);
  LDocExt := TSetUtdDosyaUzantisi.Create(Database);
  try
    LDocTip.SelectToList(' AND ' + LDocTip.TableName + '.' + LDocTip.Id.FieldName + '=' + IntToStr(FormatedVariantVal(FDokumanTipiID)), False, False);
    LDocExt.SelectToList(' AND ' + LDocExt.TableName + '.' + LDocExt.Id.FieldName + '=' + IntToStr(FormatedVariantVal(FDosyaUzantisiID)), False, False);

    if AFake then
     LExtension := FormatedVariantVal(LDocExt.FakeDosyaUzantisi)
    else
     LExtension := FormatedVariantVal(LDocExt.DosyaUzantisi);

    Result := FormatedVariantVal(GSysUygulamaAyariDiger.PathUTD) + PathDelim
            + FormatedVariantVal(Self.FSiparisNo) + PathDelim
            + FormatedVariantVal(LDocTip.AltKlasor) + '_' + FormatedVariantVal(DosyaAdi) + '.' + LExtension;
  finally
    FreeAndNil(LDocTip);
    FreeAndNil(LDocExt);
  end;
end;

procedure TUtdDokuman.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FSiparisNo.FieldName,
        TableName + '.' + FDokumanTipiID.FieldName,
        FDocTip.TableName + '.' + FDocTip.DokumanTipi.FieldName + ' ' + FDokumanTipi.FieldName,
        TableName + '.' + FDosyaUzantisiID.FieldName,
        FDocExt.TableName + '.' + FDocExt.DosyaUzantisi.FieldName + ' ' + FDosyaUzantisi.FieldName,
        TableName + '.' + FDosyaAdi.FieldName
      ], [
        ' LEFT JOIN ' + FDocTip.TableName + ' ON ' + FDocTip.TableName + '.id=' + Self.TableName + '.' + FDokumanTipiID.FieldName,
        ' LEFT JOIN ' + FDocExt.TableName + ' ON ' + FDocExt.TableName + '.id=' + Self.TableName + '.' + FDosyaUzantisiID.FieldName,
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FSiparisNo, 'Siparis No', QueryOfDS);
      setFieldTitle(FDokumanTipiID, 'Doküman Tip ID', QueryOfDS);
      setFieldTitle(FDokumanTipi, 'Doküman Tipi', QueryOfDS);
      setFieldTitle(FDosyaUzantisiID, 'Dosya Uzantýsý ID', QueryOfDS);
      setFieldTitle(FDosyaUzantisi, 'Dosya Uzantýsý', QueryOfDS);
      setFieldTitle(FDosyaAdi, 'Dosya Adý', QueryOfDS);
    end;
  end;
end;

procedure TUtdDokuman.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FSiparisNo.FieldName,
        TableName + '.' + FDokumanTipiID.FieldName,
        FDocTip.TableName + '.' + FDocTip.DokumanTipi.FieldName + ' ' + FDokumanTipi.FieldName,
        TableName + '.' + FDosyaUzantisiID.FieldName,
        FDocExt.TableName + '.' + FDocExt.DosyaUzantisi.FieldName + ' ' + FDosyaUzantisi.FieldName,
        TableName + '.' + FDosyaAdi.FieldName
      ], [
        ' LEFT JOIN ' + FDocTip.TableName + ' ON ' + FDocTip.TableName + '.id=' + Self.TableName + '.' + FDokumanTipiID.FieldName,
        ' LEFT JOIN ' + FDocExt.TableName + ' ON ' + FDocExt.TableName + '.id=' + Self.TableName + '.' + FDosyaUzantisiID.FieldName,
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TUtdDokuman.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FSiparisNo.FieldName,
        FDokumanTipiID.FieldName,
        FDosyaUzantisiID.FieldName,
        FDosyaAdi.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
        AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else
        AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.Notify;
  end;
end;

procedure TUtdDokuman.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FSiparisNo.FieldName,
        FDokumanTipiID.FieldName,
        FDosyaUzantisiID.FieldName,
        FDosyaAdi.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.Notify;
  end;
end;

procedure TUtdDokuman.BusinessDelete(APermissionControl: Boolean);
var
  LFullPath: string;
  LDocTip: TSetUtdDokumanTipi;
begin
  Self.Delete(APermissionControl);
  LDocTip := TSetUtdDokumanTipi.Create(Database);
  try
    LDocTip.SelectToList(' AND ' + LDocTip.TableName + '.' + LDocTip.Id.FieldName + '=' + FormatedVariantVal(FDokumanTipiID), False, False);

    LFullPath := FormatedVariantVal(GSysUygulamaAyariDiger.PathUTD) + PathDelim
               + FormatedVariantVal(Self.FSiparisNo) + PathDelim
               + FormatedVariantVal(LDocTip.AltKlasor) + '_' + IntToHex(trunc(Now())) + '.' + FormatedVariantVal(FDosyaUzantisi);

    FormatedVariantVal(Self.FDosyaAdi);
    if FileExists(LFullPath) then
      DeleteFile(LFullPath);
  finally
    FreeAndNil(LDocTip);
  end;
end;

procedure TUtdDokuman.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LFullName: string;
  LPath: string;
begin
  LFullName := GenerateFileNameFake;
  Self.DosyaAdi.Value := ExtractFileNameFromFake( ExtractFileName(LFullName) );
  Self.Insert(AID, APermissionControl);

  LPath := ExtractFilePath(LFullName);
  if not FileExists(LFullName) then
  begin
    if not DirectoryExists(LPath) then  //check folder
      ForceDirectories(LPath);  //create folder with subfolder
    TFile.Copy(FormatedVariantVal(FLocalDosyaAdi), LFullName, False);
  end;
end;

function TUtdDokuman.Clone: TTable;
begin
  Result := TUtdDokuman.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
