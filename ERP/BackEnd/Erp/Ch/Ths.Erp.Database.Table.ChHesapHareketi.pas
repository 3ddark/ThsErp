unit Ths.Erp.Database.Table.ChHesapHareketi;

interface

{$I ThsERP.inc}

uses
  SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

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
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

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
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TChHesapHareketi.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_hesap_hareketi';
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
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
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
end;

procedure TChHesapHareketi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
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
      QueryOfList.DisableControls;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Clone);

        Next;
      end;
      QueryOfList.EnableControls;
      Close;
    end;
  end;
end;

procedure TChHesapHareketi.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FHesapKodu.FieldName,
        FTutar.FieldName,
        FTutarDoviz.FieldName,
        FParaBirimi.FieldName,
        FIsBorc.FieldName,
        FTarih.FieldName,
        FIsDonemBasi.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TChHesapHareketi.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FHesapKodu.FieldName,
        FTutar.FieldName,
        FTutarDoviz.FieldName,
        FParaBirimi.FieldName,
        FIsBorc.FieldName,
        FTarih.FieldName,
        FIsDonemBasi.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TChHesapHareketi.Clone():TTable;
begin
  Result := TChHesapHareketi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
