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
    FMusteriKodu: TFieldDB;
    FMusteriAdi: TFieldDB;
    FSehirAdi: TFieldDB;
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

    Property MusteriKodu: TFieldDB read FMusteriKodu write FMusteriKodu;
    Property MusteriAdi: TFieldDB read FMusteriAdi write FMusteriAdi;
    Property SehirAdi: TFieldDB read FSehirAdi write FSehirAdi;
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

  FMusteriKodu := TFieldDB.Create('musteri_kodu', ftString, '', Self, 'Müþteri Kodu');
  FMusteriAdi := TFieldDB.Create('musteri_adi', ftString, '', Self, 'Müþteri Adý');
  FSehirAdi := TFieldDB.Create('sehir_adi', ftString, '', Self, 'Þehir');
  FStokGrubu := TFieldDB.Create('stok_grubu', ftString, '', Self, 'Stok Grubu');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, 'Stok Kodu');
  FStokAciklama := TFieldDB.Create('stok_aciklama', ftString, '', Self, 'Stok Açýklama');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, 'Miktar');
  FOlcuBirimi := TFieldDB.Create('olcu_birimi', ftString, '', Self, 'Ölçü Birimi');
  FSiparisNo := TFieldDB.Create('siparis_no', ftString, '', Self, 'Sipariþ No');
  FSiparisTarihi := TFieldDB.Create('siparis_tarihi', ftDate, 0, Self, 'Sipariþ Tarihi');
  FTeslimTarihi := TFieldDB.Create('teslim_tarihi', ftDate, 0, Self, 'Teslim Tarihi');
  FSiparisDurum := TFieldDB.Create('siparis_durum', ftString, '', Self, 'Sipariþ Durum');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'Açýklama');
  FReferans := TFieldDB.Create('referans', ftString, '', Self, 'Referans');
  FReferansSatir := TFieldDB.Create('referans_satir', ftString, '', Self, 'Satýr Referans');
end;

procedure TSatSiparisRapor.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Self.Id.QryName,
        FMusteriKodu.QryName,
        FMusteriAdi.QryName,
        FSehirAdi.QryName,
        FStokGrubu.QryName,
        FStokKodu.QryName,
        FStokAciklama.QryName,
        FMiktar.QryName,
        FOlcuBirimi.QryName,
        FSiparisNo.QryName,
        FSiparisTarihi.QryName,
        FTeslimTarihi.QryName,
        FSiparisDurum.QryName,
        FAciklama.QryName,
        FReferans.QryName,
        FReferansSatir.QryName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;
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
        Self.Id.QryName,
        FMusteriKodu.QryName,
        FMusteriAdi.QryName,
        FSehirAdi.QryName,
        FStokGrubu.QryName,
        FStokKodu.QryName,
        FStokAciklama.QryName,
        FMiktar.QryName,
        FOlcuBirimi.QryName,
        FSiparisNo.QryName,
        FSiparisTarihi.QryName,
        FTeslimTarihi.QryName,
        FSiparisDurum.QryName,
        FAciklama.QryName,
        FReferans.QryName,
        FReferansSatir.QryName
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
