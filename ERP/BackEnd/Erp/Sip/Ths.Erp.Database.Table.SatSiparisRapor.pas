unit Ths.Erp.Database.Table.SatSiparisRapor;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.View,
  Ths.Erp.Database.Table.SatSiparis,
  Ths.Erp.Database.Table.SeTSatSiparisDurum,
  Ths.Erp.Database.Table.SysSehir;

type
  TSatSiparisRapor = class(TView)
  private
    FMusteriAdi: TFieldDB;
    FCity: TFieldDB;
    FStokGrubu: TFieldDB;
    FStokKodu: TFieldDB;
    FStokAciklama: TFieldDB;
    FMiktar: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FSiparisNo: TFieldDB;
    FSiparisTarihi: TFieldDB;
    FTeslimTarihi: TFieldDB;
    FSiparisDurum: TFieldDB;
    FAciklama: TFieldDB;
    FReferans: TFieldDB;
    FReferansSatir: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property MusteriAdi: TFieldDB read FMusteriAdi write FMusteriAdi;
    Property City: TFieldDB read FCity write FCity;
    Property StokGrubu: TFieldDB read FStokGrubu write FStokGrubu;
    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property StokAciklama: TFieldDB read FStokAciklama write FStokAciklama;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property SiparisNo: TFieldDB read FSiparisNo write FSiparisNo;
    Property SiparisTarihi: TFieldDB read FSiparisTarihi write FSiparisTarihi;
    Property TeslimTarihi: TFieldDB read FTeslimTarihi write FTeslimTarihi;
    Property SiparisDurum: TFieldDB read FSiparisDurum write FSiparisDurum;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property Referans: TFieldDB read FReferans write FReferans;
    Property ReferansSatir: TFieldDB read FReferansSatir write FReferansSatir;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSatSiparisRapor.Create(ADatabase: TDatabase);
begin
  TableName := 'sat_siparis_rapor';
  TableSourceCode := MODULE_SAT_SIP_RAPOR;
  inherited Create(ADatabase);

  FMusteriAdi := TFieldDB.Create('musteri_adi', ftString, '', Self, '');
  FCity := TFieldDB.Create('city', ftString, '', Self, '');
  FStokGrubu := TFieldDB.Create('stok_grubu', ftString, '', Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, '');
  FStokAciklama := TFieldDB.Create('stok_aciklama', ftString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FOlcuBirimi := TFieldDB.Create('olcu_birimi', ftString, '', Self, '');
  FSiparisNo := TFieldDB.Create('siparis_no', ftString, '', Self, '');
  FSiparisTarihi := TFieldDB.Create('siparis_tarihi', ftDate, 0, Self, '');
  FTeslimTarihi := TFieldDB.Create('teslim_tarihi', ftDate, 0, Self, '');
  FSiparisDurum := TFieldDB.Create('siparis_durum', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FReferans := TFieldDB.Create('referans', ftString, '', Self, '');
  FReferansSatir := TFieldDB.Create('referans_satir', ftString, '', Self, '');
end;

procedure TSatSiparisRapor.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FMusteriAdi.FieldName,
        TableName + '.' + FCity.FieldName,
        TableName + '.' + FStokGrubu.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FStokAciklama.FieldName,
        TableName + '.' + FMiktar.FieldName,
        TableName + '.' + FOlcuBirimi.FieldName,
        TableName + '.' + FSiparisNo.FieldName,
        TableName + '.' + FSiparisTarihi.FieldName,
        TableName + '.' + FTeslimTarihi.FieldName,
        TableName + '.' + FSiparisDurum.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FReferans.FieldName,
        TableName + '.' + FReferansSatir.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FMusteriAdi, 'Müþteri Adý', QueryOfDS);
      setFieldTitle(FCity, 'Þehir', QueryOfDS);
      setFieldTitle(FStokGrubu, 'Stok Grubu', QueryOfDS);
      setFieldTitle(FStokKodu, 'Stok Kodu', QueryOfDS);
      setFieldTitle(FStokAciklama, 'Stok Açýklama', QueryOfDS);
      setFieldTitle(FMiktar, 'Miktar', QueryOfDS);
      setFieldTitle(FOlcuBirimi, 'Ölçü Birimi', QueryOfDS);
      setFieldTitle(FSiparisNo, 'Sipariþ No', QueryOfDS);
      setFieldTitle(FSiparisTarihi, 'Sipariþ Tarihi', QueryOfDS);
      setFieldTitle(FTeslimTarihi, 'Teslim Tarihi', QueryOfDS);
      setFieldTitle(FSiparisDurum, 'Durum', QueryOfDS);
      setFieldTitle(FAciklama, 'Açýklama', QueryOfDS);
      setFieldTitle(FReferans, 'Referans', QueryOfDS);
      setFieldTitle(FReferansSatir, 'Referans Satýr', QueryOfDS);
    end;
  end;
end;

procedure TSatSiparisRapor.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FMusteriAdi.FieldName,
        TableName + '.' + FCity.FieldName,
        TableName + '.' + FStokGrubu.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FStokAciklama.FieldName,
        TableName + '.' + FMiktar.FieldName,
        TableName + '.' + FOlcuBirimi.FieldName,
        TableName + '.' + FSiparisNo.FieldName,
        TableName + '.' + FSiparisTarihi.FieldName,
        TableName + '.' + FTeslimTarihi.FieldName,
        TableName + '.' + FSiparisDurum.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FReferans.FieldName,
        TableName + '.' + FReferansSatir.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

function TSatSiparisRapor.Clone: TTable;
begin
  Result := TSatSiparisRapor.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
