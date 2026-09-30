unit ufrmAccAccount;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccAccount.Service, AccAccount;

type
  TfrmAccAccount = class(TfrmInputSimpleDB<TAccAccount, TAccAccountService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblAccSetAccountTypeId: TLabel;
    edtAccSetAccountTypeId: TEdit;
    lblAccGroupId: TLabel;
    edtAccGroupId: TEdit;
    lblAccRegionId: TLabel;
    edtAccRegionId: TEdit;
    lblRootCode: TLabel;
    edtRootCode: TEdit;
    lblSubCode: TLabel;
    edtSubCode: TEdit;
    lblIban: TLabel;
    edtIban: TEdit;
    lblIbanCurrency: TLabel;
    edtIbanCurrency: TEdit;
    lblDiscountRate: TLabel;
    edtDiscountRate: TEdit;
    lblEInvoiceActive: TLabel;
    chkEInvoiceActive: TCheckBox;
    lblEInvoicePackageName: TLabel;
    edtEInvoicePackageName: TEdit;
    lblIsPassive: TLabel;
    chkIsPassive: TCheckBox;
    lblNotes: TLabel;
    edtNotes: TEdit;
    lblTaxpayerType: TLabel;
    cbbTaxpayerType: TComboBox;
    lblTaxpayerName: TLabel;
    edtTaxpayerName: TEdit;
    lblTaxpayerName2: TLabel;
    edtTaxpayerName2: TEdit;
    lblTaxpayerSurname: TLabel;
    edtTaxpayerSurname: TEdit;
    lblTaxOffice: TLabel;
    edtTaxOffice: TEdit;
    lblTaxNo: TLabel;
    edtTaxNo: TEdit;
    lblNaceCode: TLabel;
    edtNaceCode: TEdit;
    lblAuthorizedPerson1: TLabel;
    edtAuthorizedPerson1: TEdit;
    lblAuthorizedPhone1: TLabel;
    edtAuthorizedPhone1: TEdit;
    lblAuthorizedPerson2: TLabel;
    edtAuthorizedPerson2: TEdit;
    lblAuthorizedPhone2: TLabel;
    edtAuthorizedPhone2: TEdit;
    lblAuthorizedPerson3: TLabel;
    edtAuthorizedPerson3: TEdit;
    lblAuthorizedPhone3: TLabel;
    edtAuthorizedPhone3: TEdit;
    lblFax: TLabel;
    edtFax: TEdit;
    lblAccountantPhone: TLabel;
    edtAccountantPhone: TEdit;
    lblAccountantEmail: TLabel;
    edtAccountantEmail: TEdit;
    lblAccountantAuthorized: TLabel;
    edtAccountantAuthorized: TEdit;
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
  AccLookup,
  AccSetAccountType, AccSetAccountType.Service, ufrmAccSetAccountTypes,         // TfrmAccSetAccountTypes helper output form
  AccGroup, AccGroup.Service, ufrmAccGroups,                                    // TfrmAccGroups helper output form
  AccRegion, AccRegion.Service, ufrmAccRegions,                                 // TfrmAccRegions helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;                          // TfrmSysCurrencies helper output form

procedure TfrmAccAccount.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.Iban := edtIban.Text;
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.EInvoiceActive := chkEInvoiceActive.Checked;
  Table.EInvoicePackageName := edtEInvoicePackageName.Text;
  Table.IsPassive := chkIsPassive.Checked;
  Table.Notes := edtNotes.Text;
  Table.TaxpayerType := cbbTaxpayerType.ItemIndex + 1;  // seçim yoksa 0 -> zorunluluk kontrolü
  Table.TaxpayerName := edtTaxpayerName.Text;
  Table.TaxpayerName2 := edtTaxpayerName2.Text;
  Table.TaxpayerSurname := edtTaxpayerSurname.Text;
  Table.TaxOffice := edtTaxOffice.Text;
  Table.TaxNo := edtTaxNo.Text;
  Table.NaceCode := edtNaceCode.Text;
  Table.AuthorizedPerson1 := edtAuthorizedPerson1.Text;
  Table.AuthorizedPhone1 := edtAuthorizedPhone1.Text;
  Table.AuthorizedPerson2 := edtAuthorizedPerson2.Text;
  Table.AuthorizedPhone2 := edtAuthorizedPhone2.Text;
  Table.AuthorizedPerson3 := edtAuthorizedPerson3.Text;
  Table.AuthorizedPhone3 := edtAuthorizedPhone3.Text;
  Table.Fax := edtFax.Text;
  Table.AccountantPhone := edtAccountantPhone.Text;
  Table.AccountantEmail := edtAccountantEmail.Text;
  Table.AccountantAuthorized := edtAccountantAuthorized.Text;
  inherited;
end;

procedure TfrmAccAccount.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtAccSetAccountTypeId.OnHelperProcess := HelperProcess;
  edtAccGroupId.OnHelperProcess := HelperProcess;
  edtAccRegionId.OnHelperProcess := HelperProcess;
  edtIbanCurrency.OnHelperProcess := HelperProcess;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  edtName.CharCase := TEditCharCase.ecUpperCase;
  edtRootCode.thsInputDataType := itString;
  edtSubCode.thsInputDataType := itString;
  edtIban.thsInputDataType := itString;
  edtIban.CharCase := TEditCharCase.ecUpperCase;
  edtDiscountRate.thsInputDataType := itFloat;
  edtEInvoicePackageName.thsInputDataType := itString;
  edtNotes.thsInputDataType := itString;
  TAccLookup.FillItems(cbbTaxpayerType.Items, alkTaxpayerType);
  edtTaxpayerName.thsInputDataType := itString;
  edtTaxpayerName2.thsInputDataType := itString;
  edtTaxpayerSurname.thsInputDataType := itString;
  edtTaxOffice.thsInputDataType := itString;
  edtTaxNo.thsInputDataType := itString;
  edtNaceCode.thsInputDataType := itString;
  edtAuthorizedPerson1.thsInputDataType := itString;
  edtAuthorizedPhone1.thsInputDataType := itString;
  edtAuthorizedPerson2.thsInputDataType := itString;
  edtAuthorizedPhone2.thsInputDataType := itString;
  edtAuthorizedPerson3.thsInputDataType := itString;
  edtAuthorizedPhone3.thsInputDataType := itString;
  edtFax.thsInputDataType := itString;
  edtAccountantPhone.thsInputDataType := itString;
  edtAccountantEmail.thsInputDataType := itString;
  edtAccountantAuthorized.thsInputDataType := itString;
end;

procedure TfrmAccAccount.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmAccAccount.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.TitleSingular, 'Account Card');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColCode, 'Account Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColName, 'Account Name');
  lblAccSetAccountTypeId.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAccountType, 'Account Type');
  lblAccGroupId.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColGroup, 'Group');
  lblAccRegionId.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColRegion, 'Region');
  lblRootCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColRootCode, 'Root Code');
  lblSubCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColSubCode, 'Parent Code');
  lblIban.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColIban, 'IBAN');
  lblIbanCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColIbanCurrency, 'IBAN Currency');
  lblDiscountRate.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColDiscountRate, 'Discount Rate');
  lblEInvoiceActive.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEInvoiceActive, 'E-Invoice Active');
  lblEInvoicePackageName.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEInvoicePackageName, 'E-Invoice Package');
  lblIsPassive.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColIsPassive, 'Passive');
  lblNotes.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColNotes, 'Notes');
  lblTaxpayerType.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxpayerType, 'Taxpayer Type');
  lblTaxpayerName.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxpayerName, 'Taxpayer Name');
  lblTaxpayerName2.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxpayerName2, 'Taxpayer Name 2');
  lblTaxpayerSurname.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxpayerSurname, 'Taxpayer Surname');
  lblTaxOffice.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxOffice, 'Tax Office');
  lblTaxNo.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxNo, 'Tax No');
  lblNaceCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColNaceCode, 'NACE Code');
  lblAuthorizedPerson1.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPerson1, 'Contact Person 1');
  lblAuthorizedPhone1.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPhone1, 'Contact Phone 1');
  lblAuthorizedPerson2.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPerson2, 'Contact Person 2');
  lblAuthorizedPhone2.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPhone2, 'Contact Phone 2');
  lblAuthorizedPerson3.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPerson3, 'Contact Person 3');
  lblAuthorizedPhone3.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAuthorizedPhone3, 'Contact Phone 3');
  lblFax.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColFax, 'Fax');
  lblAccountantPhone.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAccountantPhone, 'Accountant Phone');
  lblAccountantEmail.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAccountantEmail, 'Accountant E-Mail');
  lblAccountantAuthorized.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColAccountantAuthorized, 'Accountant Contact');
  LIndex := cbbTaxpayerType.ItemIndex;
  TAccLookup.FillItems(cbbTaxpayerType.Items, alkTaxpayerType);
  cbbTaxpayerType.ItemIndex := LIndex;
