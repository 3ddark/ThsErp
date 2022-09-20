unit Ths.Erp.Database.Table.SetPrsGecisSistemiKarti;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSetPrsGecisSistemiKarti = class(TTable)
  private
    FKartID: TFieldDB;
    FPersonelNo: TFieldDB;
    FKartNo: TFieldDB;
    FIsAktif: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property KartID: TFieldDB read FKartID write FKartID;
    Property PersonelNo: TFieldDB read FPersonelNo write FPersonelNo;
    Property KartNo: TFieldDB read FKartNo write FKartNo;
    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TSetPrsGecisSistemiKarti.Create(ADatabase: TDatabase);
begin
  TableName := 'set_prs_gecis_sistemi_karti';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FKartID := TFieldDB.Create('kart_id', ftWideString, '', Self, 'Kart ID');
  FPersonelNo := TFieldDB.Create('personel_no', ftInteger, 0, Self, 'Personel No');
  FKartNo := TFieldDB.Create('kart_no', ftInteger, 0, Self, 'Kart No');
  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, 'Aktif?');
end;

procedure TSetPrsGecisSistemiKarti.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FKartID.QryName,
        FPersonelNo.QryName,
        FKartNo.QryName,
        FIsAktif.QryName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  end;
end;

procedure TSetPrsGecisSistemiKarti.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FKartID.QryName,
        FPersonelNo.QryName,
        FKartNo.QryName,
        FIsAktif.QryName
      ], [
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
  end;
end;

procedure TSetPrsGecisSistemiKarti.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FKartID.FieldName,
        FPersonelNo.FieldName,
        FKartNo.FieldName,
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

procedure TSetPrsGecisSistemiKarti.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FKartID.FieldName,
        FPersonelNo.FieldName,
        FKartNo.FieldName,
        FIsAktif.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TSetPrsGecisSistemiKarti.Clone: TTable;
begin
  Result := TSetPrsGecisSistemiKarti.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
