unit ufrmAccBank;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
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
  Table.SwiftCode := edtSwiftCode.Text;
  inherited;
end;

procedure TfrmAccBank.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtBankName.thsInputDataType := itString;
  edtBankName.CharCase := TEditCharCase.ecUpperCase;
  edtSwiftCode.thsInputDataType := itString;
  edtSwiftCode.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmAccBank.FormShow(Sender: TObject);
begin
  inherited;
  if edtBankName.CanFocus then
    edtBankName.SetFocus;
end;

procedure TfrmAccBank.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.TitleSingular, 'Bank');
  lblBankName.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.ColBankName, 'Bank Name');
  lblSwiftCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.ColSwiftCode, 'Swift Code');
end;

procedure TfrmAccBank.RefreshData;
begin
  inherited;
  edtBankName.Text := Table.BankName;
  edtSwiftCode.Text := Table.SwiftCode;
end;

end.
