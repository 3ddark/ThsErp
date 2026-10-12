unit ufrmFinChequeNote;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  FinChequeNote.Service, FinChequeNote;

type
  TfrmFinChequeNote = class(TfrmInputSimpleDB<TFinChequeNote, TFinChequeNoteService>)
    pnlContent: TPanel;
    lblDocKind: TLabel;
    cbbDocKind: TComboBox;
    lblDirection: TLabel;
    cbbDirection: TComboBox;
    lblPortfolioNo: TLabel;
    edtPortfolioNo: TEdit;
    lblSerialNo: TLabel;
    edtSerialNo: TEdit;
    lblIssueDate: TLabel;
    edtIssueDate: TEdit;
    lblDueDate: TLabel;
    edtDueDate: TEdit;
    lblAmount: TLabel;
    edtAmount: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblStatusText: TLabel;
    edtStatusText: TEdit;
    lblDrawerName: TLabel;
    edtDrawerName: TEdit;
    lblDrawerTaxNo: TLabel;
    edtDrawerTaxNo: TEdit;
    lblIssuePlace: TLabel;
    edtIssuePlace: TEdit;
    lblAccBankId: TLabel;
    edtAccBankId: TEdit;
    lblAccBankBranchId: TLabel;
    edtAccBankBranchId: TEdit;
    lblBankAccountNo: TLabel;
    edtBankAccountNo: TEdit;
    lblGuarantorName: TLabel;
    edtGuarantorName: TEdit;
    lblNotes: TLabel;
    mmoNotes: TMemo;
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
  FinLookup,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  AccBank, AccBank.Service, ufrmAccBanks,
  AccBankBranch, AccBankBranch.Service, ufrmAccBankBranches;

procedure TfrmFinChequeNote.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.DocKind := cbbDocKind.ItemIndex + 1;
  Table.Direction := cbbDirection.ItemIndex + 1;
  Table.PortfolioNo := edtPortfolioNo.Text;
  Table.SerialNo := edtSerialNo.Text;
  Table.IssueDate := StrToDateDef(edtIssueDate.Text, 0);
  Table.DueDate := StrToDateDef(edtDueDate.Text, 0);
  Table.Amount := StrToCurrDef(edtAmount.Text, 0);
  Table.DrawerName := edtDrawerName.Text;
  Table.DrawerTaxNo := edtDrawerTaxNo.Text;
  Table.IssuePlace := edtIssuePlace.Text;
  Table.BankAccountNo := edtBankAccountNo.Text;
  Table.GuarantorName := edtGuarantorName.Text;
  Table.Notes := mmoNotes.Text;
  inherited;
end;

procedure TfrmFinChequeNote.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  TFinLookup.FillItems(cbbDocKind.Items, flkDocKind);
  TFinLookup.FillItems(cbbDirection.Items, flkDirection);
  edtPortfolioNo.thsInputDataType := itString;
  edtPortfolioNo.CharCase := TEditCharCase.ecUpperCase;
  edtSerialNo.thsInputDataType := itString;
  edtSerialNo.CharCase := TEditCharCase.ecUpperCase;
  edtIssueDate.thsInputDataType := itDate;
  edtDueDate.thsInputDataType := itDate;
  edtAmount.thsInputDataType := itFloat;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtDrawerName.thsInputDataType := itString;
  edtDrawerTaxNo.thsInputDataType := itString;
  edtIssuePlace.thsInputDataType := itString;
  edtAccBankId.OnHelperProcess := HelperProcess;
  edtAccBankBranchId.OnHelperProcess := HelperProcess;
  edtBankAccountNo.thsInputDataType := itString;
  edtGuarantorName.thsInputDataType := itString;
end;

procedure TfrmFinChequeNote.FormShow(Sender: TObject);
begin
  inherited;
  if cbbDocKind.CanFocus then
    cbbDocKind.SetFocus;
end;