end;

procedure TfrmAccAccount.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccSetAccountTypeId: TfrmAccSetAccountTypes;
  LFrmAccGroupId: TfrmAccGroups;
  LFrmAccRegionId: TfrmAccRegions;
  LFrmIbanCurrency: TfrmSysCurrencies;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccSetAccountTypeId.Name then
  begin
    LFrmAccSetAccountTypeId := TfrmAccSetAccountTypes.Create(LEdit, TAccSetAccountTypeService.Create, TAccSetAccountType.Create);
    try
      LFrmAccSetAccountTypeId.IsHelper := True;
      LFrmAccSetAccountTypeId.ShowModal;
      if LFrmAccSetAccountTypeId.DataTransfer then
        if LFrmAccSetAccountTypeId.CleanAndClose then
        begin
          Table.AccSetAccountTypeId := 0;
          Table.AccountTypeName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccSetAccountTypeId := LFrmAccSetAccountTypeId.Table.Id;
          Table.AccountTypeName := LFrmAccSetAccountTypeId.Table.AccountTypeName;
          LEdit.Text := Table.AccountTypeName;
        end;
    finally
      LFrmAccSetAccountTypeId.Free;
    end;
  end
  else if LEdit.Name = edtAccGroupId.Name then
  begin
    LFrmAccGroupId := TfrmAccGroups.Create(LEdit, TAccGroupService.Create, TAccGroup.Create);
    try
      LFrmAccGroupId.IsHelper := True;
      LFrmAccGroupId.ShowModal;
      if LFrmAccGroupId.DataTransfer then
        if LFrmAccGroupId.CleanAndClose then
        begin
          Table.AccGroupId := 0;
          Table.GroupName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccGroupId := LFrmAccGroupId.Table.Id;
          Table.GroupName := LFrmAccGroupId.Table.Name;
          LEdit.Text := Table.GroupName;
        end;
    finally
      LFrmAccGroupId.Free;
    end;
  end
  else if LEdit.Name = edtAccRegionId.Name then
  begin
    LFrmAccRegionId := TfrmAccRegions.Create(LEdit, TAccRegionService.Create, TAccRegion.Create);
    try
      LFrmAccRegionId.IsHelper := True;
      LFrmAccRegionId.ShowModal;
      if LFrmAccRegionId.DataTransfer then
        if LFrmAccRegionId.CleanAndClose then
        begin
          Table.AccRegionId := 0;
          Table.RegionName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccRegionId := LFrmAccRegionId.Table.Id;
          Table.RegionName := LFrmAccRegionId.Table.Name;
          LEdit.Text := Table.RegionName;
        end;
    finally
      LFrmAccRegionId.Free;
    end;
  end
  else if LEdit.Name = edtIbanCurrency.Name then
  begin
    LFrmIbanCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmIbanCurrency.IsHelper := True;
      LFrmIbanCurrency.ShowModal;
      if LFrmIbanCurrency.DataTransfer then
        if LFrmIbanCurrency.CleanAndClose then
        begin
          Table.IbanCurrency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.IbanCurrency := LFrmIbanCurrency.Table.Currency;
          LEdit.Text := Table.IbanCurrency;
        end;
    finally
      LFrmIbanCurrency.Free;
    end;
  end;
