unit ufrmStkWarehouse;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  StkWarehouse.Service, StkWarehouse;

type
  TfrmStkWarehouse = class(TfrmInputSimpleDB<TStkWarehouse, TStkWarehouseService>)
    pnlContent: TPanel;
    lblWarehouseName: TLabel;
    edtWarehouseName: TEdit;
    lblDefaultRawMaterial: TLabel;
    chkDefaultRawMaterial: TCheckBox;
    lblDefaultProduction: TLabel;
    chkDefaultProduction: TCheckBox;
    lblDefaultSales: TLabel;
    chkDefaultSales: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
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
  pnlContent.Parent := PanelMain;
  edtWarehouseName.thsInputDataType := itString;
  edtWarehouseName.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmStkWarehouse.FormShow(Sender: TObject);
begin
  inherited;
  if edtWarehouseName.CanFocus then
    edtWarehouseName.SetFocus;
end;

procedure TfrmStkWarehouse.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkWarehouse.TitleSingular, 'Warehouse');
  lblWarehouseName.Caption := TLocalizationManager.Translate(TLangKeys.TStkWarehouse.ColWarehouseName, 'Warehouse Name');
  lblDefaultRawMaterial.Caption := TLocalizationManager.Translate(TLangKeys.TStkWarehouse.ColDefaultRawMaterial, 'Default Raw Material');
  lblDefaultProduction.Caption := TLocalizationManager.Translate(TLangKeys.TStkWarehouse.ColDefaultProduction, 'Default Production');
  lblDefaultSales.Caption := TLocalizationManager.Translate(TLangKeys.TStkWarehouse.ColDefaultSales, 'Default Sales');
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