procedure TfrmFinChequeNote.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.TitleSingular, 'Cheque / Note');
  lblDocKind.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDocKind, 'Document Kind');
  LIndex := cbbDocKind.ItemIndex;
  TFinLookup.FillItems(cbbDocKind.Items, flkDocKind);
  cbbDocKind.ItemIndex := LIndex;
  lblDirection.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDirection, 'Direction');
  LIndex := cbbDirection.ItemIndex;
  TFinLookup.FillItems(cbbDirection.Items, flkDirection);
  cbbDirection.ItemIndex := LIndex;
  lblPortfolioNo.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColPortfolioNo, 'Portfolio No');
  lblSerialNo.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColSerialNo, 'Serial No');
  lblIssueDate.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColIssueDate, 'Issue Date');
  lblDueDate.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDueDate, 'Due Date');
  lblAmount.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColAmount, 'Amount');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColCurrency, 'Currency');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColAccAccountId, 'Account (Received From / Given To)');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColStatus, 'Status');
  lblDrawerName.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDrawerName, 'Drawer / Debtor');
  lblDrawerTaxNo.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColDrawerTaxNo, 'Drawer Tax No');
  lblIssuePlace.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColIssuePlace, 'Place of Issue');
  lblAccBankId.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColAccBankId, 'Bank');
  lblAccBankBranchId.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColAccBankBranchId, 'Bank Branch');
  lblBankAccountNo.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColBankAccountNo, 'Bank Account No');
  lblGuarantorName.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColGuarantorName, 'Guarantor');
  lblNotes.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.ColNotes, 'Notes');
end;

procedure TfrmFinChequeNote.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmCurrency: TfrmSysCurrencies;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmAccBankId: TfrmAccBanks;
  LFrmAccBankBranchId: TfrmAccBankBranches;
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
  end
  else if LEdit.Name = edtAccAccountId.Name then
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
  end
  else if LEdit.Name = edtAccBankId.Name then
  begin
    LFrmAccBankId := TfrmAccBanks.Create(LEdit, TAccBankService.Create, TAccBank.Create);
    try
      LFrmAccBankId.IsHelper := True;
      LFrmAccBankId.ShowModal;
      if LFrmAccBankId.DataTransfer then
        if LFrmAccBankId.CleanAndClose then
        begin
          Table.AccBankId := 0;
          Table.BankName := '';
          Table.AccBankBranchId := 0;
          Table.BranchName := '';
          edtAccBankBranchId.Clear;
          LEdit.Clear;
        end
        else
        begin
          if Table.AccBankId <> LFrmAccBankId.Table.Id then
          begin
            Table.AccBankBranchId := 0;
            Table.BranchName := '';
            edtAccBankBranchId.Clear;
          end;
          Table.AccBankId := LFrmAccBankId.Table.Id;
          Table.BankName := LFrmAccBankId.Table.BankName;
          LEdit.Text := Table.BankName;
        end;
    finally
      LFrmAccBankId.Free;
    end;
  end
  else if LEdit.Name = edtAccBankBranchId.Name then
  begin
    LFrmAccBankBranchId := TfrmAccBankBranches.Create(LEdit, TAccBankBranchService.Create, TAccBankBranch.Create);
    try
      LFrmAccBankBranchId.IsHelper := True;
      if Table.AccBankId > 0 then
        LFrmAccBankBranchId.SetFixedBank(Table.AccBankId, Table.BankName);
      LFrmAccBankBranchId.ShowModal;
      if LFrmAccBankBranchId.DataTransfer then
        if LFrmAccBankBranchId.CleanAndClose then
        begin
          Table.AccBankBranchId := 0;
          Table.BranchName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccBankBranchId := LFrmAccBankBranchId.Table.Id;
          Table.BranchName := LFrmAccBankBranchId.Table.BranchName;
          LEdit.Text := Table.BranchName;
        end;
    finally
      LFrmAccBankBranchId.Free;
    end;
  end;
end;

procedure TfrmFinChequeNote.RefreshData;
begin
  inherited;
  cbbDocKind.ItemIndex := Table.DocKind - 1;
  cbbDirection.ItemIndex := Table.Direction - 1;
  edtPortfolioNo.Text := Table.PortfolioNo;
  edtSerialNo.Text := Table.SerialNo;
  if Table.IssueDate > 0 then
    edtIssueDate.Text := DateToStr(Table.IssueDate)
  else
    edtIssueDate.Text := '';
  if Table.DueDate > 0 then
    edtDueDate.Text := DateToStr(Table.DueDate)
  else
    edtDueDate.Text := '';
  edtAmount.Text := CurrToStr(Table.Amount);
  edtCurrency.Text := Table.Currency;
  edtAccAccountId.Text := Table.AccountName;
  edtStatusText.Text := TFinLookup.Text(flkChequeStatus, Table.Status);
  edtDrawerName.Text := Table.DrawerName;
  edtDrawerTaxNo.Text := Table.DrawerTaxNo;
  edtIssuePlace.Text := Table.IssuePlace;
  edtAccBankId.Text := Table.BankName;
  edtAccBankBranchId.Text := Table.BranchName;
  edtBankAccountNo.Text := Table.BankAccountNo;
  edtGuarantorName.Text := Table.GuarantorName;
  mmoNotes.Text := Table.Notes;
end;

end.
