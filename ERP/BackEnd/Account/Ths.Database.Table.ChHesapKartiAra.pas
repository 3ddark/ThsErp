unit Ths.Database.Table.ChHesapKartiAra;

interface

{$I Ths.inc}

uses
  SysUtils,
  StrUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetChHesapTipi,
  Ths.Database.Table.ChHesapPlanlari;

type
  TChHesapKartiAra = class(TTable)
  private
    FHesapKodu: TFieldDB;
    FHesapIsmi: TFieldDB;
    FHesapTipiID: TFieldDB;
    FHesapTipi: TFieldDB;
    FKokKod: TFieldDB;
    FSeviye: TFieldDB;
  protected
    FSetChHesapTipi: TSetChHesapTipi;
    FSetChHesapPlani: TChHesapPlani;

    procedure BusinessDelete(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure Validate;

    Property HesapKodu: TFieldDB read FHesapKodu write FHesapKodu;
    Property HesapIsmi: TFieldDB read FHesapIsmi write FHesapIsmi;
    Property HesapTipiID: TFieldDB read FHesapTipiID write FHesapTipiID;
    Property HesapTipi: TFieldDB read FHesapTipi write FHesapTipi;
    Property KokKod: TFieldDB read FKokKod write FKokKod;
    Property Seviye: TFieldDB read FSeviye write FSeviye;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.ChHesapKarti;

procedure TChHesapKartiAra.BusinessDelete(APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
  LStr: string;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    LStr := FHesapKodu.AsString;
    //Bu ara hesaptan oluşturulmuş son hesap varsa silmeyi engelle
    LHesap.SelectToList(
      ' AND ' + LHesap.AraKod.QryName + '=' + QuotedStr(LStr) +
      ' AND ' + LHesap.HesapTipiID.QryName + '=' + IntToStr(Ord(htSon))
      , False, False);
    if LHesap.List.Count > 0 then
      raise Exception.Create(Trim('Bu hesaba bağlı Son Hesaplar oluşturulmuş! Önce bu hesaplar silinmeli. + 999999'));

    Delete(APermissionControl);
  finally
    LHesap.Free;
  end;
end;

constructor TChHesapKartiAra.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_hesaplar';
  TableSourceCode := MODULE_CH_KAYIT;
  inherited Create(ADatabase);

  FSetChHesapTipi := TSetChHesapTipi.Create(Database);
  FSetChHesapPlani := TChHesapPlani.Create(Database);

  FHesapKodu := TFieldDB.Create('hesap_kodu', ftWideString, '', Self);
  FHesapIsmi := TFieldDB.Create('hesap_ismi', ftWideString, '', Self);
  FHesapTipiID := TFieldDB.Create('hesap_tipi_id', ftInteger, 0, Self);
  FHesapTipi := TFieldDB.Create(FSetChHesapTipi.HesapTipi.FieldName, FSetChHesapTipi.HesapTipi.DataType, '', Self);
  FKokKod := TFieldDB.Create('kok_kod', ftWideString, '', Self);
  FSeviye := TFieldDB.Create(FSetChHesapPlani.Seviye.FieldName, FSetChHesapPlani.Seviye.DataType, FSetChHesapPlani.Seviye.Value, Self);
end;

destructor TChHesapKartiAra.Destroy;
begin
  FSetChHesapTipi.Free;
  FSetChHesapPlani.Free;

  inherited;
end;

function TChHesapKartiAra.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Self.Id.QryName,
      FHesapKodu.QryName,
      FHesapIsmi.QryName,
      FHesapTipiID.QryName,
      addField(FSetChHesapTipi.TableName, FSetChHesapTipi.HesapTipi.FieldName, FHesapTipi.FieldName),
      FKokKod.QryName,
      addField(FSetChHesapPlani.TableName, FSetChHesapPlani.Seviye.FieldName, FSeviye.FieldName)
    ], [
      addJoin(jtLeft, FSetChHesapTipi.TableName, FSetChHesapTipi.Id.FieldName, TableName, FHesapTipiID.FieldName),
      addJoin(jtLeft, FSetChHesapPlani.TableName, FSetChHesapPlani.PlanKodu.FieldName, TableName, FKokKod.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TChHesapKartiAra.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHesapKodu.QryName,
      FHesapIsmi.QryName,
      FHesapTipiID.QryName,
      addField(FSetChHesapTipi.TableName, FSetChHesapTipi.HesapTipi.FieldName, FHesapTipi.FieldName),
      FKokKod.QryName,
      addField(FSetChHesapPlani.TableName, FSetChHesapPlani.Seviye.FieldName, FSeviye.FieldName)
    ], [
      addJoin(jtLeft, FSetChHesapTipi.TableName, FSetChHesapTipi.Id.FieldName, TableName, FHesapTipiID.FieldName),
      addJoin(jtLeft, FSetChHesapPlani.TableName, FSetChHesapPlani.PlanKodu.FieldName, TableName, FKokKod.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TChHesapKartiAra.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHesapKodu.FieldName,
      FHesapIsmi.FieldName,
      FHesapTipiID.FieldName,
      FKokKod.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TChHesapKartiAra.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHesapKodu.FieldName,
      FHesapIsmi.FieldName,
      FHesapTipiID.FieldName,
      FKokKod.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TChHesapKartiAra.Validate;
var
  LStr: string;
begin
  if (KokKod.Value = '') then
    raise Exception.Create(Trim('Kök Hesap Kodu seçilmeden devam edilemez! + 999999'));

  LStr := ReverseString(FHesapKodu.AsString);
  if (LStr[1] = '-') then
    raise Exception.Create(Trim('Ara Hesap Kodu doğru girilmedi! Örnek Kod "120-001" gibi olmalı + 999999'));
end;

function TChHesapKartiAra.Clone: TTable;
begin
  Result := TChHesapKartiAra.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
