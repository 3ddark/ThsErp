unit ufrmFinCompanyBankAccount;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  FinCompanyBankAccount.Service, FinCompanyBankAccount;

type
  TfrmFinCompanyBankAccount = class(TfrmInputSimpleDB<TFinCompanyBankAccount, TFinCompanyBankAccountService>)
    pnlContent: TPanel;
    lblAccBankId: TLabel;
    edtAccBankId: TEdit;
    lblBranchCode: TLabel;
    edtBranchCode: TEdit;
    lblBranchName: TLabel;
    edtBranchName: TEdit;
    lblSysCityId: TLabel;
    edtSysCityId: TEdit;
    lblAccountNo: TLabel;
    edtAccountNo: TEdit;
    lblIban: TLabel;
    edtIban: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblAccountHolder: TLabel;
    edtAccountHolder: TEdit;
    lblShowOnCheque: TLabel;
    chkShowOnCheque: TCheckBox;
    lblShowOnNote: TLabel;
    chkShowOnNote: TCheckBox;
    lblShowOnPrint: TLabel;
    chkShowOnPrint: TCheckBox;
    lblSortOrder: TLabel;
    edtSortOrder: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    lblDescription: TLabel;
    edtDescription: TEdit;
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
  AccBank, AccBank.Service, ufrmAccBanks,
  SysCity, SysCity.Service, ufrmSysCities,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;

procedure TfrmFinCompanyBankAccount.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.BranchCode := edtBranchCode.Text;
  Table.BranchName := edtBranchName.Text;
  Table.AccountNo := edtAccountNo.Text;
  Table.Iban := edtIban.Text;
  Table.AccountHolder := edtAccountHolder.Text;
  Table.ShowOnCheque := chkShowOnCheque.Checked;
  Table.ShowOnNote := chkShowOnNote.Checked;
  Table.ShowOnPrint := chkShowOnPrint.Checked;
  Table.SortOrder := StrToIntDef(edtSortOrder.Text, 0);
  Table.IsActive := chkIsActive.Checked;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmFinCompanyBankAccount.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtAccBankId.OnHelperProcess := HelperProcess;
  edtBranchCode.thsInputDataType := itString;
  edtBranchCode.CharCase := TEditCharCase.ecUpperCase;
  edtBranchName.thsInputDataType := itString;
  edtSysCityId.OnHelperProcess := HelperProcess;
  edtAccountNo.thsInputDataType := itString;
  edtIban.thsInputDataType := itString;
  edtIban.CharCase := TEditCharCase.ecUpperCase;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtAccountHolder.thsInputDataType := itString;
  edtSortOrder.thsInputDataType := itInteger;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmFinCompanyBankAccount.FormShow(Sender: TObject);
begin
  inherited;
  if edtBranchCode.CanFocus then
    edtBranchCode.SetFocus;
end;

procedure TfrmFinCompanyBankAccount.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.TitleSingular, 'Company Bank Account');
  lblAccBankId.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColAccBankId, 'Bank');
  lblBranchCode.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColBranchCode, 'Branch Code');
  lblBranchName.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColBranchName, 'Branch Name');
  lblSysCityId.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColSysCityId, 'Branch City');
  lblAccountNo.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColAccountNo, 'Account No');
  lblIban.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColIban, 'IBAN');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColCurrency, 'Currency');
  lblAccountHolder.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColAccountHolder, 'Account Holder');
  lblShowOnCheque.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColShowOnCheque, 'Show on Cheques');
  lblShowOnNote.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColShowOnNote, 'Show on Promissory Notes');
  lblShowOnPrint.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColShowOnPrint, 'Show on Printouts');
  lblSortOrder.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColSortOrder, 'Sort Order');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColIsActive, 'Active');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.ColDescription, 'Description');
end;

procedure TfrmFinCompanyBankAccount.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccBankId: TfrmAccBanks;
  LFrmSysCityId: TfrmSysCities;
  LFrmCurrency: TfrmSysCurrencies;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccBankId.Name then
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
          LEdit.Clear;
        end
        else
        begin
          Table.AccBankId := LFrmAccBankId.Table.Id;
          Table.BankName := LFrmAccBankId.Table.BankName;
          LEdit.Text := Table.BankName;
        end;
    finally
      LFrmAccBankId.Free;
    end;
  end
  else if LEdit.Name = edtSysCityId.Name then
  begin
    LFrmSysCityId := TfrmSysCities.Create(LEdit, TSysCityService.Create, TSysCity.Create);
    try
      LFrmSysCityId.IsHelper := True;
      LFrmSysCityId.ShowModal;
      if LFrmSysCityId.DataTransfer then
        if LFrmSysCityId.CleanAndClose then
        begin
          Table.SysCityId := 0;
          Table.CityName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SysCityId := LFrmSysCityId.Table.Id;
          Table.CityName := LFrmSysCityId.Table.CityName;
          LEdit.Text := Table.CityName;
        end;
    finally
      LFrmSysCityId.Free;
    end;
  end
  else if LEdit.Name = edtCurrency.Name then
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

procedure TfrmFinCompanyBankAccount.RefreshData;
begin
  inherited;
  edtAccBankId.Text := Table.BankName;
  edtBranchCode.Text := Table.BranchCode;
  edtBranchName.Text := Table.BranchName;
  edtSysCityId.Text := Table.CityName;
  edtAccountNo.Text := Table.AccountNo;
  edtIban.Text := Table.Iban;
  edtCurrency.Text := Table.Currency;
  edtAccountHolder.Text := Table.AccountHolder;
  chkShowOnCheque.Checked := Table.ShowOnCheque;
  chkShowOnNote.Checked := Table.ShowOnNote;
  chkShowOnPrint.Checked := Table.ShowOnPrint;
  edtSortOrder.Text := IntToStr(Table.SortOrder);
  chkIsActive.Checked := Table.IsActive;
  edtDescription.Text := Table.Description;
end;

end.
