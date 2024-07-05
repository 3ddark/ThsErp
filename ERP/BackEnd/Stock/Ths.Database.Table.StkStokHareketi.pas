unit Ths.Database.Table.StkStokHareketi;

interface

{$I Ths.inc}

uses
  SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.StkAmbarlar;

type
  TStkStokHareketi = class(TTable)
  private
    FStokKodu: TFieldDB;
    FMiktar: TFieldDB;
    FTutar: TFieldDB;
    FTutarDoviz: TFieldDB;
    FParaBirimi: TFieldDB;
    FIsGiris: TFieldDB;
    FTarih: TFieldDB;
    FAmbarID: TFieldDB;
    FAmbar: TFieldDB;
    FIsDonemBasi: TFieldDB;
  protected
    FStkStokAmbar: TStkAmbar;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    Property Tutar: TFieldDB read FTutar write FTutar;
    Property TutarDoviz: TFieldDB read FTutarDoviz write FTutarDoviz;
    Property ParaBirimi: TFieldDB read FParaBirimi write FParaBirimi;
    Property IsGiris: TFieldDB read FIsGiris write FIsGiris;
    Property Tarih: TFieldDB read FTarih write FTarih;
    Property AmbarID: TFieldDB read FAmbarID write FAmbarID;
    Property Ambar: TFieldDB read FAmbar write FAmbar;
    Property IsDonemBasi: TFieldDB read FIsDonemBasi write FIsDonemBasi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TStkStokHareketi.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_hareketler';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FStkStokAmbar := TStkAmbar.Create(ADatabase);

  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self);
  FMiktar := TFieldDB.Create('miktar', ftBCD, 0, Self);
  FTutar := TFieldDB.Create('tutar', ftBCD, 0, Self);
  FTutarDoviz := TFieldDB.Create('tutar_doviz', ftBCD, 0, Self);
  FParaBirimi := TFieldDB.Create('para_birimi', ftWideString, '', Self);
  FIsGiris := TFieldDB.Create('is_giris', ftBoolean, True, Self);
  FTarih := TFieldDB.Create('tarih', ftDate, 0, Self);
  FAmbarID := TFieldDB.Create('ambar_id', ftInteger, 0, Self);
  FAmbar := TFieldDB.Create(FStkStokAmbar.AmbarAdi.FieldName, FStkStokAmbar.AmbarAdi.DataType, '', Self);
  FIsDonemBasi := TFieldDB.Create('is_donem_basi', ftBoolean, False, Self);
end;

destructor TStkStokHareketi.Destroy;
begin
  FStkStokAmbar.Free;
  inherited;
end;

function TStkStokHareketi.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FStokKodu.QryName,
      FMiktar.QryName,
      FTutar.QryName,
      FTutarDoviz.QryName,
      FParaBirimi.QryName,
      FIsGiris.QryName,
      FTarih.QryName,
      FAmbarID.QryName,
      addField(FStkStokAmbar.TableName, FStkStokAmbar.AmbarAdi.FieldName, FAmbarID.FieldName),
      FIsDonemBasi.QryName
    ], [
      addJoin(jtLeft, FStkStokAmbar.TableName, FStkStokAmbar.Id.FieldName, TableName, FAmbarID.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TStkStokHareketi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FStokKodu.QryName,
      FMiktar.QryName,
      FTutar.QryName,
      FTutarDoviz.QryName,
      FParaBirimi.QryName,
      FIsGiris.QryName,
      FTarih.QryName,
      FAmbarID.QryName,
      addField(FStkStokAmbar.TableName, FStkStokAmbar.AmbarAdi.FieldName, FAmbarID.FieldName),
      FIsDonemBasi.QryName
    ], [
      addJoin(jtLeft, FStkStokAmbar.TableName, FStkStokAmbar.Id.FieldName, TableName, FAmbarID.FieldName),
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

procedure TStkStokHareketi.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FTutar.FieldName,
      FTutarDoviz.FieldName,
      FParaBirimi.FieldName,
      FIsGiris.FieldName,
      FTarih.FieldName,
      FAmbarID.FieldName,
      FIsDonemBasi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TStkStokHareketi.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FTutar.FieldName,
      FTutarDoviz.FieldName,
      FParaBirimi.FieldName,
      FIsGiris.FieldName,
      FTarih.FieldName,
      FAmbarID.FieldName,
      FIsDonemBasi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TStkStokHareketi.Clone():TTable;
begin
  Result := TStkStokHareketi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
