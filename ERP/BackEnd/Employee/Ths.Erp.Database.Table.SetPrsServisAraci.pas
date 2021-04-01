unit Ths.Erp.Database.Table.SetPrsServisAraci;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSetPrsServisAraci = class(TTable)
  private
    FAracNo: TFieldDB;
    FAracAdi: TFieldDB;
//    FRota: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property AracNo: TFieldDB read FAracNo write FAracNo;
    Property AracAdi: TFieldDB read FAracAdi write FAracAdi;
//    property Rota: TFieldDB read FRota write FRota;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSetPrsServisAraci.Create(ADatabase: TDatabase);
begin
  TableName := 'set_prs_servis_araci';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FAracNo := TFieldDB.Create('arac_no', ftInteger, 0, Self, 'Araç No');
  FAracAdi := TFieldDB.Create('arac_adi', ftString, '', Self, 'Araç Adý');
//  FRota := TFieldDB.Create('rota', ftString, '', Self, 'Rota');
end;

procedure TSetPrsServisAraci.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FAracNo.FieldName,
        TableName + '.' + FAracAdi.FieldName
//        TableName + '.' + FRota.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSetPrsServisAraci.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FAracNo.FieldName,
        TableName + '.' + FAracAdi.FieldName
//        TableName + '.' + FRota.FieldName
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

procedure TSetPrsServisAraci.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FAracNo.FieldName,
        FAracAdi.FieldName
//        FRota.FieldName
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

procedure TSetPrsServisAraci.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FAracNo.FieldName,
        FAracAdi.FieldName
//        FRota.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSetPrsServisAraci.Clone: TTable;
begin
  Result := TSetPrsServisAraci.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
