unit Ths.Database.Table.SysGuiIcerikler;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  System.Generics.Collections, Ths.Database, Ths.Database.Table;

type
  TGuiIcerik = record
    FKod: string;
    FIcerikTipi: string;
    FTabloAdi: string;
    FDeger: string;
    FIsFabrika: Boolean;
    FFormAdi: string;
  end;

type
  TSysGuiIcerik = class(TTable)
  private
    FKod: TFieldDB;
    FDeger: TFieldDB;
    FIsFabrika: TFieldDB;
    FIcerikTipi: TFieldDB;
    FTabloAdi: TFieldDB;
    FFormAdi: TFieldDB;
  protected
    procedure BusinessInsert(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property Kod: TFieldDB read FKod write FKod;
    property Deger: TFieldDB read FDeger write FDeger;
    property IsFabrika: TFieldDB read FIsFabrika write FIsFabrika;
    property IcerikTipi: TFieldDB read FIcerikTipi write FIcerikTipi;
    property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    property FormAdi: TFieldDB read FFormAdi write FFormAdi;
  end;

implementation

uses Ths.Globals, Ths.Constants;

constructor TSysGuiIcerik.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_gui_icerikler';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FKod := TFieldDB.Create('kod', ftString, '', Self);
  FDeger := TFieldDB.Create('deger', ftString, '', Self);
  FIsFabrika := TFieldDB.Create('is_fabrika', ftBoolean, False, Self);
  FIcerikTipi := TFieldDB.Create('icerik_tipi', ftString, '', Self);
  FTabloAdi := TFieldDB.Create('tablo_adi', ftString, '', Self);
  FFormAdi := TFieldDB.Create('form_adi', ftString, '', Self);
end;

function TSysGuiIcerik.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.FieldName,
      FKod.FieldName,
      'cast(' + FDeger.FieldName + ' as varchar) ' + FDeger.FieldName,
      FIsFabrika.FieldName,
      FIcerikTipi.FieldName,
      FTabloAdi.FieldName,
      FFormAdi.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSysGuiIcerik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.FieldName,
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

procedure TSysGuiIcerik.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FKod.FieldName,
      FDeger.FieldName,
      FIsFabrika.FieldName,
      FIcerikTipi.FieldName,
      FTabloAdi.FieldName,
      FFormAdi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysGuiIcerik.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FKod.FieldName,
      FDeger.FieldName,
      FIsFabrika.FieldName,
      FIcerikTipi.FieldName,
      FTabloAdi.FieldName,
      FFormAdi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TSysGuiIcerik.BusinessInsert(APermissionControl: Boolean);
var
  LSysGuiContent: TSysGuiIcerik;
  LFilter: string;
begin
  LSysGuiContent := TSysGuiIcerik.Create(Database);
  try
    if FTabloAdi.AsString <> '' then
      LFilter := ' AND ' + LSysGuiContent.FTabloAdi.QryName + '=' + QuotedStr(FTabloAdi.AsString);

    LSysGuiContent.SelectToList(' AND ' + FKod.QryName + '=' + QuotedStr(FKod.AsString) +
                                ' AND ' + FIcerikTipi.QryName + '=' + QuotedStr(FIcerikTipi.AsString) +
                                 LFilter, False, False);
    if LSysGuiContent.List.Count = 1 then
    begin
      Id.Value := LSysGuiContent.Id.Value;
      Update(False)
    end
    else
      Insert(APermissionControl);
  finally
    LSysGuiContent.Free;
  end;
end;

function TSysGuiIcerik.Clone: TTable;
begin
  Result := TSysGuiIcerik.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
