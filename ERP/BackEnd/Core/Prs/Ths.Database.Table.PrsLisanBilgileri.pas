unit Ths.Database.Table.PrsLisanBilgileri;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetPrsLisanlar,
  Ths.Database.Table.SetPrsLisanSeviyeleri,
  Ths.Database.Table.PrsPersoneller;

type
  TPrsLisanBilgisi = class(TTable)
  private
    FLisanID: TFieldDB;
    FLisan: TFieldDB;
    FOkumaID: TFieldDB;
    FOkuma: TFieldDB;
    FYazmaID: TFieldDB;
    FYazma: TFieldDB;
    FKonusmaID: TFieldDB;
    FKonusma: TFieldDB;
    FPersonelID: TFieldDB;
    FPersonel: TFieldDB;
  published
    FSetPrsLisan: TSetPrsLisan;
    FSetPrsLisanSeviyesi: TSetPrsLisanSeviyesi;
    FEmpEmployee: TPrsPersonel;

    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property LisanID: TFieldDB read FLisanID write FLisanID;
    Property Lisan: TFieldDB read FLisan write FLisan;
    Property OkumaID: TFieldDB read FOkumaID write FOkumaID;
    Property Okuma: TFieldDB read FOkuma write FOkuma;
    Property YazmaID: TFieldDB read FYazmaID write FYazmaID;
    Property Yazma: TFieldDB read FYazma write FYazma;
    Property KonusmaID: TFieldDB read FKonusmaID write FKonusmaID;
    Property Konusma: TFieldDB read FKonusma write FKonusma;
    Property PersonelID: TFieldDB read FPersonelID write FPersonelID;
    Property Personel: TFieldDB read FPersonel write FPersonel;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TPrsLisanBilgisi.Create(ADatabase: TDatabase);
begin
  TableName := 'prs_lisan_bilgileri';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FSetPrsLisan := TSetPrsLisan.Create(Database);
  FSetPrsLisanSeviyesi := TSetPrsLisanSeviyesi.Create(Database);
  FEmpEmployee := TPrsPersonel.Create(Database);

  FLisanID := TFieldDB.Create('lisan_id', ftInteger, 0, Self);
  FLisan := TFieldDB.Create(FSetPrsLisan.Lisan.FieldName, FSetPrsLisan.Lisan.DataType, '', Self);
  FOkumaID := TFieldDB.Create('okuma_id', ftInteger, 0, Self);
  FOkuma := TFieldDB.Create('okuma', FSetPrsLisanSeviyesi.LisanSeviyesi.DataType, '', Self, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName + '_read', 0, True);
  FYazmaID := TFieldDB.Create('yazma_id', ftInteger, 0, Self);
  FYazma := TFieldDB.Create('yazma', FSetPrsLisanSeviyesi.LisanSeviyesi.DataType, '', Self, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName + '_write', 0, True);
  FKonusmaID := TFieldDB.Create('konusma_id', ftInteger, 0, Self);
  FKonusma := TFieldDB.Create('konusma', FSetPrsLisanSeviyesi.LisanSeviyesi.DataType, '', Self, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName + '_speak', 0, True);
  FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self);
  FPersonel := TFieldDB.Create(FEmpEmployee.AdSoyad.FieldName, FEmpEmployee.AdSoyad.DataType, FEmpEmployee.AdSoyad.Value, Self);
end;

destructor TPrsLisanBilgisi.Destroy;
begin
  FreeAndNil(FSetPrsLisan);
  FreeAndNil(FSetPrsLisanSeviyesi);
  FreeAndNil(FEmpEmployee);
  inherited;
end;

function TPrsLisanBilgisi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FLisanID.QryName,
      addField(FSetPrsLisan.TableName, FSetPrsLisan.Lisan.FieldName, FLisan.FieldName),
      FOkumaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FOkuma.FieldName, 'ok'),
      FYazmaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FYazma.FieldName, 'ya'),
      FKonusmaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FKonusma.FieldName, 'ko'),
      FPersonelID.QryName,
      addField(FEmpEmployee.TableName, FEmpEmployee.AdSoyad.FieldName, FPersonel.FieldName)
    ], [
      addJoin(jtLeft, FSetPrsLisan.TableName, FSetPrsLisan.Id.FieldName, TableName, FLisanID.FieldName),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FOkumaID.FieldName, 'ok'),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FYazmaID.FieldName, 'ya'),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FKonusmaID.FieldName, 'ko'),
      addJoin(jtLeft, FEmpEmployee.TableName, FEmpEmployee.Id.FieldName, TableName, FPersonelID.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TPrsLisanBilgisi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FLisanID.QryName,
      addField(FSetPrsLisan.TableName, FSetPrsLisan.Lisan.FieldName, FLisan.FieldName),
      FOkumaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FOkuma.FieldName, 'ok'),
      FYazmaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FYazma.FieldName, 'ya'),
      FKonusmaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FKonusma.FieldName, 'ko'),
      FPersonelID.QryName,
      addField(FEmpEmployee.TableName, FEmpEmployee.AdSoyad.FieldName, FPersonel.FieldName)
    ], [
      addJoin(jtLeft, FSetPrsLisan.TableName, FSetPrsLisan.Id.FieldName, TableName, FLisanID.FieldName),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FOkumaID.FieldName, 'ok'),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FYazmaID.FieldName, 'ya'),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FKonusmaID.FieldName, 'ko'),
      addJoin(jtLeft, FEmpEmployee.TableName, FEmpEmployee.Id.FieldName, TableName, FPersonelID.FieldName),
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

procedure TPrsLisanBilgisi.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FLisanID.FieldName,
      FOkumaID.FieldName,
      FYazmaID.FieldName,
      FKonusmaID.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TPrsLisanBilgisi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FLisanID.FieldName,
      FOkumaID.FieldName,
      FYazmaID.FieldName,
      FKonusmaID.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TPrsLisanBilgisi.Clone: TTable;
begin
  Result := TPrsLisanBilgisi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
