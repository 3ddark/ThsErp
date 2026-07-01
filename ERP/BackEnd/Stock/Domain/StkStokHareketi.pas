unit StkStokHareketi;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_transaction')]
  TStkStokHareketi = class(TEntity)
  private
    FStokID: Int64;
    FTipID: Int64;
    FMiktar: Double;
    FKodu: string;
    FDosyaNo: string;
    FTarih: TDateTime;
  public
    [Column('stok_id')]
    Property StokID: Int64 read FStokID write FStokID;

    [Column('tip_id')]
    Property TipID: Int64 read FTipID write FTipID;

    [Column('miktar')]
    Property Miktar: Double read FMiktar write FMiktar;

    [Column('kodu')]
    Property Kudu: string read FKodu write FKodu;

    [Column('dosya_no')]
    Property DosyaNo: string read FDosyaNo write FDosyaNo;

    [Column('tarih')]
    Property Tarih: TDateTime read FTarih write FTarih;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkStokHareketi.Create;
begin
  inherited;
end;

destructor TStkStokHareketi.Destroy;
begin
  inherited;
end;

end.
