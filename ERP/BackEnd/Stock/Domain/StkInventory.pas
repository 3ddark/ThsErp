unit StkInventory;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_inventory')]
  TStkInventory = class(TEntity)
  private
    FIsSatilabilir: Boolean;
    FStokKodu: string;
    FStokAdi: string;
    FStokGrubuID: Int64;
    FOlcuBirimiID: Int64;
    FUrunTipi: SmallInt;
    FAlisIskonto: Double;
    FSatisIskonto: Double;
    FAlisFiyat: Double;
    FAlisPara: string;
    FSatisFiyat: Double;
    FSatisPara: string;
    FIhracFiyat: Double;
    FIhracPara: string;
    FOrtalamaMaliyet: Double;
    FEn: Double;
    FBoy: Double;
    FYukseklik: Double;
    FAgirlik: Double;
    FTeminSuresi: Integer;
    FOzelKod: string;
    FMarka: string;
    FMenseiID: Int64;
    FGtipNo: string;
    FDiibUrunTanimi: string;
    FEnAzStokSeviyesi: Double;
    FTanim: string;
  public
    [Column('is_satilabilir')]
    Property IsSatilabilir: Boolean read FIsSatilabilir write FIsSatilabilir;

    [Column('stok_kodu')]
    Property StokKodu: string read FStokKodu write FStokKodu;

    [Column('stok_adi')]
    Property StokAdi: string read FStokAdi write FStokAdi;

    [Column('stok_grubu_id')]
    Property StokGrubuID: Int64 read FStokGrubuID write FStokGrubuID;

    [Column('olcu_birimi_id')]
    Property OlcuBirimiID: Int64 read FOlcuBirimiID write FOlcuBirimiID;

    [Column('urun_tipi')]
    Property UrunTipi: SmallInt read FUrunTipi write FUrunTipi;

    [Column('alis_iskonto')]
    Property AlisIskonto: Double read FAlisIskonto write FAlisIskonto;

    [Column('satis_iskonto')]
    Property SatisIskonto: Double read FSatisIskonto write FSatisIskonto;

    [Column('alis_fiyat')]
    Property AlisFiyat: Double read FAlisFiyat write FAlisFiyat;

    [Column('alis_para')]
    Property AlisPara: string read FAlisPara write FAlisPara;

    [Column('satis_fiyat')]
    Property SatisFiyat: Double read FSatisFiyat write FSatisFiyat;

    [Column('satis_para')]
    Property SatisPara: string read FSatisPara write FSatisPara;

    [Column('ihrac_fiyat')]
    Property IhracFiyat: Double read FIhracFiyat write FIhracFiyat;

    [Column('ihrac_para')]
    Property IhracPara: string read FIhracPara write FIhracPara;

    [Column('ortalama_maliyet')]
    Property OrtalamaMaliyet: Double read FOrtalamaMaliyet write FOrtalamaMaliyet;

    [Column('en')]
    Property En: Double read FEn write FEn;

    [Column('boy')]
    Property Boy: Double read FBoy write FBoy;

    [Column('yukseklik')]
    Property Yukseklik: Double read FYukseklik write FYukseklik;

    [Column('agirlik')]
    Property Agirlik: Double read FAgirlik write FAgirlik;

    [Column('temin_suresi')]
    Property TeminSuresi: Integer read FTeminSuresi write FTeminSuresi;

    [Column('ozel_kod')]
    Property OzelKod: string read FOzelKod write FOzelKod;

    [Column('marka')]
    Property Marka: string read FMarka write FMarka;

    [Column('mensei_id')]
    Property MenseiID: Int64 read FMenseiID write FMenseiID;

    [Column('gtip_no')]
    Property GtipNo: string read FGtipNo write FGtipNo;

    [Column('diib_urun_tanimi')]
    Property DiibUrunTanimi: string read FDiibUrunTanimi write FDiibUrunTanimi;

    [Column('en_az_stok_seviyesi')]
    Property EnAzStokSeviyesi: Double read FEnAzStokSeviyesi write FEnAzStokSeviyesi;

    [Column('tanim')]
    Property Tanim: string read FTanim write FTanim;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkKart.Create;
begin
  inherited;
  FIsSatilabilir := False;
  FUrunTipi := 0;
  FAlisIskonto := 0;
  FSatisIskonto := 0;
  FAlisFiyat := 0;
  FSatisFiyat := 0;
  FIhracFiyat := 0;
  FOrtalamaMaliyet := 0;
  FEn := 0;
  FBoy := 0;
  FYukseklik := 0;
  FAgirlik := 0;
  FTeminSuresi := 0;
  FEnAzStokSeviyesi := 0;
end;

destructor TStkKart.Destroy;
begin
  inherited;
end;

end.
