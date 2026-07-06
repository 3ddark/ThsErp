unit ufrmAccExchangeRate;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  AccExchangeRate.Service, AccExchangeRate;

type
  TfrmAccExchangeRate = class(TfrmInputSimpleDB<TAccExchangeRate, TAccExchangeRateService>)
    pnlContent: TPanel;
    lbltarih: TLabel;
    edttarih: TEdit;
    lblpara_birimi: TLabel;
    edtpara_birimi: TEdit;
    btnpara_sec: TButton;
    lblkur: TLabel;
    edtkur: TEdit;
  private
    FCurrencyId: string;
    procedure btnpara_secClick(Sender: TObject);
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccExchangeRate.BtnAcceptClick(Sender: TObject);
begin
  Table.RateDate := StrToDateDef(edttarih.Text, Date);
  Table.Currency := edtpara_birimi.Text;
  Table.Rate := StrToFloatDef(edtkur.Text, 0);
  inherited;
end;

procedure TfrmAccExchangeRate.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  btnpara_sec.OnClick := btnpara_secClick;
end;

procedure TfrmAccExchangeRate.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Döviz Kuru';
  edttarih.SetFocus;
end;

procedure TfrmAccExchangeRate.btnpara_secClick(Sender: TObject);
var
  LId: string;
  LName: string;
begin
  // TODO: Show currency selection helper form (ufrmSysParabirimleri)
  // For now, use a placeholder
  LId := '';
  LName := '';
  if LId <> '' then
  begin
    FCurrencyId := LId;
    edtpara_birimi.Text := LName;
  end;
end;

procedure TfrmAccExchangeRate.RefreshData;
begin
  inherited;
  edttarih.Text := DateToStr(Table.RateDate);
  edtpara_birimi.Text := Table.Currency;
  FCurrencyId := Table.Currency;
  edtkur.Text := FloatToStr(Table.Rate);
end;

end.
