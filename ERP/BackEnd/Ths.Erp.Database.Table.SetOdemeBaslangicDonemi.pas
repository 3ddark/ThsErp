unit Ths.Erp.Database.Table.SetOdemeBaslangicDonemi;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TSetOdemeBaslangicDonemi = class(TTable)
  private
    FOdemeBaslangicDonemi: TFieldDB;
    FAciklama: TFieldDB;
    FIsAktif: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property OdemeBaslangicDonemi: TFieldDB read FOdemeBaslangicDonemi write FOdemeBaslangicDonemi;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSetOdemeBaslangicDonemi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_odeme_baslangic_donemi';
  TableSourceCode := '1000';
  inherited Create(ADatabase);

  FOdemeBaslangicDonemi := TFieldDB.Create('odeme_baslangic_donemi', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, '');
end;

procedure TSetOdemeBaslangicDonemi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FOdemeBaslangicDonemi.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsAktif.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;

      setFieldTitle(Id, 'ID', QueryOfDS);
      setFieldTitle(FOdemeBaslangicDonemi, 'Ödeme Baþlangýç Dönemi', QueryOfDS);
      setFieldTitle(FAciklama, 'Açýklama', QueryOfDS);
      setFieldTitle(FIsAktif, 'Aktif?', QueryOfDS);
    end;
  end;
end;

procedure TSetOdemeBaslangicDonemi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FOdemeBaslangicDonemi.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsAktif.FieldName
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

procedure TSetOdemeBaslangicDonemi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FOdemeBaslangicDonemi.FieldName,
        FAciklama.FieldName,
        FIsAktif.FieldName
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

procedure TSetOdemeBaslangicDonemi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FOdemeBaslangicDonemi.FieldName,
        FAciklama.FieldName,
        FIsAktif.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSetOdemeBaslangicDonemi.Clone: TTable;
begin
  Result := TSetOdemeBaslangicDonemi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
