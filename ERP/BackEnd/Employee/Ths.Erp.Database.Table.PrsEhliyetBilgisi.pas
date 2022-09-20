unit Ths.Erp.Database.Table.PrsEhliyetBilgisi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetPrsEhliyet;

type
  TPrsEhliyetBilgisi = class(TTable)
  private
    FEhliyetID: TFieldDB;
    FEhliyet: TFieldDB;
    FPersonelID: TFieldDB;
    FPersonel: TFieldDB;
    FIsAktif: TFieldDB;
  protected
    FSetEhliyet: TSetPrsEhliyet;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property EhliyetID: TFieldDB read FEhliyetID write FEhliyetID;
    Property Ehliyet: TFieldDB read FEhliyet write FEhliyet;
    Property PersonelID: TFieldDB read FPersonelID write FPersonelID;
    Property Personel: TFieldDB read FPersonel write FPersonel;
    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Table.PrsPersonel;


constructor TPrsEhliyetBilgisi.Create(ADatabase: TDatabase);
var
  LPers: TPrsPersonel;
begin
  TableName := 'prs_ehliyet_bilgisi';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FSetEhliyet := TSetPrsEhliyet.Create(Database);

  LPers := TPrsPersonel.Create(Database);
  try
    FEhliyetID := TFieldDB.Create('ehliyet_id', ftInteger, 0, Self, 'Ehliyet ID');
    FEhliyet := TFieldDB.Create(FSetEhliyet.Ehliyet.FieldName, FSetEhliyet.Ehliyet.DataType, '', Self, 'Ehliyet');
    FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self, 'Personel Kartý ID');
    FPersonel := TFieldDB.Create(LPers.AdSoyad.FieldName, LPers.AdSoyad.DataType, LPers.AdSoyad.Value, Self, 'Personel Kartý');
    FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, False, Self, 'Aktif?');
  finally
    LPers.Free;
  end;
end;

destructor TPrsEhliyetBilgisi.Destroy;
begin
  FreeAndNil(FSetEhliyet);
  inherited;
end;

procedure TPrsEhliyetBilgisi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
var
  LPers: TPrsPersonel;
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    LPers := TPrsPersonel.Create(Database);
    try
      with QueryOfDS do
      begin
        Close;
        SQL.Clear;
        Database.GetSQLSelectCmd(QueryOfDS, TableName, [
          Id.QryName,
          FEhliyetID.QryName,
          addField(FSetEhliyet.TableName, FSetEhliyet.Ehliyet.FieldName, FEhliyet.FieldName),
          FPersonelID.QryName,
          addField(LPers.TableName, LPers.AdSoyad.FieldName, FPersonel.FieldName),
          FIsAktif.QryName
        ], [
          addJoin(jtLeft, FSetEhliyet.TableName, FSetEhliyet.Id.FieldName, TableName, FEhliyet.FieldName),
          addJoin(jtLeft, LPers.TableName, LPers.Id.FieldName, TableName, FPersonelID.FieldName),
          ' WHERE 1=1 ', AFilter
        ], AAllColumn, AHelper);
        Open;
      end;
    finally
      LPers.Free;
    end;
  end;
end;

procedure TPrsEhliyetBilgisi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LPers: TPrsPersonel;
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    LPers := TPrsPersonel.Create(Database);
    try
      with QueryOfList do
      begin
        Close;
        Database.GetSQLSelectCmd(QueryOfList, TableName, [
          Id.QryName,
          FEhliyetID.QryName,
          addField(FSetEhliyet.TableName, FSetEhliyet.Ehliyet.FieldName, FEhliyet.FieldName),
          FPersonelID.QryName,
          addField(LPers.TableName, LPers.AdSoyad.FieldName, FPersonel.FieldName),
          FIsAktif.QryName
        ], [
          addJoin(jtLeft, FSetEhliyet.TableName, FSetEhliyet.Id.FieldName, TableName, FEhliyet.FieldName),
          addJoin(jtLeft, LPers.TableName, LPers.Id.FieldName, TableName, FPersonelID.FieldName),
          ' WHERE 1=1 ', AFilter
        ]);
        Open;

        FreeListContent();
        List.Clear;
        while NOT EOF do
        begin
          PrepareTableClassFromQuery(QueryOfList);

          List.Add(Clone);

          Next;
        end;
        Close;
      end;
    finally
      LPers.Free;
    end;
  end;
end;

procedure TPrsEhliyetBilgisi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FEhliyetID.FieldName,
        FPersonelID.FieldName,
        FIsAktif.FieldName
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

procedure TPrsEhliyetBilgisi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FEhliyetID.FieldName,
        FPersonelID.FieldName,
        FIsAktif.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TPrsEhliyetBilgisi.Clone: TTable;
begin
  Result := TPrsEhliyetBilgisi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
