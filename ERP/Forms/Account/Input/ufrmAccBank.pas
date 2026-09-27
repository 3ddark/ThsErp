unit ufrmAccBank;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  AccBank.Service, AccBank;

type
  TfrmAccBank = class(TfrmInputSimpleDB<TAccBank, TAccBankService>)
    pnlContent: TPanel;
    lblBankName: TLabel;
    edtBankName: TEdit;
    lblSwiftCode: TLabel;
    edtSwiftCode: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccBank.BtnAcceptClick(Sender: TObject);
begin
  Table.BankName := edtBankName.Text;
  Table.SWiftCode := edtSwiftCode.Text;
  inherited;
end;

procedure TfrmAccBank.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmAccBank.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtBankName.SetFocus;
end;

procedure TfrmAccBank.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.TitleSingular, 'Region');
  lblBankName.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.ColBankName, 'Bank Name');
  lblSwiftCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.ColSwiftCode, 'Swift Code');
end;

procedure TfrmAccBank.RefreshData;
begin
  inherited;
  edtBankName.Text := Table.BankName;
  edtSwiftCode.Text := Table.SWiftCode;
end;

end.
