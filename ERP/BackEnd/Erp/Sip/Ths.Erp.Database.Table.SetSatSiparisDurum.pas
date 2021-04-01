unit Ths.Erp.Database.Table.SetSatSiparisDurum;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSatSiparisDurum = (Beklemede=1, Hazir, Gitti);
  TSetSatSiparisDurum = class(TTable)
  private
    FSiparisDurum: TFieldDB;
    FAciklama: TFieldDB;
    FIsActive: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property SiparisDurum: TFieldDB read FSiparisDurum write FSiparisDurum;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsActive: TFieldDB read FIsActive write FIsActive;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSetSatSiparisDurum.Create(ADatabase: TDatabase);
begin
  TableName := 'set_sat_siparis_durum';
  TableSourceCode := MODULE_TSIF_AYAR;
  inherited Create(ADatabase);

  FSiparisDurum := TFieldDB.Create('siparis_durum', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FIsActive := TFieldDB.Create('is_active', ftBoolean, True, Self, '');
end;

procedure TSetSatSiparisDurum.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FSiparisDurum.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsActive.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;

      setFieldTitle(Id, 'ID', QueryOfDS);
      setFieldTitle(FSiparisDurum, 'Siparis Durum', QueryOfDS);
      setFieldTitle(FAciklama, 'Açıklama', QueryOfDS);
      setFieldTitle(FIsActive, 'Aktif?', QueryOfDS);
    end;
  end;
end;

procedure TSetSatSiparisDurum.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FSiparisDurum.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsActive.FieldName
      ], [
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

procedure TSetSatSiparisDurum.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FSiparisDurum.FieldName,
        FAciklama.FieldName,
        FIsActive.FieldName
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

procedure TSetSatSiparisDurum.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FSiparisDurum.FieldName,
        FAciklama.FieldName,
        FIsActive.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSetSatSiparisDurum.Clone: TTable;
begin
  Result := TSetSatSiparisDurum.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
