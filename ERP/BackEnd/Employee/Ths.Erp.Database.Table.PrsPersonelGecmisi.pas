unit Ths.Erp.Database.Table.PrsPersonelGecmisi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.PrsPersonel,
  Ths.Erp.Database.Table.SetPrsLisan,
  Ths.Erp.Database.Table.SetPrsLisanSeviyesi,
  Ths.Erp.Database.Table.SetPrsAyrilmaNedeni;

type
  TPrsPersonelGecmisi = class(TTable)
  private
    FPersonelID: TFieldDB;
    FPersonel: TFieldDB;
    FBaslamaTarihi: TFieldDB;
    FAyrilmaTarihi: TFieldDB;
    FAyrilmaNedeniID: TFieldDB;
    FAyrilmaNedeni: TFieldDB;
    FAciklama: TFieldDB;

    FPrs: TPrsPersonel;
    FSetAyrilma: TSetPrsAyrilmaNedeni;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property PersonelID: TFieldDB read FPersonelID write FPersonelID;
    Property Personel: TFieldDB read FPersonel write FPersonel;
    Property BaslamaTarihi: TFieldDB read FBaslamaTarihi write FBaslamaTarihi;
    Property AyrilmaTarihi: TFieldDB read FAyrilmaTarihi write FAyrilmaTarihi;
    Property AyrilmaNedeniID: TFieldDB read FAyrilmaNedeniID write FAyrilmaNedeniID;
    Property AyrilmaNedeni: TFieldDB read FAyrilmaNedeni write FAyrilmaNedeni;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TPrsPersonelGecmisi.Create(ADatabase: TDatabase);
begin
  TableName := 'prs_personel_gecmisi';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FPrs := TPrsPersonel.Create(Database);
  FSetAyrilma := TSetPrsAyrilmaNedeni.Create(Database);

  FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self, 'Personel Kart ID');
  FPersonel := TFieldDB.Create(FPrs.AdSoyad.FieldName, FPrs.AdSoyad.DataType, FPrs.AdSoyad.Value, Self, 'Personel Adý');
  FBaslamaTarihi := TFieldDB.Create('baslama_tarihi', ftDate, 0, Self, 'Giriþ Tarihi');
  FAyrilmaTarihi := TFieldDB.Create('ayrilma_tarihi', ftDate, 0, Self, 'Çýkýþ Tarihi');
  FAyrilmaNedeniID := TFieldDB.Create('ayrilma_nedeni_id', ftInteger, 0, Self, 'Ayrýlma Nedeni ID');
  FAyrilmaNedeni := TFieldDB.Create(FSetAyrilma.AyrilmaNedeni.FieldName, FSetAyrilma.AyrilmaNedeni.DataType, '', Self, 'Ayrýlma Nedeni');
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self, 'Açýklama');
end;

destructor TPrsPersonelGecmisi.Destroy;
begin
  FreeAndNil(FPrs);
  FreeAndNil(FSetAyrilma);
  inherited;
end;

procedure TPrsPersonelGecmisi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FPersonelID.QryName,
        addField(FPrs.TableName, FPrs.AdSoyad.FieldName, FPersonel.FieldName),
        FBaslamaTarihi.QryName,
        FAyrilmaTarihi.QryName,
        FAyrilmaNedeniID.QryName,
        addField(FSetAyrilma.TableName, FSetAyrilma.AyrilmaNedeni.FieldName, FAyrilmaNedeni.FieldName),
        FAciklama.QryName
      ], [
        addJoin(jtLeft, FPrs.TableName, FPrs.Id.FieldName, TableName, FPersonelID.FieldName),
        addJoin(jtLeft, FSetAyrilma.TableName, FSetAyrilma.Id.FieldName, TableName, FAyrilmaNedeniID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  end;
end;

procedure TPrsPersonelGecmisi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FPersonelID.QryName,
        addField(FPrs.TableName, FPrs.AdSoyad.FieldName, FPersonel.FieldName),
        FBaslamaTarihi.QryName,
        FAyrilmaTarihi.QryName,
        FAyrilmaNedeniID.QryName,
        addField(FSetAyrilma.TableName, FSetAyrilma.AyrilmaNedeni.FieldName, FAyrilmaNedeni.FieldName),
        FAciklama.QryName
      ], [
        addJoin(jtLeft, FPrs.TableName, FPrs.Id.FieldName, TableName, FPersonelID.FieldName),
        addJoin(jtLeft, FSetAyrilma.TableName, FSetAyrilma.Id.FieldName, TableName, FAyrilmaNedeniID.FieldName),
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

procedure TPrsPersonelGecmisi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FPersonelID.FieldName,
        FBaslamaTarihi.FieldName,
        FAyrilmaTarihi.FieldName,
        FAyrilmaNedeniID.FieldName,
        FAciklama.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then AID := Fields.FieldByName(Id.FieldName).AsInteger
      else AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TPrsPersonelGecmisi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FPersonelID.FieldName,
        FBaslamaTarihi.FieldName,
        FAyrilmaTarihi.FieldName,
        FAyrilmaNedeniID.FieldName,
        FAciklama.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TPrsPersonelGecmisi.Clone: TTable;
begin
  Result := TPrsPersonelGecmisi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
