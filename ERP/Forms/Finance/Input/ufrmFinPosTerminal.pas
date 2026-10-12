unit ufrmFinPosTerminal;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  FinPosTerminal.Service, FinPosTerminal;

type
  TfrmFinPosTerminal = class(TfrmInputSimpleDB<TFinPosTerminal, TFinPosTerminalService>)
    pnlContent: TPanel;
    lblPosName: TLabel;
    edtPosName: TEdit;
    lblAccBankId: TLabel;
    edtAccBankId: TEdit;
    lblTerminalNo: TLabel;
    edtTerminalNo: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    lblCommissionRate: TLabel;
    edtCommissionRate: TEdit;
    lblBlockedDays: TLabel;
    edtBlockedDays: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblAccAccountCode: TLabel;
    edtAccAccountCode: TEdit;
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
  AccBank, AccBank.Service, ufrmAccBanks,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies,
  AccAccount, AccAccount.Service, ufrmAccAccounts;

procedure TfrmFinPosTerminal.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.PosName := edtPosName.Text;
  Table.TerminalNo := edtTerminalNo.Text;
  Table.IsActive := chkIsActive.Checked;
  Table.CommissionRate := StrToCurrDef(edtCommissionRate.Text, 0);
  Table.BlockedDays := StrToIntDef(edtBlockedDays.Text, 0);
  Table.Notes := mmoNotes.Text;
  inherited;
end;

procedure TfrmFinPosTerminal.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPosName.thsInputDataType := itString;
  edtAccBankId.OnHelperProcess := HelperProcess;
  edtTerminalNo.thsInputDataType := itString;
  edtCommissionRate.thsInputDataType := itFloat;
  edtBlockedDays.thsInputDataType := itInteger;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtAccAccountCode.OnHelperProcess := HelperProcess;
end;

procedure TfrmFinPosTerminal.FormShow(Sender: TObject);
begin
  inherited;
  if edtPosName.CanFocus then
    edtPosName.SetFocus;
end;

procedure TfrmFinPosTerminal.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.TitleSingular, 'POS Terminal');
  lblPosName.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColPosName, 'POS Name');
  lblAccBankId.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColAccBankId, 'Bank');
  lblTerminalNo.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColTerminalNo, 'Terminal No');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColIsActive, 'Active');
  lblCommissionRate.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColCommissionRate, 'Commission Rate (%)');
  lblBlockedDays.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColBlockedDays, 'Blocked Days');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColCurrency, 'Currency');
  lblAccAccountCode.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColAccAccountCode, 'Accounting Account');
  lblNotes.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTerminal.ColNotes, 'Notes');
end;

procedure TfrmFinPosTerminal.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccBankId: TfrmAccBanks;
  LFrmCurrency: TfrmSysCurrencies;
  LFrmAccAccountCode: TfrmAccAccounts;
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
  end;
end;

procedure TfrmFinPosTerminal.RefreshData;
begin
  inherited;
  edtPosName.Text := Table.PosName;
  edtAccBankId.Text := Table.BankName;
  edtTerminalNo.Text := Table.TerminalNo;
  chkIsActive.Checked := Table.IsActive;
  edtCommissionRate.Text := CurrToStr(Table.CommissionRate);
  edtBlockedDays.Text := IntToStr(Table.BlockedDays);
  edtCurrency.Text := Table.Currency;
  edtAccAccountCode.Text := Table.AccAccountCode;
  mmoNotes.Text := Table.Notes;
end;

end.