end;

procedure TfrmAccAccount.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  edtAccSetAccountTypeId.Text := Table.AccountTypeName;
  edtAccGroupId.Text := Table.GroupName;
  edtAccRegionId.Text := Table.RegionName;
  edtRootCode.Text := Table.RootCode;
  edtSubCode.Text := Table.SubCode;
  edtIban.Text := Table.Iban;
  edtIbanCurrency.Text := Table.IbanCurrency;
  edtDiscountRate.Text := CurrToStr(Table.DiscountRate);
  chkEInvoiceActive.Checked := Table.EInvoiceActive;
  edtEInvoicePackageName.Text := Table.EInvoicePackageName;
  chkIsPassive.Checked := Table.IsPassive;
  edtNotes.Text := Table.Notes;
  cbbTaxpayerType.ItemIndex := Table.TaxpayerType - 1;
  edtTaxpayerName.Text := Table.TaxpayerName;
  edtTaxpayerName2.Text := Table.TaxpayerName2;
  edtTaxpayerSurname.Text := Table.TaxpayerSurname;
  edtTaxOffice.Text := Table.TaxOffice;
  edtTaxNo.Text := Table.TaxNo;
  edtNaceCode.Text := Table.NaceCode;
  edtAuthorizedPerson1.Text := Table.AuthorizedPerson1;
  edtAuthorizedPhone1.Text := Table.AuthorizedPhone1;
  edtAuthorizedPerson2.Text := Table.AuthorizedPerson2;
  edtAuthorizedPhone2.Text := Table.AuthorizedPhone2;
  edtAuthorizedPerson3.Text := Table.AuthorizedPerson3;
  edtAuthorizedPhone3.Text := Table.AuthorizedPhone3;
  edtFax.Text := Table.Fax;
  edtAccountantPhone.Text := Table.AccountantPhone;
  edtAccountantEmail.Text := Table.AccountantEmail;
  edtAccountantAuthorized.Text := Table.AccountantAuthorized;
end;

end.
