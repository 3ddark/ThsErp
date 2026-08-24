unit ufrmStkGroup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, Ths.Helper.SpinEdit,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkGroup.Service, StkGroup, LocalizationManager;

type
  TfrmStkGroup = class(TfrmInputSimpleDB<TStkGroup, TStkGroupService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblGroupName: TLabel;
    edtGroupName: TEdit;
    lblVatRate: TLabel;
    edtVatRate: TSpinEdit;
    lblRawMaterialStockAccount: TLabel;
    edtRawMaterialStockAccount: TEdit;
    lblRawMaterialUsageAccount: TLabel;
    edtRawMaterialUsageAccount: TEdit;
    lblSemiProductAccount: TLabel;
    edtSemiProductAccount: TEdit;
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

procedure TfrmStkGroup.BtnAcceptClick(Sender: TObject);
begin
  Table.GroupName := edtGroupName.Text;
  Table.VatRate := edtVatRate.Value / 100;
  Table.RawMaterialStockAccount := edtRawMaterialStockAccount.Text;
  Table.RawMaterialUsageAccount := edtRawMaterialUsageAccount.Text;
  Table.SemiProductAccount := edtSemiProductAccount.Text;
  inherited;
end;

procedure TfrmStkGroup.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkGroup.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtGroupName.SetFocus;
end;

procedure TfrmStkGroup.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_group.title_singular', 'Stok Grubu');
  lblGroupName.Caption := TLocalizationManager.Translate('stk_group.lbl_group_name', 'Grup Adı');
  lblVatRate.Caption := TLocalizationManager.Translate('stk_group.lbl_vat_rate', 'KDV Oranı (%)');
  lblRawMaterialStockAccount.Caption := TLocalizationManager.Translate('stk_group.lbl_rm_stock_account', 'Hammadde Stok Hesabı');
  lblRawMaterialUsageAccount.Caption := TLocalizationManager.Translate('stk_group.lbl_rm_usage_account', 'Hammadde Kullanım Hesabı');
  lblSemiProductAccount.Caption := TLocalizationManager.Translate('stk_group.lbl_semi_product_account', 'Yarı Mamul Hesabı');
end;

procedure TfrmStkGroup.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkGroup.RefreshData;
begin
  inherited;
  edtGroupName.Text := Table.GroupName;
  edtVatRate.Value := Round(Table.VatRate * 100);
  edtRawMaterialStockAccount.Text := Table.RawMaterialStockAccount;
  edtRawMaterialUsageAccount.Text := Table.RawMaterialUsageAccount;
  edtSemiProductAccount.Text := Table.SemiProductAccount;
end;

end.
