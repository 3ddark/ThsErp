unit ufrmAccVoucherLine;

// Fiş kalemi satır formu (TfrmAccVoucherDetail'den modal): bellekteki satırı düzenler, DB'ye fişle birlikte yazılır.
// Hesap yalnız hareket gören (SON) hesaplardan seçilir; borç ya da alacak girilir (biri girilince diğeri sıfırlanır).

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  AccVoucherDetail.Service, AccVoucherDetail;

type
  TfrmAccVoucherLine = class(TfrmInputLineDB<TAccVoucherDetail, TAccVoucherDetailService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblDebit: TLabel;
    edtDebit: TEdit;
    lblCredit: TLabel;
    edtCredit: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    procedure DebitChanged(Sender: TObject);
    procedure CreditChanged(Sender: TObject);
  protected
    procedure PrepareLine; override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache, AccLookup,
  AccAccount, AccAccount.Service, ufrmAccAccounts;   // TfrmAccAccounts helper output form

procedure TfrmAccVoucherLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; fiş (acc_voucher_id) ana formdan gelir
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Description := edtDescription.Text;
  Table.Debit := StrToCurrDef(edtDebit.Text, 0);
  Table.Credit := StrToCurrDef(edtCredit.Text, 0);
  inherited;
end;

// Kabul: alan kontrolleri (servisin belge kaydıyla aynı kurallar); SON hesap kuralı kayıtta denetlenir
procedure TfrmAccVoucherLine.PrepareLine;
begin
  inherited;
  TAccVoucherDetailService.CheckLine(Table);
end;

procedure TfrmAccVoucherLine.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtDescription.thsInputDataType := itString;
  edtDebit.thsInputDataType := itFloat;
  edtDebit.thsDecimalDigitCount := TDecimalPlaces.Total;
  edtCredit.thsInputDataType := itFloat;
  edtCredit.thsDecimalDigitCount := TDecimalPlaces.Total;
  edtDebit.OnChange := DebitChanged;
  edtCredit.OnChange := CreditChanged;
end;

procedure TfrmAccVoucherLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtAccAccountId.CanFocus then
    edtAccAccountId.SetFocus;
end;

// Borç ya da alacak: biri girilince diğeri boşalır
procedure TfrmAccVoucherLine.DebitChanged(Sender: TObject);
begin
  if (StrToCurrDef(edtDebit.Text, 0) <> 0) and (edtCredit.Text <> '') then
    edtCredit.Text := '';
end;

procedure TfrmAccVoucherLine.CreditChanged(Sender: TObject);
begin
  if (StrToCurrDef(edtCredit.Text, 0) <> 0) and (edtDebit.Text <> '') then
    edtDebit.Text := '';
end;

procedure TfrmAccVoucherLine.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.TitleSingular, 'Voucher Line');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColLineNo, 'Line No');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColAccAccountId, 'Account');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColDescription, 'Description');
  lblDebit.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColDebit, 'Debit');
  lblCredit.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColCredit, 'Credit');
end;

procedure TfrmAccVoucherLine.HelperProcess(Sender: TObject);
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
      // yalnız hareket gören (SON) hesaplar
      LFrmAccAccountId.SetFixedAccountType(ACC_ACCOUNT_TYPE_DETAIL, '');
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
          LEdit.Text := Table.AccountCode + ' ' + Table.AccountName;
        end;
    finally
      LFrmAccAccountId.Free;
    end;
  end;
end;

procedure TfrmAccVoucherLine.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  if Table.AccAccountId > 0 then
    edtAccAccountId.Text := Table.AccountCode + ' ' + Table.AccountName
  else
    edtAccAccountId.Text := '';
  edtDescription.Text := Table.Description;
  if Table.Debit <> 0 then
    edtDebit.Text := CurrToStr(Table.Debit)
  else
    edtDebit.Text := '';
  if Table.Credit <> 0 then
    edtCredit.Text := CurrToStr(Table.Credit)
  else
    edtCredit.Text := '';
end;

end.
