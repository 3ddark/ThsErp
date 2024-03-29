unit Ths.Database.Table.StkResimler;

interface

{$I Ths.inc}

uses
  System.Variants,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table;

type
  TStkResim = class(TTable)
  private
    FStkKartID: TFieldDB;
    FResim: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;
    destructor Destroy; override;

    Property StkKartID: TFieldDB read FStkKartID write FStkKartID;
    Property Resim: TFieldDB read FResim write FResim;
  end;

implementation

uses
  Ths.Globals, Ths.Constants;

constructor TStkResim.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_resimler';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FStkKartID := TFieldDB.Create('stk_kart_id', ftInteger, 0, Self, 'Stok Kart� ID');
  FResim := TFieldDB.Create('resim', ftBytes, '', Self, 'Resim');
end;

destructor TStkResim.Destroy;
begin
  inherited;
end;

procedure TStkResim.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FStkKartID.QryName,
      FResim.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TStkResim.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FStkKartID.QryName,
      FResim.QryName
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

procedure TStkResim.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FStkKartID.FieldName,
      FResim.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TStkResim.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FStkKartID.FieldName,
      FResim.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TStkResim.Clone: TTable;
begin
  Result := TStkResim.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
