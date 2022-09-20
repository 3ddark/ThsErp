unit Ths.Erp.Database.Table.StkStokHareketi;

interface

{$I ThsERP.inc}

uses
  SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.StkStokAmbar;

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
    FStkStokAmbar: TStkStokAmbar;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

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
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TStkStokHareketi.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_stok_hareketi';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FStkStokAmbar := TStkStokAmbar.Create(ADatabase);

  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self, 'Stok Kodu');
  FMiktar := TFieldDB.Create('miktar', ftBCD, 0, Self, 'Miktar');
  FTutar := TFieldDB.Create('tutar', ftBCD, 0, Self, 'Tutar');
  FTutarDoviz := TFieldDB.Create('tutar_doviz', ftBCD, 0, Self, 'Döviz Tutar');
  FParaBirimi := TFieldDB.Create('para_birimi', ftWideString, '', Self, 'Para Birimi');
  FIsGiris := TFieldDB.Create('is_giris', ftBoolean, True, Self, 'Giriþ?');
  FTarih := TFieldDB.Create('tarih', ftDate, 0, Self, 'Tarih');
  FAmbarID := TFieldDB.Create('ambar_id', ftInteger, 0, Self, 'Ambar ID');
  FAmbar := TFieldDB.Create(FStkStokAmbar.AmbarAdi.FieldName, FStkStokAmbar.AmbarAdi.DataType, '', Self, 'Ambar');
  FIsDonemBasi := TFieldDB.Create('is_donem_basi', ftBoolean, False, Self, 'Dönem Baþý?');
end;

destructor TStkStokHareketi.Destroy;
begin
  FStkStokAmbar.Free;
  inherited;
end;

procedure TStkStokHareketi.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
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
      Open;
    end;
  end;
end;

procedure TStkStokHareketi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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

procedure TStkStokHareketi.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
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

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
  end;
end;

procedure TStkStokHareketi.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
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

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
  end;
end;

function TStkStokHareketi.Clone():TTable;
begin
  Result := TStkStokHareketi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
