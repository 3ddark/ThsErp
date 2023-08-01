unit Ths.Database.Table.SysLisanVeriIcerikler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSysLisanVeriIcerik = class(TTable)
  private
    FLisan: TFieldDB;
    FTabloAdi: TFieldDB;
    FKolonAdi: TFieldDB;
    FSatirID: TFieldDB;
    FDeger: TFieldDB;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Lisan: TFieldDB read FLisan write FLisan;
    Property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    Property KolonAdi: TFieldDB read FKolonAdi write FKolonAdi;
    Property SatirID: TFieldDB read FSatirID write FSatirID;
    Property Deger: TFieldDB read FDeger write FDeger;
  end;

implementation

uses
  Ths.Constants,
  Ths.Globals;

constructor TSysLisanVeriIcerik.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_lisan_veri_icerikler';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FLisan := TFieldDB.Create('lisan', ftString, '', Self, 'Lisan');
  FTabloAdi := TFieldDB.Create('tablo_adi', ftString, '', Self, 'Table Adý');
  FKolonAdi := TFieldDB.Create('kolon_adi', ftString, '', Self, 'Kolon Adý');
  FSatirID := TFieldDB.Create('satir_id', ftInteger, 0, Self, 'Satýr ID');
  FDeger := TFieldDB.Create('deger', ftString, '', Self, 'Deðer');
end;

procedure TSysLisanVeriIcerik.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FLisan.QryName,
      FTabloAdi.QryName,
      FKolonAdi.QryName,
      FSatirID.QryName,
      FDeger.QryName + '::::varchar'
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysLisanVeriIcerik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FLisan.QryName,
      FTabloAdi.QryName,
      FKolonAdi.QryName,
      FSatirID.QryName,
      FDeger.QryName + '::::varchar'
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TSysLisanVeriIcerik.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FLisan.FieldName,
      FTabloAdi.FieldName,
      FKolonAdi.FieldName,
      FSatirID.FieldName,
      FDeger.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
    then  AID := Fields.FieldByName(Id.FieldName).AsInteger
    else  AID := 0;
  finally
    Free;
  end;
end;

procedure TSysLisanVeriIcerik.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FLisan.FieldName,
      FTabloAdi.FieldName,
      FKolonAdi.FieldName,
      FSatirID.FieldName,
      FDeger.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysLisanVeriIcerik.Clone: TTable;
begin
  Result := TSysLisanVeriIcerik.Create(Database);
  CloneClassContent(Self, Result);
end;

procedure TSysLisanVeriIcerik.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LLangCntt: TSysLisanVeriIcerik;
begin
  LLangCntt := TSysLisanVeriIcerik.Create(Database);
  try
    LLangCntt.SelectToList(
          ' AND ' + LLangCntt.FLisan.QryName        + '=' + QuotedStr(FLisan.AsString) +
          ' AND ' + LLangCntt.FTabloAdi.QryName   + '=' + QuotedStr(FTabloAdi.AsString) +
          ' AND ' + LLangCntt.FKolonAdi.QryName  + '=' + QuotedStr(FKolonAdi.AsString) +
          ' AND ' + LLangCntt.FSatirID.QryName       + '=' + QuotedStr(FSatirID.AsString),
          False, False);
    if LLangCntt.List.Count = 1 then
    begin
      Id.Value := LLangCntt.Id.Value;
      Update(False)
    end
    else
      Insert(AID, APermissionControl);
  finally
    LLangCntt.Free;
  end;
end;

end.
