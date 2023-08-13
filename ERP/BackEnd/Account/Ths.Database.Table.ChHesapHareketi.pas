unit Ths.Database.Table.ChHesapHareketi;

interface

{$I Ths.inc}

uses
  SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TChHesapHareketi = class(TTable)
  private
    FHesapKodu: TFieldDB;
    FTutar: TFieldDB;
    FTutarDoviz: TFieldDB;
    FParaBirimi: TFieldDB;
    FIsBorc: TFieldDB;
    FTarih: TFieldDB;
    FIsDonemBasi: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HesapKodu: TFieldDB read FHesapKodu write FHesapKodu;
    Property Tutar: TFieldDB read FTutar write FTutar;
    Property TutarDoviz: TFieldDB read FTutarDoviz write FTutarDoviz;
    Property ParaBirimi: TFieldDB read FParaBirimi write FParaBirimi;
    Property IsBorc: TFieldDB read FIsBorc write FIsBorc;
    Property Tarih: TFieldDB read FTarih write FTarih;
    Property IsDonemBasi: TFieldDB read FIsDonemBasi write FIsDonemBasi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TChHesapHareketi.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_hesap_hareketleri';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FHesapKodu := TFieldDB.Create('hesap_kodu', ftWideString, '', Self, 'Hesap Kodu');
  FTutar := TFieldDB.Create('tutar', ftBCD, 0, Self, 'Tutar');
  FTutarDoviz := TFieldDB.Create('tutar_doviz', ftBCD, 0, Self, 'Döviz Tutar');
  FParaBirimi := TFieldDB.Create('para_birimi', ftWideString, '', Self, 'Para Birimi');
  FIsBorc := TFieldDB.Create('is_giris', ftBoolean, True, Self, 'Borç?');
  FTarih := TFieldDB.Create('tarih', ftDate, 0, Self, 'Tarih');
  FIsDonemBasi := TFieldDB.Create('is_donem_basi', ftBoolean, False, Self, 'Dönem Baþý?');
end;

procedure TChHesapHareketi.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FHesapKodu.QryName,
      FTutar.QryName,
      FTutarDoviz.QryName,
      FParaBirimi.QryName,
      FIsBorc.QryName,
      FTarih.QryName,
      FIsDonemBasi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TChHesapHareketi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHesapKodu.QryName,
      FTutar.QryName,
      FTutarDoviz.QryName,
      FParaBirimi.QryName,
      FIsBorc.QryName,
      FTarih.QryName,
      FIsDonemBasi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
    LQry.DisableControls;
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      Next;
    end;
    LQry.EnableControls;
    Close;
  finally
    Free;
  end;
end;

procedure TChHesapHareketi.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FHesapKodu.FieldName,
      FTutar.FieldName,
      FTutarDoviz.FieldName,
      FParaBirimi.FieldName,
      FIsBorc.FieldName,
      FTarih.FieldName,
      FIsDonemBasi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TChHesapHareketi.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FHesapKodu.FieldName,
      FTutar.FieldName,
      FTutarDoviz.FieldName,
      FParaBirimi.FieldName,
      FIsBorc.FieldName,
      FTarih.FieldName,
      FIsDonemBasi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TChHesapHareketi.Clone():TTable;
begin
  Result := TChHesapHareketi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



