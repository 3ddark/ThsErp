unit Ths.Erp.Database.Table.SysLisanDataIcerik;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSysLisanDataIcerik = class(TTable)
  private
    FLisan: TFieldDB;
    FTabloAdi: TFieldDB;
    FKolonAdi: TFieldDB;
    FRowID: TFieldDB;
    FDeger: TFieldDB;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Lisan: TFieldDB read FLisan write FLisan;
    Property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    Property KolonAdi: TFieldDB read FKolonAdi write FKolonAdi;
    Property RowID: TFieldDB read FRowID write FRowID;
    Property Deger: TFieldDB read FDeger write FDeger;
  end;

implementation

uses
  Ths.Erp.Constants,
  Ths.Erp.Globals,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysLisan;

constructor TSysLisanDataIcerik.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_lisan_data_icerik';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FLisan := TFieldDB.Create('lisan', ftString, '', Self, 'Lisan');
  FTabloAdi := TFieldDB.Create('tablo_adi', ftString, '', Self, 'Tablo Adý');
  FKolonAdi := TFieldDB.Create('kolon_adi', ftString, '', Self, 'Kolon Adý');
  FRowID := TFieldDB.Create('row_id', ftInteger, 0, Self, 'Row ID');
  FDeger := TFieldDB.Create('deger', ftString, '', Self, 'Deðer');
end;

procedure TSysLisanDataIcerik.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FLisan.FieldName,
        TableName + '.' + FTabloAdi.FieldName,
        TableName + '.' + FKolonAdi.FieldName,
        TableName + '.' + FRowID.FieldName,
        TableName + '.' + FDeger.FieldName + '::varchar'
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSysLisanDataIcerik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FLisan.FieldName,
        TableName + '.' + FTabloAdi.FieldName,
        TableName + '.' + FKolonAdi.FieldName,
        TableName + '.' + FRowID.FieldName,
        TableName + '.' + FDeger.FieldName + '::varchar'
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

procedure TSysLisanDataIcerik.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FLisan.FieldName,
        FTabloAdi.FieldName,
        FKolonAdi.FieldName,
        FRowID.FieldName,
        FDeger.FieldName
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

procedure TSysLisanDataIcerik.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FLisan.FieldName,
        FTabloAdi.FieldName,
        FKolonAdi.FieldName,
        FRowID.FieldName,
        FDeger.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSysLisanDataIcerik.Clone: TTable;
begin
  Result := TSysLisanDataIcerik.Create(Database);
  CloneClassContent(Self, Result);
end;

procedure TSysLisanDataIcerik.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LLangCntt: TSysLisanDataIcerik;
begin
  LLangCntt := TSysLisanDataIcerik.Create(Self.Database);
  try
    LLangCntt.SelectToList(
          ' AND ' + TableName + '.' + LLangCntt.FLisan.FieldName        + '=' + QuotedStr(FormatedVariantVal(FLisan.DataType, FLisan.Value)) +
          ' AND ' + TableName + '.' + LLangCntt.FTabloAdi.FieldName   + '=' + QuotedStr(FormatedVariantVal(FTabloAdi.DataType, FTabloAdi.Value)) +
          ' AND ' + TableName + '.' + LLangCntt.FKolonAdi.FieldName  + '=' + QuotedStr(FormatedVariantVal(FKolonAdi.DataType, FKolonAdi.Value)) +
          ' AND ' + TableName + '.' + LLangCntt.FRowID.FieldName       + '=' + QuotedStr(FormatedVariantVal(FRowID.DataType, FRowID.Value)),
          False, False);
    if LLangCntt.List.Count = 1 then
    begin
      Self.Id.Value := LLangCntt.Id.Value;
      Self.Update(False)
    end
    else
      Self.Insert(AID, APermissionControl);
  finally
    FreeAndNil(LLangCntt)
  end;
end;

end.
