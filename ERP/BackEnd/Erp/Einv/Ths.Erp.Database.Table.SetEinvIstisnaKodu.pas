unit Ths.Erp.Database.Table.SetEinvIstisnaKodu;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetEInvFaturaTipi;

type
  TSetEinvIstisnaKodu = class(TTable)
  private
    FIstisnaKodu: TFieldDB;
    FAciklama: TFieldDB;
    FIsTamIstisna: TFieldDB;
    FFaturaTipiID: TFieldDB;
    FFaturaTipi: TFieldDB;
  published
    FSetEInvFaturaTipi: TSetEinvFaturaTipi;

    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IstisnaKodu: TFieldDB read FIstisnaKodu write FIstisnaKodu;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsTamIstisna: TFieldDB read FIsTamIstisna write FIsTamIstisna;
    Property FaturaTipiID: TFieldDB read FFaturaTipiID write FFaturaTipiID;
    Property FaturaTipi: TFieldDB read FFaturaTipi write FFaturaTipi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSetEinvIstisnaKodu.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_istisna_kodu';
  TableSourceCode := '1010';
  inherited Create(ADatabase);

  FSetEInvFaturaTipi := TSetEinvFaturaTipi.Create(Database);

  FIstisnaKodu := TFieldDB.Create('istisna_kodu', ftString, '', Self, 'Ýstisna Kodu');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'Açýklama');
  FIsTamIstisna := TFieldDB.Create('is_tam_istisna', ftBoolean, False, Self, 'Tam Ýstisna');
  FFaturaTipiID := TFieldDB.Create('fatura_tipi_id', ftInteger, 0, Self, 'Fatura Tipi ID');
  FFaturaTipi := TFieldDB.Create(FSetEInvFaturaTipi.FaturaTipi.FieldName, FSetEInvFaturaTipi.FaturaTipi.DataType, '', Self, 'Fatura Tipi');
end;

destructor TSetEinvIstisnaKodu.Destroy;
begin
  FSetEInvFaturaTipi.Free;
  inherited;
end;

procedure TSetEinvIstisnaKodu.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FIstisnaKodu.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsTamIstisna.FieldName,
        TableName + '.' + FFaturaTipiID.FieldName,
        addLangField(FFaturaTipi.FieldName)
      ], [
        addLeftJoin(FFaturaTipi.FieldName, FFaturaTipiID.FieldName, FSetEInvFaturaTipi.TableName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FIstisnaKodu, 'Ýstisna Kodu', QueryOfDS);
      setFieldTitle(FAciklama, 'Açýklama', QueryOfDS);
      setFieldTitle(FIsTamIstisna, 'Tam Ýstisna?', QueryOfDS);
      setFieldTitle(FFaturaTipiID, 'Fatura Tip ID', QueryOfDS);
      setFieldTitle(FFaturaTipi, 'Fatura Tipi', QueryOfDS);
    end;
  end;
end;

procedure TSetEinvIstisnaKodu.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FIstisnaKodu.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsTamIstisna.FieldName,
        TableName + '.' + FFaturaTipiID.FieldName,
        addLangField(FFaturaTipi.FieldName)
      ], [
        addLeftJoin(FFaturaTipi.FieldName, FFaturaTipiID.FieldName, FSetEInvFaturaTipi.TableName),
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

procedure TSetEinvIstisnaKodu.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FIstisnaKodu.FieldName,
        FAciklama.FieldName,
        FIsTamIstisna.FieldName,
        FFaturaTipiID.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSetEinvIstisnaKodu.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FIstisnaKodu.FieldName,
        FAciklama.FieldName,
        FIsTamIstisna.FieldName,
        FFaturaTipiID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSetEinvIstisnaKodu.Clone: TTable;
begin
  Result := TSetEinvIstisnaKodu.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
