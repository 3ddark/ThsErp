unit ufrmSysDecimalPlace;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysDecimalPlace.Service, SysDecimalPlace;

type
  TfrmSysDecimalPlace = class(TfrmInputSimpleDB<TSysDecimalPlace, TSysDecimalPlaceService>)
    pnlContent: TPanel;
    lblquantity: TLabel;
    lblprice: TLabel;
    lbltotal: TLabel;
    lblstock_quantity: TLabel;
    lblexchange_rate: TLabel;
    edtquantity: TSpinEdit;
    edtprice: TSpinEdit;
    edttotal: TSpinEdit;
    edtstock_quantity: TSpinEdit;
    edtexchange_rate: TSpinEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysDecimalPlace.BtnAcceptClick(Sender: TObject);
begin
  Table.Quantity := edtquantity.Value;
  Table.Price := edtprice.Value;
  Table.Total := edttotal.Value;
  Table.StockQuantity := edtstock_quantity.Value;
  Table.ExchangeRate := edtexchange_rate.Value;
  inherited;
end;

procedure TfrmSysDecimalPlace.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysDecimalPlace.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'Decimal Place';

  edtquantity.SetFocus;
end;

procedure TfrmSysDecimalPlace.InitializeInputCase;
begin
  inherited;
  edtquantity.thsInputDataType := itInteger;
  edtprice.thsInputDataType := itInteger;
  edttotal.thsInputDataType := itInteger;
  edtstock_quantity.thsInputDataType := itInteger;
  edtexchange_rate.thsInputDataType := itInteger;
end;

procedure TfrmSysDecimalPlace.RefreshData;
begin
  inherited;
  edtquantity.Value := Table.Quantity;
  edtprice.Value := Table.Price;
  edttotal.Value := Table.Total;
  edtstock_quantity.Value := Table.StockQuantity;
  edtexchange_rate.Value := Table.ExchangeRate;
end;

end.
