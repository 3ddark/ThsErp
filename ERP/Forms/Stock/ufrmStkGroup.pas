unit ufrmStkGroup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkGroupService, StkGroup;

type
  TfrmStkGroup = class(TfrmInputSimpleDbX<TStkGroup, TStkGroupService>)
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
  published
    procedure BtnAcceptClick(Sender: TObject); override;

  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkGroup.BtnAcceptClick(Sender: TObject);
begin
  Table.GroupName.Value := edtGroupName.Text;
  Table.VatRate.Value := edtVatRate.Value / 100;
  Table.RawMaterialStockAccount.Value := edtRawMaterialStockAccount.Text;
  Table.RawMaterialUsageAccount.Value := edtRawMaterialUsageAccount.Text;
  Table.SemiProductAccount.Value := edtSemiProductAccount.Text;
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
  Self.Caption := 'Input Stk Group';
  edtGroupName.SetFocus;
end;

procedure TfrmStkGroup.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkGroup.RefreshData;
begin
  inherited;
  edtGroupName.Text := Table.GroupName.Value;
  edtVatRate.Value := Round(Table.VatRate.Value * 100);
  edtRawMaterialStockAccount.Text := Table.RawMaterialStockAccount.Value;
  edtRawMaterialUsageAccount.Text := Table.RawMaterialUsageAccount.Value;
  edtSemiProductAccount.Text := Table.SemiProductAccount.Value;
end;

end.
