unit Ths.Database.Table.StkAmbarlar;

interface

{$I Ths.inc}

uses
  SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, Ths.Database,
  Ths.Database.Table;

type
  TStkAmbar = class(TTable)
  private
    FAmbarAdi: TFieldDB;
    FIsVarsayilanHammadde: TFieldDB;
    FIsVarsayilanUretim: TFieldDB;
    FIsVarsayilanSatis: TFieldDB;
  protected
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property AmbarAdi: TFieldDB read FAmbarAdi write FAmbarAdi;
    Property IsVarsayilanHammadde: TFieldDB read FIsVarsayilanHammadde write FIsVarsayilanHammadde;
    Property IsVarsayilanUretim: TFieldDB read FIsVarsayilanUretim write FIsVarsayilanUretim;
    Property IsVarsayilanSatis: TFieldDB read FIsVarsayilanSatis write FIsVarsayilanSatis;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TStkAmbar.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_ambarlar';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FAmbarAdi := TFieldDB.Create('ambar_adi', ftWideString, '', Self, 'Ambar Adı');
  FIsVarsayilanHammadde := TFieldDB.Create('is_varsayilan_hammadde', ftBoolean, False, Self, 'Varsayılan Hammadde');
  FIsVarsayilanUretim := TFieldDB.Create('is_varsayilan_uretim', ftBoolean, False, Self, 'Varsayılan Üretim');
  FIsVarsayilanSatis := TFieldDB.Create('is_varsayilan_satis', ftBoolean, False, Self, 'Varsayılan Satış');
end;

function TStkAmbar.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FAmbarAdi.QryName,
      FIsVarsayilanHammadde.QryName,
      FIsVarsayilanUretim.QryName,
      FIsVarsayilanSatis.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TStkAmbar.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      Id.QryName,
      FAmbarAdi.QryName,
      FIsVarsayilanHammadde.QryName,
      FIsVarsayilanUretim.QryName,
      FIsVarsayilanSatis.QryName
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
  finally
    Free;
  end;
end;

procedure TStkAmbar.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FAmbarAdi.FieldName,
      FIsVarsayilanHammadde.FieldName,
      FIsVarsayilanUretim.FieldName,
      FIsVarsayilanSatis.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TStkAmbar.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FAmbarAdi.FieldName,
      FIsVarsayilanHammadde.FieldName,
      FIsVarsayilanUretim.FieldName,
      FIsVarsayilanSatis.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TStkAmbar.BusinessInsert(APermissionControl: Boolean);
begin
  inherited;
//
end;

procedure TStkAmbar.BusinessUpdate(APermissionControl: Boolean);
begin
  inherited;
//
end;

function TStkAmbar.Clone: TTable;
begin
  Result := TStkAmbar.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



