unit Ths.Database.Table.PrsLisanBilgileri;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetPrsLisanlar,
  Ths.Database.Table.SetPrsLisanSeviyeleri,
  Ths.Database.Table.EmpEmployee;

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
    FEmpEmployee: TEmpEmployee;

    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
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
  FEmpEmployee := TEmpEmployee.Create(Database);

  FLisanID := TFieldDB.Create('lisan_id', ftInteger, 0, Self, 'Lisan ID');
  FLisan := TFieldDB.Create(FSetPrsLisan.Lisan.FieldName, FSetPrsLisan.Lisan.DataType, '', Self, 'Lisan');
  FOkumaID := TFieldDB.Create('okuma_id', ftInteger, 0, Self, 'Okuma Seviyesi ID');
  FOkuma := TFieldDB.Create(FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FSetPrsLisanSeviyesi.LisanSeviyesi.DataType, '', Self, 'Okuma Seviyesi', FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName + '_read', 0, True);
  FYazmaID := TFieldDB.Create('yazma_id', ftInteger, 0, Self, 'Yazma Seviyesi ID');
  FYazma := TFieldDB.Create(FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FSetPrsLisanSeviyesi.LisanSeviyesi.DataType, '', Self, 'Yazma Seviyesi', FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName + '_write', 0, True);
  FKonusmaID := TFieldDB.Create('konusma_id', ftInteger, 0, Self, 'Konuþma Seviyesi ID');
  FKonusma := TFieldDB.Create(FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FSetPrsLisanSeviyesi.LisanSeviyesi.DataType, '', Self, 'Konuþma Seviyesi', FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName + '_speak', 0, True);
  FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self, 'Personel Kart ID');
  FPersonel := TFieldDB.Create(FEmpEmployee.AdSoyad.FieldName, FEmpEmployee.AdSoyad.DataType, FEmpEmployee.AdSoyad.Value, Self, FEmpEmployee.AdSoyad.Title);
end;

destructor TPrsLisanBilgisi.Destroy;
begin
  FreeAndNil(FSetPrsLisan);
  FreeAndNil(FSetPrsLisanSeviyesi);
  FreeAndNil(FEmpEmployee);
  inherited;
end;

procedure TPrsLisanBilgisi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FLisanID.QryName,
      addField(FSetPrsLisan.TableName, FSetPrsLisan.Lisan.FieldName, FLisan.FieldName),
      FOkumaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FOkuma.FieldName, 'ok'),
      FYazmaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FYazma.FieldName, 'ya'),
      FKonusmaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FYazma.FieldName, 'ko'),
      FPersonelID.QryName,
      addField(FEmpEmployee.TableName, FEmpEmployee.AdSoyad.FieldName, FPersonel.FieldName)
    ], [
      addJoin(jtLeft, FLisan.FieldName, FLisanID.FieldName, FSetPrsLisan.TableName, FLisanID.FieldName),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FOkumaID.FieldName, 'ok'),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FYazmaID.FieldName, 'ya'),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FKonusmaID.FieldName, 'ko'),
      addJoin(jtLeft, FEmpEmployee.TableName, FEmpEmployee.Id.FieldName, TableName, FPersonelID.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TPrsLisanBilgisi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FLisanID.QryName,
      addField(FSetPrsLisan.TableName, FSetPrsLisan.Lisan.FieldName, FLisan.FieldName),
      FOkumaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FOkuma.FieldName, 'ok'),
      FYazmaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FYazma.FieldName, 'ya'),
      FKonusmaID.QryName,
      addField(FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.LisanSeviyesi.FieldName, FYazma.FieldName, 'ko'),
      FPersonelID.QryName,
      addField(FEmpEmployee.TableName, FEmpEmployee.AdSoyad.FieldName, FPersonel.FieldName)
    ], [
      addJoin(jtLeft, FLisan.FieldName, FLisanID.FieldName, FSetPrsLisan.TableName, FLisanID.FieldName),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FOkumaID.FieldName, 'ok'),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FYazmaID.FieldName, 'ya'),
      addJoin(jtLeft, FSetPrsLisanSeviyesi.TableName, FSetPrsLisanSeviyesi.Id.FieldName, TableName, FKonusmaID.FieldName, 'ko'),
      addJoin(jtLeft, FEmpEmployee.TableName, FEmpEmployee.Id.FieldName, TableName, FPersonelID.FieldName),
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

procedure TPrsLisanBilgisi.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FLisanID.FieldName,
      FOkumaID.FieldName,
      FYazmaID.FieldName,
      FKonusmaID.FieldName,
      FPersonelID.FieldName
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

procedure TPrsLisanBilgisi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FLisanID.FieldName,
      FOkumaID.FieldName,
      FYazmaID.FieldName,
      FKonusmaID.FieldName,
      FPersonelID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TPrsLisanBilgisi.Clone: TTable;
begin
  Result := TPrsLisanBilgisi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
