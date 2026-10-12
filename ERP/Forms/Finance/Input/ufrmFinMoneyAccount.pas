unit ufrmFinMoneyAccount;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  FinMoneyAccount.Service, FinMoneyAccount;

type
  TfrmFinMoneyAccount = class(TfrmInputSimpleDB<TFinMoneyAccount, TFinMoneyAccountService>)
    pnlContent: TPanel;
    lblAccountKind: TLabel;
    cbbAccountKind: TComboBox;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblAccAccountCode: TLabel;
    edtAccAccountCode: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    lblAccBankId: TLabel;
    edtAccBankId: TEdit;
    lblAccBankBranchId: TLabel;
    edtAccBankBranchId: TEdit;
    lblAccountNo: TLabel;
    edtAccountNo: TEdit;
    lblIban: TLabel;
    edtIban: TEdit;
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

procedure TfrmFinMoneyAccount.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.AccountKind := cbbAccountKind.ItemIndex + 1;
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.IsActive := chkIsActive.Checked;
  Table.AccountNo := edtAccountNo.Text;
  Table.Iban := edtIban.Text;
  Table.Notes := mmoNotes.Text;
  inherited;
end;

procedure TfrmFinMoneyAccount.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  TFinLookup.FillItems(cbbAccountKind.Items, flkMoneyAccountKind);
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtAccAccountCode.OnHelperProcess := HelperProcess;
  edtAccBankId.OnHelperProcess := HelperProcess;
  edtAccBankBranchId.OnHelperProcess := HelperProcess;
  edtAccountNo.thsInputDataType := itString;
  edtIban.thsInputDataType := itString;
  edtIban.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmFinMoneyAccount.FormShow(Sender: TObject);
begin
  inherited;
  if cbbAccountKind.CanFocus then
    cbbAccountKind.SetFocus;
end;

procedure TfrmFinMoneyAccount.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.TitleSingular, 'Cash / Bank Account');
  lblAccountKind.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColAccountKind, 'Account Kind');
  LIndex := cbbAccountKind.ItemIndex;
  TFinLookup.FillItems(cbbAccountKind.Items, flkMoneyAccountKind);
  cbbAccountKind.ItemIndex := LIndex;
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColCode, 'Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColName, 'Name');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColCurrency, 'Currency');
  lblAccAccountCode.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColAccAccountCode, 'Accounting Account');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColIsActive, 'Active');
  lblAccBankId.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColAccBankId, 'Bank');
  lblAccBankBranchId.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColAccBankBranchId, 'Bank Branch');
  lblAccountNo.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColAccountNo, 'Account No');
  lblIban.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColIban, 'IBAN');
  lblNotes.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.ColNotes, 'Notes');
end;

procedure TfrmFinMoneyAccount.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmCurrency: TfrmSysCurrencies;
  LFrmAccAccountCode: TfrmAccAccounts;
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
  else if LEdit.Name = edtAccAccountCode.Name then
  begin
    LFrmAccAccountCode := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmAccAccountCode.IsHelper := True;
      LFrmAccAccountCode.ShowModal;
      if LFrmAccAccountCode.DataTransfer then
        if LFrmAccAccountCode.CleanAndClose then
        begin
          Table.AccAccountCode := '';
          Table.AccountName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccAccountCode := LFrmAccAccountCode.Table.Code;
          Table.AccountName := LFrmAccAccountCode.Table.Name;
          LEdit.Text := Table.AccAccountCode;
        end;
    finally
      LFrmAccAccountCode.Free;
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

procedure TfrmFinMoneyAccount.RefreshData;
begin
  inherited;
  cbbAccountKind.ItemIndex := Table.AccountKind - 1;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  edtCurrency.Text := Table.Currency;
  edtAccAccountCode.Text := Table.AccAccountCode;
  chkIsActive.Checked := Table.IsActive;
  edtAccBankId.Text := Table.BankName;
  edtAccBankBranchId.Text := Table.BranchName;
  edtAccountNo.Text := Table.AccountNo;
  edtIban.Text := Table.Iban;
  mmoNotes.Text := Table.Notes;
end;

end.
