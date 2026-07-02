unit ufrmStkKart;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkInventoryService, StkInventory;

type
  TfrmStkKart = class(TfrmInputSimpleDbX<TStkInventory, TStkInventoryService>)
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
  published
    procedure BtnAcceptClick(Sender: TObject); override;

  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkKart.BtnAcceptClick(Sender: TObject);
begin
  Table.IsSellable.Value := chkIsSatilabilir.Checked;
  Table.StokKodu.Value := edtStokKodu.Text;
  Table.StokAdi.Value := edtStokAdi.Text;
  Table.AlisIskonto.Value := edtAlisIskonto.Value / 100;
  Table.SatisIskonto.Value := edtSatisIskonto.Value / 100;
  Table.AlisFiyat.Value := StrToFloatDef(edtAlisFiyat.Text, 0);
  Table.AlisPara.Value := edtAlisPara.Text;
  Table.SatisFiyat.Value := StrToFloatDef(edtSatisFiyat.Text, 0);
  Table.SatisPara.Value := edtSatisPara.Text;
  Table.IhracFiyat.Value := StrToFloatDef(edtIhracFiyat.Text, 0);
  Table.IhracPara.Value := edtIhracPara.Text;
  Table.En.Value := StrToFloatDef(edtEn.Text, 0);
  Table.Boy.Value := StrToFloatDef(edtBoy.Text, 0);
  Table.Agirlik.Value := StrToFloatDef(edtAgirlik.Text, 0);
  Table.TeminSuresi.Value := edtTeminSuresi.Value;
  Table.OzelKod.Value := edtOzelKod.Text;
  Table.Marka.Value := edtMarka.Text;
  Table.MenseiID.Value := StrToIntDef(edtMenseiID.Text, 0);
  Table.GtipNo.Value := edtGtipNo.Text;
  Table.DiibUrunTanimi.Value := edtDiibUrunTanimi.Text;
  Table.EnAzStokSeviyesi.Value := StrToFloatDef(edtEnAzStokSeviyesi.Text, 0);
  Table.Tanim.Value := mmoTanim.Lines.Text;
  inherited;
end;

procedure TfrmStkKart.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkKart.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Input Stk Inventory';
  edtStokKodu.SetFocus;
end;

procedure TfrmStkKart.InitializeInputCase;
begin
  inherited;
  mmoTanim.CharCase := TEditCharCase.ecNormal;
end;

procedure TfrmStkKart.RefreshData;
begin
  inherited;
  chkIsSatilabilir.Checked := Table.IsSellable.Value;
  edtStokKodu.Text := Table.StokKodu.Value;
  edtStokAdi.Text := Table.StokAdi.Value;
  edtAlisIskonto.Value := Round(Table.AlisIskonto.Value * 100);
  edtSatisIskonto.Value := Round(Table.SatisIskonto.Value * 100);
  edtAlisFiyat.Text := FormatFloat('0.00', Table.AlisFiyat.Value);
  edtAlisPara.Text := Table.AlisPara.Value;
  edtSatisFiyat.Text := FormatFloat('0.00', Table.SatisFiyat.Value);
  edtSatisPara.Text := Table.SatisPara.Value;
  edtIhracFiyat.Text := FormatFloat('0.00', Table.IhracFiyat.Value);
  edtIhracPara.Text := Table.IhracPara.Value;
  edtEn.Text := FloatToStr(Table.En.Value);
  edtBoy.Text := FloatToStr(Table.Boy.Value);
  edtAgirlik.Text := FloatToStr(Table.Agirlik.Value);
  edtTeminSuresi.Value := Table.TeminSuresi.Value;
  edtOzelKod.Text := Table.OzelKod.Value;
  edtMarka.Text := Table.Marka.Value;
  edtMenseiID.Text := IntToStr(Table.MenseiID.Value);
  edtGtipNo.Text := Table.GtipNo.Value;
  edtDiibUrunTanimi.Text := Table.DiibUrunTanimi.Value;
  edtEnAzStokSeviyesi.Text := FloatToStr(Table.EnAzStokSeviyesi.Value);
  mmoTanim.Lines.Text := Table.Tanim.Value;
end;

end.
