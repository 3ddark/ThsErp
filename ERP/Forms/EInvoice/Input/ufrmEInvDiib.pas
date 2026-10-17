unit ufrmEInvDiib;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvDiib.Service, EInvDiib;

type
  TfrmEInvDiib = class(TfrmInputSimpleDB<TEInvDiib, TEInvDiibService>)
    pnlContent: TPanel;
    lblDocumentNo: TLabel;
    edtDocumentNo: TEdit;
    lblHolderType: TLabel;
    cbbHolderType: TComboBox;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblIssueDate: TLabel;
    edtIssueDate: TEdit;
    lblValidUntil: TLabel;
    edtValidUntil: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
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
  EInvLookup,
  AccAccount, AccAccount.Service, ufrmAccAccounts;

procedure TfrmEInvDiib.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.DocumentNo := edtDocumentNo.Text;
  Table.HolderType := cbbHolderType.ItemIndex + 1;
  Table.IssueDate := StrToDateDef(edtIssueDate.Text, 0);
  Table.ValidUntil := StrToDateDef(edtValidUntil.Text, 0);
  Table.Description := edtDescription.Text;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvDiib.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtDocumentNo.thsInputDataType := itString;
  edtDocumentNo.CharCase := TEditCharCase.ecUpperCase;
  TEInvLookup.FillItems(cbbHolderType.Items, elkDiibHolder);
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtIssueDate.thsInputDataType := itDate;
  edtValidUntil.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmEInvDiib.FormShow(Sender: TObject);
begin
  inherited;
  if edtDocumentNo.CanFocus then
    edtDocumentNo.SetFocus;
end;

procedure TfrmEInvDiib.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.TitleSingular, 'DIIB Certificate');
  lblDocumentNo.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColDocumentNo, 'DIIB No');
  lblHolderType.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColHolderType, 'Certificate Holder');
  LIndex := cbbHolderType.ItemIndex;
  TEInvLookup.FillItems(cbbHolderType.Items, elkDiibHolder);
  cbbHolderType.ItemIndex := LIndex;
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColAccAccountId, 'Customer / Exporter');
  lblIssueDate.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColIssueDate, 'Issue Date');
  lblValidUntil.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColValidUntil, 'Valid Until');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColDescription, 'Description');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColIsActive, 'Active');
end;

procedure TfrmEInvDiib.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccAccountId.Name then
  begin
    LFrmAccAccountId := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmAccAccountId.IsHelper := True;
      LFrmAccAccountId.ShowModal;
      if LFrmAccAccountId.DataTransfer then
        if LFrmAccAccountId.CleanAndClose then
        begin
          Table.AccAccountId := 0;
          Table.AccountCode := '';
          Table.AccountName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccAccountId := LFrmAccAccountId.Table.Id;
          Table.AccountCode := LFrmAccAccountId.Table.Code;
          Table.AccountName := LFrmAccAccountId.Table.Name;
          LEdit.Text := Table.AccountName;
        end;
    finally
      LFrmAccAccountId.Free;
    end;
  end;
end;

procedure TfrmEInvDiib.RefreshData;
begin
  inherited;
  edtDocumentNo.Text := Table.DocumentNo;
  cbbHolderType.ItemIndex := Table.HolderType - 1;
  edtAccAccountId.Text := Table.AccountName;
  if Table.IssueDate > 0 then
    edtIssueDate.Text := DateToStr(Table.IssueDate)
  else
    edtIssueDate.Text := '';
  if Table.ValidUntil > 0 then
    edtValidUntil.Text := DateToStr(Table.ValidUntil)
  else
    edtValidUntil.Text := '';
  edtDescription.Text := Table.Description;
  chkIsActive.Checked := Table.IsActive;
end;

end.
