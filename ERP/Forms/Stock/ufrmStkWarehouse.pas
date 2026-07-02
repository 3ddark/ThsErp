unit ufrmStkWarehouse;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkWarehouseService, StkWarehouse;

type
  TfrmStkWarehouse = class(TfrmInputSimpleDbX<TStkWarehouse, TStkWarehouseService>)
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
  published
    procedure BtnAcceptClick(Sender: TObject); override;

  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkWarehouse.BtnAcceptClick(Sender: TObject);
begin
  Table.WarehouseName.Value := edtWarehouseName.Text;
  Table.DefaultRawMaterial.Value := chkDefaultRawMaterial.Checked;
  Table.DefaultProduction.Value := chkDefaultProduction.Checked;
  Table.DefaultSales.Value := chkDefaultSales.Checked;
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
  Self.Caption := 'Input Stk Warehouse';
  edtWarehouseName.SetFocus;
end;

procedure TfrmStkWarehouse.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkWarehouse.RefreshData;
begin
  inherited;
  edtWarehouseName.Text := Table.WarehouseName.Value;
  chkDefaultRawMaterial.Checked := Table.DefaultRawMaterial.Value;
  chkDefaultProduction.Checked := Table.DefaultProduction.Value;
  chkDefaultSales.Checked := Table.DefaultSales.Value;
end;

end.
