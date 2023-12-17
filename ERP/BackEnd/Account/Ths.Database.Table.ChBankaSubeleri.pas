unit Ths.Database.Table.ChBankaSubeleri;

interface

{$I Ths.inc}

uses
  SysUtils,
  System.Variants,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.ChBankalar,
  Ths.Database.Table.SysSehirler;

type
  TChBankaSubesi = class(TTable)
  private
    FBankaID: TFieldDB;
    FBanka: TFieldDB;
    FSubeKodu: TFieldDB;
    FSubeAdi: TFieldDB;
    FSehirID: TFieldDB;
    FSehir: TFieldDB;
  protected
    FChBanka: TChBanka;
    FSysSehir: TSysSehir;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property BankaID: TFieldDB read FBankaID write FBankaID;
    Property Banka: TFieldDB read FBanka write FBanka;
    Property SubeKodu: TFieldDB read FSubeKodu write FSubeKodu;
    Property SubeAdi: TFieldDB read FSubeAdi write FSubeAdi;
    Property SehirID: TFieldDB read FSehirID write FSehirID;
    Property Sehir: TFieldDB read FSehir write FSehir;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TChBankaSubesi.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_banka_subeleri';
  TableSourceCode := MODULE_CH_KAYIT;
  inherited Create(ADatabase);

  FChBanka := TChBanka.Create(ADatabase);
  FSysSehir := TSysSehir.Create(ADatabase);

  FBankaID := TFieldDB.Create('banka_id', ftInteger, 0, Self, 'Banka ID');
  FBanka := TFieldDB.Create(FChBanka.BankaAdi.FieldName, FChBanka.BankaAdi.DataType, '', Self, 'Banka');
  FSubeKodu := TFieldDB.Create('sube_kodu', ftInteger, 0, Self, 'Þube Kodu');
  FSubeAdi := TFieldDB.Create('sube_adi', ftString, '', Self, 'Þube Adý');
  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self, 'Þehir ID');
  FSehir := TFieldDB.Create(FSysSehir.Sehir.FieldName, FSysSehir.Sehir.DataType, FSysSehir.Sehir.Value, Self, FSysSehir.Sehir.Title);
end;

destructor TChBankaSubesi.Destroy;
begin
  FreeAndNil(FChBanka);
  FreeAndNil(FSysSehir);
  inherited;
end;

procedure TChBankaSubesi.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FBankaID.QryName,
      addLangField(FBanka.FieldName),
      FSubeKodu.QryName,
      FSubeAdi.QryName,
      FSehirID.QryName,
      addLangField(FSehir.FieldName)
    ], [
      addLeftJoin(FBanka.FieldName, FBankaID.FieldName, FChBanka.TableName),
      addLeftJoin(FSehir.FieldName, FSehirID.FieldName, FSysSehir.TableName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TChBankaSubesi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FBankaID.QryName,
      addLangField(FBanka.FieldName),
      FSubeKodu.QryName,
      FSubeAdi.QryName,
      FSehirID.QryName,
      addLangField(FSehir.FieldName)
    ], [
      addLeftJoin(FBanka.FieldName, FBankaID.FieldName, FChBanka.TableName),
      addLeftJoin(FSehir.FieldName, FSehirID.FieldName, FSysSehir.TableName),
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

procedure TChBankaSubesi.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FBankaID.FieldName,
      FSubeKodu.FieldName,
      FSubeAdi.FieldName,
      FSehirID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TChBankaSubesi.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FBankaID.FieldName,
      FSubeKodu.FieldName,
      FSubeAdi.FieldName,
      FSehirID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TChBankaSubesi.Clone: TTable;
begin
  Result := TChBankaSubesi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
