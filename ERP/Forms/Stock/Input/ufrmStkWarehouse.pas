unit ufrmStkWarehouse;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkWarehouse.Service, StkWarehouse, LocalizationManager;

type
  TfrmStkWarehouse = class(TfrmInputSimpleDB<TStkWarehouse, TStkWarehouseService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblWarehouseName: TLabel;
    edtWarehouseName: TEdit;
    lblDefaultRawMaterial: TLabel;
    chkDefaultRawMaterial: TCheckBox;
    lblDefaultProduction: TLabel;
    chkDefaultProduction: TCheckBox;
    lblDefaultSales: TLabel;
    chkDefaultSales: TCheckBox;
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

procedure TfrmStkWarehouse.BtnAcceptClick(Sender: TObject);
begin
  Table.WarehouseName := edtWarehouseName.Text;
  Table.DefaultRawMaterial := chkDefaultRawMaterial.Checked;
  Table.DefaultProduction := chkDefaultProduction.Checked;
  Table.DefaultSales := chkDefaultSales.Checked;
  inherited;
end;

procedure TfrmStkWarehouse.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkWarehouse.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtWarehouseName.SetFocus;
end;

procedure TfrmStkWarehouse.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_warehouse.title_singular', 'Stok Ambarı');
  lblWarehouseName.Caption := TLocalizationManager.Translate('stk_warehouse.lbl_warehouse_name', 'Ambar Adı');
  lblDefaultRawMaterial.Caption := TLocalizationManager.Translate('stk_warehouse.lbl_default_raw_material', 'Varsayılan Hammadde');
  lblDefaultProduction.Caption := TLocalizationManager.Translate('stk_warehouse.lbl_default_production', 'Varsayılan Üretim');
  lblDefaultSales.Caption := TLocalizationManager.Translate('stk_warehouse.lbl_default_sales', 'Varsayılan Satış');
end;

procedure TfrmStkWarehouse.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkWarehouse.RefreshData;
begin
  inherited;
  edtWarehouseName.Text := Table.WarehouseName;
  chkDefaultRawMaterial.Checked := Table.DefaultRawMaterial;
  chkDefaultProduction.Checked := Table.DefaultProduction;
  chkDefaultSales.Checked := Table.DefaultSales;
end;

end.
