unit ufrmStkInventory;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Ths.Helper.SpinEdit, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkInventory.Service, StkInventory, LocalizationManager;

type
  TfrmStkInventory = class(TfrmInputSimpleDB<TStkInventory, TStkInventoryService>)
    pgcMain: TPageControl;
    tsGenel: TTabSheet;
    lblstok_kodu: TLabel;
    edtStokKodu: TEdit;
    lblstok_adi: TLabel;
    edtStokAdi: TEdit;
    lblis_satilabilir: TLabel;
    chkIsSatilabilir: TCheckBox;

    tsParasal: TTabSheet;
    pnlParasalHeader: TPanel;
    lblalis_fiyat: TLabel;
    edtAlisFiyat: TMaskEdit;
    lblalis_para: TLabel;
    edtAlisPara: TEdit;
    lblsatis_fiyat: TLabel;
    edtSatisFiyat: TMaskEdit;
    lblsatis_para: TLabel;
    edtSatisPara: TEdit;
    lblihrac_fiyat: TLabel;
    edtIhracFiyat: TMaskEdit;
    lblihrac_para: TLabel;
    edtIhracPara: TEdit;
    lblalis_iskonto: TLabel;
    edtAlisIskonto: TSpinEdit;
    lblsatis_iskonto: TLabel;
    edtSatisIskonto: TSpinEdit;
    lblortalama_maliyet_brm: TLabel;

    tsGrupOzellikleri: TTabSheet;
    pnlGrupHeader: TPanel;
    lblen: TLabel;
    edtEn: TEdit;
    lblboy: TLabel;
    edtBoy: TEdit;
    lblhacim: TLabel;
    lblValueHacim: TLabel;
    lbllabel_agirlik: TLabel;
    edtAgirlik: TEdit;
    lbltemin_suresi: TLabel;
    edtTeminSuresi: TSpinEdit;
    lblozel_kod: TLabel;
    edtOzelKod: TEdit;
    lblmarka: TLabel;
    edtMarka: TEdit;

    tsCinsOzelligi: TTabSheet;
    pnlCinsHeader: TPanel;
    lblmensei_id: TLabel;
    edtMenseiID: TEdit;
    lblgtip_no: TLabel;
    edtGtipNo: TEdit;
    lbldiib_urun_tanimi: TLabel;
    edtDiibUrunTanimi: TEdit;

    tsOzetler: TTabSheet;
    pnlOzetHeader: TPanel;
    lblen_az_stok_seviyesi: TLabel;
    edtEnAzStokSeviyesi: TEdit;
    lbldetay: TLabel;
    mmoTanim: TMemo;

    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure BtnAcceptClick(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkInventory.BtnAcceptClick(Sender: TObject);
begin
  Table.Sellable := chkIsSatilabilir.Checked;
  Table.Code := edtStokKodu.Text;
  Table.Name := edtStokAdi.Text;
  Table.BuyingDiscount := edtAlisIskonto.Value / 100;
  Table.SalesDiscount := edtSatisIskonto.Value / 100;
  Table.BuyingPrice := StrToFloatDef(edtAlisFiyat.Text, 0);
  Table.BuyingCurrency := edtAlisPara.Text;
  Table.SalesPrice := StrToFloatDef(edtSatisFiyat.Text, 0);
  Table.SalesCurrency := edtSatisPara.Text;
  Table.ExportPrice := StrToFloatDef(edtIhracFiyat.Text, 0);
  Table.ExportCurrency := edtIhracPara.Text;
  Table.Width := StrToFloatDef(edtEn.Text, 0);
  Table.Length := StrToFloatDef(edtBoy.Text, 0);
  Table.Weight := StrToFloatDef(edtAgirlik.Text, 0);
//  Table.SupplyDuration := edtTeminSuresi.Value;
  Table.SpecialCode := edtOzelKod.Text;
  Table.Brand := edtMarka.Text;
  Table.OriginId := StrToInt64Def(edtMenseiID.Text, 0);
  Table.HsNo := edtGtipNo.Text;
  Table.DiibProductDescription := edtDiibUrunTanimi.Text;
  Table.MinStockAmount := StrToFloatDef(edtEnAzStokSeviyesi.Text, 0);
  Table.ProductOverview := mmoTanim.Lines.Text;
  inherited;
end;

procedure TfrmStkInventory.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkInventory.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtStokKodu.SetFocus;
end;

procedure TfrmStkInventory.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_inventory.title_singular', 'Stok Kartı');
  lblstok_kodu.Caption := TLocalizationManager.Translate('stk_inventory.lbl_code', 'Stok Kodu');
  lblstok_adi.Caption := TLocalizationManager.Translate('stk_inventory.lbl_name', 'Stok Adı');
  lblis_satilabilir.Caption := TLocalizationManager.Translate('stk_inventory.lbl_sellable', 'Satılabilir');
  lblalis_fiyat.Caption := TLocalizationManager.Translate('stk_inventory.lbl_buying_price', 'Alış Fiyatı');
  lblalis_para.Caption := TLocalizationManager.Translate('stk_inventory.lbl_buying_currency', 'Alış Para Birimi');
  lblsatis_fiyat.Caption := TLocalizationManager.Translate('stk_inventory.lbl_sales_price', 'Satış Fiyatı');
  lblsatis_para.Caption := TLocalizationManager.Translate('stk_inventory.lbl_sales_currency', 'Satış Para Birimi');
  lblihrac_fiyat.Caption := TLocalizationManager.Translate('stk_inventory.lbl_export_price', 'İhraç Fiyatı');
  lblihrac_para.Caption := TLocalizationManager.Translate('stk_inventory.lbl_export_currency', 'İhraç Para Birimi');
  lblalis_iskonto.Caption := TLocalizationManager.Translate('stk_inventory.lbl_buying_discount', 'Alış İskonto (%)');
  lblsatis_iskonto.Caption := TLocalizationManager.Translate('stk_inventory.lbl_sales_discount', 'Satış İskonto (%)');
  lblen.Caption := TLocalizationManager.Translate('stk_inventory.lbl_width', 'En');
  lblboy.Caption := TLocalizationManager.Translate('stk_inventory.lbl_length', 'Boy');
  lbllabel_agirlik.Caption := TLocalizationManager.Translate('stk_inventory.lbl_weight', 'Ağırlık');
  lbltemin_suresi.Caption := TLocalizationManager.Translate('stk_inventory.lbl_supply_duration', 'Temin Süresi (Gün)');
  lblozel_kod.Caption := TLocalizationManager.Translate('stk_inventory.lbl_special_code', 'Özel Kod');
  lblmarka.Caption := TLocalizationManager.Translate('stk_inventory.lbl_brand', 'Marka');
  lblmensei_id.Caption := TLocalizationManager.Translate('stk_inventory.lbl_origin_id', 'Menşei ID');
  lblgtip_no.Caption := TLocalizationManager.Translate('stk_inventory.lbl_hs_no', 'GTİP No');
  lbldiib_urun_tanimi.Caption := TLocalizationManager.Translate('stk_inventory.lbl_diib_desc', 'DİİB Ürün Tanımı');
  lblen_az_stok_seviyesi.Caption := TLocalizationManager.Translate('stk_inventory.lbl_min_stock', 'En Az Stok Seviyesi');
  lbldetay.Caption := TLocalizationManager.Translate('stk_inventory.lbl_overview', 'Ürün Genel Tanımı');
end;

procedure TfrmStkInventory.InitializeInputCase;
begin
  inherited;
  mmoTanim.CharCase := TEditCharCase.ecNormal;
end;

procedure TfrmStkInventory.RefreshData;
begin
  inherited;
  chkIsSatilabilir.Checked := Table.Sellable;
  edtStokKodu.Text := Table.Code;
  edtStokAdi.Text := Table.Name;
  edtAlisIskonto.Value := Round(Table.BuyingDiscount * 100);
  edtSatisIskonto.Value := Round(Table.SalesDiscount * 100);
  edtAlisFiyat.Text := FormatFloat('0.00', Table.BuyingPrice);
  edtAlisPara.Text := Table.BuyingCurrency;
  edtSatisFiyat.Text := FormatFloat('0.00', Table.SalesPrice);
  edtSatisPara.Text := Table.SalesCurrency;
  edtIhracFiyat.Text := FormatFloat('0.00', Table.ExportPrice);
  edtIhracPara.Text := Table.ExportCurrency;
  edtEn.Text := FloatToStr(Table.Width);
  edtBoy.Text := FloatToStr(Table.Length);
  edtAgirlik.Text := FloatToStr(Table.Weight);
  edtTeminSuresi.Value := Table.SupplyDuration;
  edtOzelKod.Text := Table.SpecialCode;
  edtMarka.Text := Table.Brand;
  edtMenseiID.Text := IntToStr(Table.OriginId);
  edtGtipNo.Text := Table.HsNo;
  edtDiibUrunTanimi.Text := Table.DiibProductDescription;
  edtEnAzStokSeviyesi.Text := FloatToStr(Table.MinStockAmount);
  mmoTanim.Lines.Text := Table.ProductOverview;
end;

end.
