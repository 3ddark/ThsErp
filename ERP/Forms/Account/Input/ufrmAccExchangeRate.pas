unit ufrmAccExchangeRate;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccExchangeRate.Service, AccExchangeRate;

type
  TfrmAccExchangeRate = class(TfrmInputSimpleDB<TAccExchangeRate, TAccExchangeRateService>)
    pnlContent: TPanel;
    lblRateDate: TLabel;
    edtRateDate: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblRate: TLabel;
    edtRate: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;                          // TfrmSysCurrencies helper output form

procedure TfrmAccExchangeRate.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.RateDate := StrToDateDef(edtRateDate.Text, 0);
  Table.Rate := StrToCurrDef(edtRate.Text, 0);
  inherited;
end;

procedure TfrmAccExchangeRate.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtRateDate.thsInputDataType := itDate;
  edtRate.thsInputDataType := itFloat;
end;

procedure TfrmAccExchangeRate.FormShow(Sender: TObject);
begin
  inherited;
  if edtRateDate.CanFocus then
    edtRateDate.SetFocus;
end;

procedure TfrmAccExchangeRate.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.TitleSingular, 'Exchange Rate');
  lblRateDate.Caption := TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColRateDate, 'Date');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColCurrency, 'Currency');
  lblRate.Caption := TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColRate, 'Rate');
end;

procedure TfrmAccExchangeRate.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmCurrency: TfrmSysCurrencies;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtCurrency.Name then
  begin
    LFrmCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmCurrency.IsHelper := True;
      LFrmCurrency.ShowModal;
      if LFrmCurrency.DataTransfer then
        if LFrmCurrency.CleanAndClose then
        begin
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.Currency := LFrmCurrency.Table.Currency;
          LEdit.Text := Table.Currency;
        end;
    finally
      LFrmCurrency.Free;
    end;
  end;
end;

procedure TfrmAccExchangeRate.RefreshData;
begin
  inherited;
  if Table.RateDate > 0 then
    edtRateDate.Text := DateToStr(Table.RateDate)
  else
    edtRateDate.Text := '';
  edtCurrency.Text := Table.Currency;
  edtRate.Text := CurrToStr(Table.Rate);
end;

end.
