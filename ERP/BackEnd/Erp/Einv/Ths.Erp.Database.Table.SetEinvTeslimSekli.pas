unit Ths.Erp.Database.Table.SetEinvTeslimSekli;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSetEinvTeslimSekli = class(TTable)
  private
    FIsAktif: TFieldDB;
    FTeslimSekli: TFieldDB;
    FAciklama: TFieldDB;
    FIsEFatura: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
    Property TeslimSekli: TFieldDB read FTeslimSekli write FTeslimSekli;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsEFatura: TFieldDB read FIsEFatura write FIsEFatura;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSetEinvTeslimSekli.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_teslim_sekli';
  TableSourceCode := '1010';
  inherited Create(ADatabase);

  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, '');
  FTeslimSekli := TFieldDB.Create('teslim_sekli', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FIsEFatura := TFieldDB.Create('is_efatura', ftBoolean, False, Self, '');
end;

procedure TSetEinvTeslimSekli.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FIsAktif.FieldName,
        TableName + '.' + FTeslimSekli.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsEfatura.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;

      setFieldTitle(Self.Id,'Id', QueryOfDS);
      setFieldTitle(FIsAktif, 'Atkif?', QueryOfDS);
      setFieldTitle(FTeslimSekli, 'Teslim �ekli', QueryOfDS);
      setFieldTitle(FAciklama, 'A��klama', QueryOfDS);
      setFieldTitle(FIsEFatura, 'E-Fatura?', QueryOfDS);
    end;
  end;
end;

procedure TSetEinvTeslimSekli.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FTeslimSekli.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsEfatura.FieldName
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

procedure TSetEinvTeslimSekli.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FIsAktif.FieldName,
        FTeslimSekli.FieldName,
        FAciklama.FieldName,
        FIsEFatura.FieldName
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

procedure TSetEinvTeslimSekli.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FIsAktif.FieldName,
        FTeslimSekli.FieldName,
        FAciklama.FieldName,
        FIsEFatura.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSetEinvTeslimSekli.Clone: TTable;
begin
  Result := TSetEinvTeslimSekli.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
