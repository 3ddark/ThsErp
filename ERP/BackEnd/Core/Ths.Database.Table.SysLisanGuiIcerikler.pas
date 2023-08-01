unit Ths.Database.Table.SysLisanGuiIcerikler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  System.Generics.Collections,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysLisanlar;

type
  TGuiIcerik = record
    FLisan: string;
    FKod: string;
    FIcerikTipi: string;
    FTabloAdi: string;
    FDeger: string;
    FIsFabrika: Boolean;
    FFormAdi: string;
  end;

type
  TSysLisanGuiIcerik = class(TTable)
  private
    FLisan: TFieldDB;
    FKod: TFieldDB;
    FDeger: TFieldDB;
    FIsFabrika: TFieldDB;
    FIcerikTipi: TFieldDB;
    FTabloAdi: TFieldDB;
    FFormAdi: TFieldDB;
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

    property Lisan: TFieldDB read FLisan write FLisan;
    property Kod: TFieldDB read FKod write FKod;
    property Deger: TFieldDB read FDeger write FDeger;
    property IsFabrika: TFieldDB read FIsFabrika write FIsFabrika;
    property IcerikTipi: TFieldDB read FIcerikTipi write FIcerikTipi;
    property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    property FormAdi: TFieldDB read FFormAdi write FFormAdi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysLisanGuiIcerik.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_lisan_gui_icerikler';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FLisan := TFieldDB.Create('lisan', ftString, '', Self, 'Lisan');
  FKod := TFieldDB.Create('kod', ftString, '', Self, 'Kod');
  FDeger := TFieldDB.Create('deger', ftString, '', Self, 'Deðer');
  FIsFabrika := TFieldDB.Create('is_fabrika', ftBoolean, False, Self, 'Fabrika?');
  FIcerikTipi := TFieldDB.Create('icerik_tipi', ftString, '', Self, 'Ýçerik Tipi');
  FTabloAdi := TFieldDB.Create('tablo_adi', ftString, '', Self, 'Tablo Adý');
  FFormAdi := TFieldDB.Create('form_adi', ftString, '', Self, 'Form Adý');
end;

procedure TSysLisanGuiIcerik.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.FieldName,
      FLisan.FieldName,
      FKod.FieldName,
      FDeger.FieldName + '::::varchar ',
      FIsFabrika.FieldName,
      FIcerikTipi.FieldName,
      FTabloAdi.FieldName,
      FFormAdi.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysLisanGuiIcerik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Id.FieldName,
      FLisan.FieldName,
      FKod.FieldName,
      'cast(' + FDeger.FieldName + ' as varchar) ' + FDeger.FieldName,
      FIsFabrika.FieldName,
      FIcerikTipi.FieldName,
      FTabloAdi.FieldName,
      FFormAdi.FieldName
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
    Close;
  finally
    Free;
  end;
end;

procedure TSysLisanGuiIcerik.DoInsert(out AID: Integer; APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    Close;
    SQL.Clear;
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FLisan.FieldName,
      FKod.FieldName,
      FDeger.FieldName,
      FIsFabrika.FieldName,
      FIcerikTipi.FieldName,
      FTabloAdi.FieldName,
      FFormAdi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
    then  AID := Fields.FieldByName(Id.FieldName).AsInteger
    else  AID := 0;

    EmptyDataSet;
    Close;
  finally
    Free;
  end;
end;

procedure TSysLisanGuiIcerik.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Clear;
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FLisan.FieldName,
      FKod.FieldName,
      FDeger.FieldName,
      FIsFabrika.FieldName,
      FIcerikTipi.FieldName,
      FTabloAdi.FieldName,
      FFormAdi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

procedure TSysLisanGuiIcerik.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LSysGuiContent: TSysLisanGuiIcerik;
  LFilter: string;
begin
  LSysGuiContent := TSysLisanGuiIcerik.Create(Database);
  try
    if FTabloAdi.AsString <> '' then
      LFilter := ' AND ' + LSysGuiContent.FTabloAdi.QryName + '=' + QuotedStr(FTabloAdi.AsString);

    LSysGuiContent.SelectToList(' AND ' + FLisan.QryName + '=' + QuotedStr(FLisan.AsString) +
                                ' AND ' + FKod.QryName + '=' + QuotedStr(FKod.AsString) +
                                ' AND ' + FIcerikTipi.QryName + '=' + QuotedStr(FIcerikTipi.AsString) +
                                 LFilter, False, False);
    if LSysGuiContent.List.Count = 1 then
    begin
      Id.Value := LSysGuiContent.Id.Value;
      Update(False)
    end
    else
      Insert(AID, APermissionControl);
  finally
    LSysGuiContent.Free;
  end;
end;

function TSysLisanGuiIcerik.Clone: TTable;
begin
  Result := TSysLisanGuiIcerik.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
