unit Ths.Erp.Database.Table.SetEinvPaketTipi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSetEinvPaketTipi = class(TTable)
  private
    FIsAktif: TFieldDB;
    FKod: TFieldDB;
    FPaketTipi: TFieldDB;
    FAciklama: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
    Property Kod: TFieldDB read FKod write FKod;
    Property PaketTipi: TFieldDB read FPaketTipi write FPaketTipi;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSetEinvPaketTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_paket_tipi';
  TableSourceCode := '1010';
  inherited Create(ADatabase);

  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, '');
  FKod := TFieldDB.Create('kod', ftString, '', Self, '');
  FPaketTipi := TFieldDB.Create('paket_tipi', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
end;

procedure TSetEinvPaketTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FIsAktif.FieldName,
        TableName + '.' + FKod.FieldName,
        TableName + '.' + FPaketTipi.FieldName,
        TableName + '.' + FAciklama.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;

      setFieldTitle(Self.Id,'Id', QueryOfDS);
      setFieldTitle(FIsAktif, 'Atkif?', QueryOfDS);
      setFieldTitle(FKod, 'Kod', QueryOfDS);
      setFieldTitle(FPaketTipi, 'Paket Adı?', QueryOfDS);
      setFieldTitle(FAciklama, 'Açıklama', QueryOfDS);
    end;
  end;
end;

procedure TSetEinvPaketTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FIsAktif.FieldName,
        TableName + '.' + FKod.FieldName,
        TableName + '.' + FPaketTipi.FieldName,
        TableName + '.' + FAciklama.FieldName
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

procedure TSetEinvPaketTipi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FIsAktif.FieldName,
        FKod.FieldName,
        FPaketTipi.FieldName,
        FAciklama.FieldName
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

procedure TSetEinvPaketTipi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FIsAktif.FieldName,
        FKod.FieldName,
        FPaketTipi.FieldName,
        FAciklama.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSetEinvPaketTipi.Clone: TTable;
begin
  Result := TSetEinvPaketTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
