unit Ths.Erp.Database.Table.PrsLisanBilgisi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetPrsLisan,
  Ths.Erp.Database.Table.SetPrsLisanSeviyesi,
  Ths.Erp.Database.Table.PrsPersonel;

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
    FSetLisan: TSetPrsLisan;
    FSetLisanSeviye: TSetPrsLisanSeviyesi;
    FPers: TPrsPersonel;

    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

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
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TPrsLisanBilgisi.Create(ADatabase: TDatabase);
begin
  TableName := 'prs_lisan_bilgisi';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FSetLisan := TSetPrsLisan.Create(Database);
  FSetLisanSeviye := TSetPrsLisanSeviyesi.Create(Database);
  FPers := TPrsPersonel.Create(Database);

  FLisanID := TFieldDB.Create('lisan_id', ftInteger, 0, Self, 'Lisan ID');
  FLisan := TFieldDB.Create(FSetLisan.Lisan.FieldName, FSetLisan.Lisan.DataType, '', Self, 'Lisan');
  FOkumaID := TFieldDB.Create('okuma_id', ftInteger, 0, Self, 'Okuma Seviyesi ID');
  FOkuma := TFieldDB.Create(FSetLisanSeviye.LisanSeviyesi.FieldName, FSetLisanSeviye.LisanSeviyesi.DataType, '', Self, 'Okuma Seviyesi', FSetLisanSeviye.LisanSeviyesi.FieldName + '_read', 0, True);
  FYazmaID := TFieldDB.Create('yazma_id', ftInteger, 0, Self, 'Yazma Seviyesi ID');
  FYazma := TFieldDB.Create(FSetLisanSeviye.LisanSeviyesi.FieldName, FSetLisanSeviye.LisanSeviyesi.DataType, '', Self, 'Yazma Seviyesi', FSetLisanSeviye.LisanSeviyesi.FieldName + '_write', 0, True);
  FKonusmaID := TFieldDB.Create('konusma_id', ftInteger, 0, Self, 'Konuþma Seviyesi ID');
  FKonusma := TFieldDB.Create(FSetLisanSeviye.LisanSeviyesi.FieldName, FSetLisanSeviye.LisanSeviyesi.DataType, '', Self, 'Konuþma Seviyesi', FSetLisanSeviye.LisanSeviyesi.FieldName + '_speak', 0, True);
  FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self, 'Personel Kart ID');
  FPersonel := TFieldDB.Create(FPers.AdSoyad.FieldName, FPers.AdSoyad.DataType, '', Self, 'Personel Adý');
end;

destructor TPrsLisanBilgisi.Destroy;
begin
  FreeAndNil(FSetLisan);
  FreeAndNil(FSetLisanSeviye);
  FreeAndNil(FPers);
  inherited;
end;

procedure TPrsLisanBilgisi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FLisanID.QryName,
        addField(FSetLisan.TableName, FSetLisan.Lisan.FieldName, FLisan.FieldName),
        FOkumaID.QryName,
        addField(FSetLisanSeviye.TableName, FSetLisanSeviye.LisanSeviyesi.FieldName, FOkuma.FieldName, 'ok'),
        FYazmaID.QryName,
        addField(FSetLisanSeviye.TableName, FSetLisanSeviye.LisanSeviyesi.FieldName, FYazma.FieldName, 'ya'),
        FKonusmaID.QryName,
        addField(FSetLisanSeviye.TableName, FSetLisanSeviye.LisanSeviyesi.FieldName, FYazma.FieldName, 'ko'),
        FPersonelID.QryName,
        addField(FPers.TableName, FPers.AdSoyad.FieldName, FPersonel.FieldName)
      ], [
        addJoin(jtLeft, FLisan.FieldName, FLisanID.FieldName, FSetLisan.TableName, FLisanID.FieldName),
        addJoin(jtLeft, FSetLisanSeviye.TableName, FSetLisanSeviye.Id.FieldName, TableName, FOkumaID.FieldName, 'ok'),
        addJoin(jtLeft, FSetLisanSeviye.TableName, FSetLisanSeviye.Id.FieldName, TableName, FYazmaID.FieldName, 'ya'),
        addJoin(jtLeft, FSetLisanSeviye.TableName, FSetLisanSeviye.Id.FieldName, TableName, FKonusmaID.FieldName, 'ko'),
        addJoin(jtLeft, FPers.TableName, FPers.Id.FieldName, TableName, FPersonelID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TPrsLisanBilgisi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Id.QryName,
        FLisanID.QryName,
        addField(FSetLisan.TableName, FSetLisan.Lisan.FieldName, FLisan.FieldName),
        FOkumaID.QryName,
        addField(FSetLisanSeviye.TableName, FSetLisanSeviye.LisanSeviyesi.FieldName, FOkuma.FieldName, 'ok'),
        FYazmaID.QryName,
        addField(FSetLisanSeviye.TableName, FSetLisanSeviye.LisanSeviyesi.FieldName, FYazma.FieldName, 'ya'),
        FKonusmaID.QryName,
        addField(FSetLisanSeviye.TableName, FSetLisanSeviye.LisanSeviyesi.FieldName, FYazma.FieldName, 'ko'),
        FPersonelID.QryName,
        addField(FPers.TableName, FPers.AdSoyad.FieldName, FPersonel.FieldName)
      ], [
        addJoin(jtLeft, FLisan.FieldName, FLisanID.FieldName, FSetLisan.TableName, FLisanID.FieldName),
        addJoin(jtLeft, FSetLisanSeviye.TableName, FSetLisanSeviye.Id.FieldName, TableName, FOkumaID.FieldName, 'ok'),
        addJoin(jtLeft, FSetLisanSeviye.TableName, FSetLisanSeviye.Id.FieldName, TableName, FYazmaID.FieldName, 'ya'),
        addJoin(jtLeft, FSetLisanSeviye.TableName, FSetLisanSeviye.Id.FieldName, TableName, FKonusmaID.FieldName, 'ko'),
        addJoin(jtLeft, FPers.TableName, FPers.Id.FieldName, TableName, FPersonelID.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TPrsLisanBilgisi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FLisanID.FieldName,
        FOkumaID.FieldName,
        FYazmaID.FieldName,
        FKonusmaID.FieldName,
        FPersonelID.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TPrsLisanBilgisi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FLisanID.FieldName,
        FOkumaID.FieldName,
        FYazmaID.FieldName,
        FKonusmaID.FieldName,
        FPersonelID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TPrsLisanBilgisi.Clone: TTable;
begin
  Result := TPrsLisanBilgisi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
