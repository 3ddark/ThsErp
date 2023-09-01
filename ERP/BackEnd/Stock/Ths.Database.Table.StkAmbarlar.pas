unit Ths.Database.Table.StkAmbarlar;

interface

{$I Ths.inc}

uses
  SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TStkAmbar = class(TTable)
  private
    FAmbarAdi: TFieldDB;
    FIsVarsayilanHammadde: TFieldDB;
    FIsVarsayilanUretim: TFieldDB;
    FIsVarsayilanSatis: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
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

  FAmbarAdi := TFieldDB.Create('ambar_adi', ftWideString, '', Self, 'Ambar Adý');
  FIsVarsayilanHammadde := TFieldDB.Create('is_varsayilan_hammadde', ftBoolean, False, Self, 'Varsayýlan Hammadde');
  FIsVarsayilanUretim := TFieldDB.Create('is_varsayilan_uretim', ftBoolean, False, Self, 'Varsayýlan Üretim');
  FIsVarsayilanSatis := TFieldDB.Create('is_varsayilan_satis', ftBoolean, False, Self, 'Varsayýlan Satýþ');
end;

procedure TStkAmbar.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FAmbarAdi.QryName,
      FIsVarsayilanHammadde.QryName,
      FIsVarsayilanUretim.QryName,
      FIsVarsayilanSatis.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TStkAmbar.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FAmbarAdi.FieldName,
      FIsVarsayilanHammadde.FieldName,
      FIsVarsayilanUretim.FieldName,
      FIsVarsayilanSatis.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TStkAmbar.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FAmbarAdi.FieldName,
      FIsVarsayilanHammadde.FieldName,
      FIsVarsayilanUretim.FieldName,
      FIsVarsayilanSatis.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TStkAmbar.Clone: TTable;
begin
  Result := TStkAmbar.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



