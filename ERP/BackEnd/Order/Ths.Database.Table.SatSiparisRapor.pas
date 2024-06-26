unit Ths.Database.Table.SatSiparisRapor;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
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
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
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

  FMusteriKodu := TFieldDB.Create('musteri_kodu', ftString, '', Self, 'Müşteri Kodu');
  FMusteriAdi := TFieldDB.Create('musteri_adi', ftString, '', Self, 'Müşteri Adı');
  FSehirAdi := TFieldDB.Create('sehir_adi', ftString, '', Self, 'Şehir');
  FStokGrubu := TFieldDB.Create('stok_grubu', ftString, '', Self, 'Stok Grubu');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, 'Stok Kodu');
  FStokAciklama := TFieldDB.Create('stok_aciklama', ftString, '', Self, 'Stok Açıklama');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, 'Miktar');
  FOlcuBirimi := TFieldDB.Create('olcu_birimi', ftString, '', Self, 'Ölçü Birimi');
  FSiparisNo := TFieldDB.Create('siparis_no', ftString, '', Self, 'Sipariş No');
  FSiparisTarihi := TFieldDB.Create('siparis_tarihi', ftDate, 0, Self, 'Sipariş Tarihi');
  FTeslimTarihi := TFieldDB.Create('teslim_tarihi', ftDate, 0, Self, 'Teslim Tarihi');
  FSiparisDurum := TFieldDB.Create('siparis_durum', ftString, '', Self, 'Sipariş Durum');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'Açıklama');
  FReferans := TFieldDB.Create('referans', ftString, '', Self, 'Referans');
  FReferansSatir := TFieldDB.Create('referans_satir', ftString, '', Self, 'Satır Referans');
end;

function TSatSiparisRapor.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
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
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSatSiparisRapor.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
