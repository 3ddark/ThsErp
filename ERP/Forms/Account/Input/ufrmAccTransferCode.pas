unit ufrmAccTransferCode;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccTransferCode.Service, AccTransferCode;

type
  TfrmAccTransferCode = class(TfrmInputSimpleDB<TAccTransferCode, TAccTransferCodeService>)
    pnlContent: TPanel;
    lblTransferCode: TLabel;
    edtTransferCode: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblAccount: TLabel;
    edtAccount: TEdit;
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
  AccAccount, AccAccount.Service, ufrmAccAccounts;                              // TfrmAccAccounts helper output form

procedure TfrmAccTransferCode.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.TransferCode := edtTransferCode.Text;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmAccTransferCode.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtAccount.OnHelperProcess := HelperProcess;
  edtTransferCode.thsInputDataType := itString;
  edtTransferCode.CharCase := TEditCharCase.ecUpperCase;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmAccTransferCode.FormShow(Sender: TObject);
begin
  inherited;
  if edtTransferCode.CanFocus then
    edtTransferCode.SetFocus;
end;

procedure TfrmAccTransferCode.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccTransferCode.TitleSingular, 'Transfer Code');
  lblTransferCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccTransferCode.ColTransferCode, 'Transfer Code');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TAccTransferCode.ColDescription, 'Description');
  lblAccount.Caption := TLocalizationManager.Translate(TLangKeys.TAccTransferCode.ColAccount, 'Account');
end;

procedure TfrmAccTransferCode.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccount: TfrmAccAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccount.Name then
  begin
    LFrmAccount := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmAccount.IsHelper := True;
      LFrmAccount.ShowModal;
      if LFrmAccount.DataTransfer then
        if LFrmAccount.CleanAndClose then
        begin
          Table.Account := '';
          LEdit.Clear;
        end
        else
        begin
          Table.Account := LFrmAccount.Table.Code;
          LEdit.Text := Table.Account;
        end;
    finally
      LFrmAccount.Free;
    end;
  end;
end;

procedure TfrmAccTransferCode.RefreshData;
begin
  inherited;
  edtTransferCode.Text := Table.TransferCode;
  edtDescription.Text := Table.Description;
  edtAccount.Text := Table.Account;
end;

end.
