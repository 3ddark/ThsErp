unit ufrmSysDecimalPlace;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysDecimalPlace.Service, SysDecimalPlace, LocalizationManager;

type
  TfrmSysDecimalPlace = class(TfrmInputSimpleDB<TSysDecimalPlace, TSysDecimalPlaceService>)
    pnlContent: TPanel;
    lblQuantity: TLabel;
    lblPrice: TLabel;
    lblTotal: TLabel;
    lblStockQuantity: TLabel;
    lblExchangeRate: TLabel;
    edtQuantity: TSpinEdit;
    edtPrice: TSpinEdit;
    edtTotal: TSpinEdit;
    edtStockQuantity: TSpinEdit;
    edtExchangeRate: TSpinEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysDecimalPlace.BtnAcceptClick(Sender: TObject);
begin
  Table.Quantity := edtQuantity.Value;
  Table.Price := edtPrice.Value;
  Table.Total := edtTotal.Value;
  Table.StockQuantity := edtStockQuantity.Value;
  Table.ExchangeRate := edtExchangeRate.Value;
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
  ApplyLocalization;
  edtQuantity.SetFocus;
end;

procedure TfrmSysDecimalPlace.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.TitleSingular, 'Ondalık Basamak Ayarı');

  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColQuantity, 'Ondalık Basamak Ayarı');
  lblPrice.Caption := TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColPrice, 'Ondalık Basamak Ayarı');
  lblTotal.Caption := TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColTotal, 'Ondalık Basamak Ayarı');
  lblStockQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColStockQuantity, 'Ondalık Basamak Ayarı');
  lblExchangeRate.Caption := TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColExchangeRate, 'Ondalık Basamak Ayarı');
end;

procedure TfrmSysDecimalPlace.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmSysDecimalPlace.RefreshData;
begin
  inherited;
  edtQuantity.Value := Table.Quantity;
  edtPrice.Value := Table.Price;
  edtTotal.Value := Table.Total;
  edtStockQuantity.Value := Table.StockQuantity;
  edtExchangeRate.Value := Table.ExchangeRate;
end;

end.
