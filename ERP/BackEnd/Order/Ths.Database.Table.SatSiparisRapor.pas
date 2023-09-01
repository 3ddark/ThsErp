unit Ths.Database.Table.SatSiparisRapor;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.View,
  Ths.Database.Table.SatSiparis,
  Ths.Database.Table.SeTSatSiparisDurum,
  Ths.Database.Table.SysSehirler;

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
  Ths.Globals,
  Ths.Constants;

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
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
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
  end;
end;

procedure TSatSiparisRapor.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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

function TSatSiparisRapor.Clone: TTable;
begin
  Result := TSatSiparisRapor.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
