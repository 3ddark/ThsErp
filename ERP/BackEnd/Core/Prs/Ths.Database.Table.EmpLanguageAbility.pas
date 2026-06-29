unit Ths.Database.Table.EmpLanguageAbility;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.EmpLisan,
  Ths.Database.Table.EmpLanguageLevel,
  Ths.Database.Table.EmpPersonnel;

type
  TEmpLanguageAbility = class(TTable)
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
    FEmpLisan: TEmpLisan;
    FEmpLanguageLevel: TEmpLanguageLevel;
    FEmpPersonnel: TEmpPersonnel;

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

constructor TEmpLanguageAbility.Create(ADatabase: TDatabase);
begin
  TableName := 'emp_person_language_ability';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FEmpLisan := TEmpLisan.Create(Database);
  FEmpLanguageLevel := TEmpLanguageLevel.Create(Database);
  FEmpPersonnel := TEmpPersonnel.Create(Database);

  FLisanID := TFieldDB.Create('lisan_id', ftInteger, 0, Self);
  FLisan := TFieldDB.Create(FEmpLisan.Lisan.FieldName, FEmpLisan.Lisan.DataType, '', Self);
  FOkumaID := TFieldDB.Create('okuma_id', ftInteger, 0, Self);
  FOkuma := TFieldDB.Create('okuma', FEmpLanguageLevel.LisanSeviyesi.DataType, '', Self, FEmpLanguageLevel.LisanSeviyesi.FieldName + '_read', 0, True);
  FYazmaID := TFieldDB.Create('yazma_id', ftInteger, 0, Self);
  FYazma := TFieldDB.Create('yazma', FEmpLanguageLevel.LisanSeviyesi.DataType, '', Self, FEmpLanguageLevel.LisanSeviyesi.FieldName + '_write', 0, True);
  FKonusmaID := TFieldDB.Create('konusma_id', ftInteger, 0, Self);
  FKonusma := TFieldDB.Create('konusma', FEmpLanguageLevel.LisanSeviyesi.DataType, '', Self, FEmpLanguageLevel.LisanSeviyesi.FieldName + '_speak', 0, True);
  FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self);
  FPersonel := TFieldDB.Create(FEmpPersonnel.AdSoyad.FieldName, FEmpPersonnel.AdSoyad.DataType, FEmpPersonnel.AdSoyad.Value, Self);
end;

destructor TEmpLanguageAbility.Destroy;
begin
  FreeAndNil(FEmpLisan);
  FreeAndNil(FEmpLanguageLevel);
  FreeAndNil(FEmpPersonnel);
  inherited;
end;

function TEmpLanguageAbility.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
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
      addField(FEmpLisan.TableName, FEmpLisan.Lisan.FieldName, FLisan.FieldName),
      FOkumaID.QryName,
      addField(FEmpLanguageLevel.TableName, FEmpLanguageLevel.LisanSeviyesi.FieldName, FOkuma.FieldName, 'ok'),
      FYazmaID.QryName,
      addField(FEmpLanguageLevel.TableName, FEmpLanguageLevel.LisanSeviyesi.FieldName, FYazma.FieldName, 'ya'),
      FKonusmaID.QryName,
      addField(FEmpLanguageLevel.TableName, FEmpLanguageLevel.LisanSeviyesi.FieldName, FKonusma.FieldName, 'ko'),
      FPersonelID.QryName,
      addField(FEmpPersonnel.TableName, FEmpPersonnel.AdSoyad.FieldName, FPersonel.FieldName)
    ], [
      addJoin(jtLeft, FEmpLisan.TableName, FEmpLisan.Id.FieldName, TableName, FLisanID.FieldName),
      addJoin(jtLeft, FEmpLanguageLevel.TableName, FEmpLanguageLevel.Id.FieldName, TableName, FOkumaID.FieldName, 'ok'),
      addJoin(jtLeft, FEmpLanguageLevel.TableName, FEmpLanguageLevel.Id.FieldName, TableName, FYazmaID.FieldName, 'ya'),
      addJoin(jtLeft, FEmpLanguageLevel.TableName, FEmpLanguageLevel.Id.FieldName, TableName, FKonusmaID.FieldName, 'ko'),
      addJoin(jtLeft, FEmpPersonnel.TableName, FEmpPersonnel.Id.FieldName, TableName, FPersonelID.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TEmpLanguageAbility.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      addField(FEmpLisan.TableName, FEmpLisan.Lisan.FieldName, FLisan.FieldName),
      FOkumaID.QryName,
      addField(FEmpLanguageLevel.TableName, FEmpLanguageLevel.LisanSeviyesi.FieldName, FOkuma.FieldName, 'ok'),
      FYazmaID.QryName,
      addField(FEmpLanguageLevel.TableName, FEmpLanguageLevel.LisanSeviyesi.FieldName, FYazma.FieldName, 'ya'),
      FKonusmaID.QryName,
      addField(FEmpLanguageLevel.TableName, FEmpLanguageLevel.LisanSeviyesi.FieldName, FKonusma.FieldName, 'ko'),
      FPersonelID.QryName,
      addField(FEmpPersonnel.TableName, FEmpPersonnel.AdSoyad.FieldName, FPersonel.FieldName)
    ], [
      addJoin(jtLeft, FEmpLisan.TableName, FEmpLisan.Id.FieldName, TableName, FLisanID.FieldName),
      addJoin(jtLeft, FEmpLanguageLevel.TableName, FEmpLanguageLevel.Id.FieldName, TableName, FOkumaID.FieldName, 'ok'),
      addJoin(jtLeft, FEmpLanguageLevel.TableName, FEmpLanguageLevel.Id.FieldName, TableName, FYazmaID.FieldName, 'ya'),
      addJoin(jtLeft, FEmpLanguageLevel.TableName, FEmpLanguageLevel.Id.FieldName, TableName, FKonusmaID.FieldName, 'ko'),
      addJoin(jtLeft, FEmpPersonnel.TableName, FEmpPersonnel.Id.FieldName, TableName, FPersonelID.FieldName),
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

procedure TEmpLanguageAbility.DoInsert(APermissionControl: Boolean);
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

procedure TEmpLanguageAbility.DoUpdate(APermissionControl: Boolean);
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

function TEmpLanguageAbility.Clone: TTable;
begin
  Result := TEmpLanguageAbility.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



