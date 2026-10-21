unit ufrmAccAccount;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox, Detail.Address,
  AccAccount.Service, AccAccount;

type
  TfrmAccAccount = class(TfrmInputSimpleDB<TAccAccount, TAccAccountService>)
    pnlContent: TPanel;
    pgcMain: TPageControl;
    tsGeneral: TTabSheet;
    lblCode: TLabel;
    cbbCode: TComboBox;
    lblName: TLabel;
    edtName: TEdit;
    lblAccGroupId: TLabel;
    edtAccGroupId: TEdit;
    lblAccRegionId: TLabel;
    edtAccRegionId: TEdit;
    lblRootCode: TLabel;
    cbbRootCode: TComboBox;
    lblSubCode: TLabel;
    cbbSubCode: TComboBox;
    lblIban: TLabel;
    edtIban: TEdit;
    edtIbanCurrency: TEdit;
    lblDiscountRate: TLabel;
    edtDiscountRate: TEdit;
    lblEInvoiceActive: TLabel;
    chkEInvoiceActive: TCheckBox;
    chkEDespatchActive: TCheckBox;
    lblEInvoicePkAlias: TLabel;
    edtEInvoicePkAlias: TEdit;
    lblEInvoiceGbAlias: TLabel;
    edtEInvoiceGbAlias: TEdit;
    lblEDespatchPkAlias: TLabel;
    edtEDespatchPkAlias: TEdit;
    lblEDespatchGbAlias: TLabel;
    edtEDespatchGbAlias: TEdit;
    btnQueryTaxpayer: TButton;
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
    tsTaxpayer: TTabSheet;
    tsContact: TTabSheet;
    tsBillingAddress: TTabSheet;
    tsShippingAddress: TTabSheet;
    tsLegalAddress: TTabSheet;
    tsOtherAddress: TTabSheet;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    // Table.Addresses sırasıyla (ACC_ADDRESS_TYPES): fatura, sevk, yasal, diğer
    FAddressEditors: array[0..3] of TDocumentAddressEditor;
    FAddressTabs: array[0..3] of TTabSheet;
    procedure FreeAddressEditors;
    procedure AddressFromBilling(Sender: TObject);
    procedure FillTaxpayerTypes;
    procedure cbbTaxpayerTypeChange(Sender: TObject);
    procedure ApplyTaxpayerType;
    procedure chkEDocumentActiveClick(Sender: TObject);
    procedure btnQueryTaxpayerClick(Sender: TObject);
    procedure ApplyAliasState;
  private
    FCodeLoading: Boolean;
    procedure LoadCodeSelection;
    procedure FillParentCombo(ACombo: TComboBox; const AParentCode, ASelectCode: string);
    procedure FillCodeCombo(const ASelectCode: string; AKeepCurrent: Boolean);
    function SelectedParentCode: string;
    procedure cbbRootCodeChange(Sender: TObject);
    procedure cbbSubCodeChange(Sender: TObject);
  public
    destructor Destroy; override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  AccLookup, AccAccountAddress, EInvIntegrator, EInvDocument.Service, Ths.DialogHelper,
  AccGroup, AccGroup.Service, ufrmAccGroups,                                    // TfrmAccGroups helper output form
  AccRegion, AccRegion.Service, ufrmAccRegions,                                 // TfrmAccRegions helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies;                          // TfrmSysCurrencies helper output form

procedure TfrmAccAccount.BtnAcceptClick(Sender: TObject);
var
  LIndex: Integer;
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := cbbCode.Text;
  Table.Name := edtName.Text;
  Table.Iban := edtIban.Text;
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.EInvoiceActive := chkEInvoiceActive.Checked;
  Table.EDespatchActive := chkEDespatchActive.Checked;
  Table.EInvoicePkAlias := edtEInvoicePkAlias.Text;
  Table.EInvoiceGbAlias := edtEInvoiceGbAlias.Text;
  Table.EDespatchPkAlias := edtEDespatchPkAlias.Text;
  Table.EDespatchGbAlias := edtEDespatchGbAlias.Text;
  Table.IsPassive := chkIsPassive.Checked;
  Table.Notes := edtNotes.Text;
  // ilk satır boş = mükellef değil (0 -> NULL); 1 tüzel, 2 gerçek kişi
  if cbbTaxpayerType.ItemIndex > 0 then
    Table.TaxpayerType := cbbTaxpayerType.ItemIndex
  else
    Table.TaxpayerType := 0;
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
  // adresler hesapla aynı transaction'da kaydedilir (servis yalnız değişenleri yazar)
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    for LIndex := 0 to Table.Addresses.Count - 1 do
      FAddressEditors[LIndex].SaveTo(Table.Addresses[LIndex].Address);
    Table.AddressesAssigned := True;
  end;
  inherited;
end;

destructor TfrmAccAccount.Destroy;
begin
  FreeAddressEditors;
  inherited;
end;

// Düzenleyici sınıflar (kontroller forma ait, formla birlikte yok olur)
procedure TfrmAccAccount.FreeAddressEditors;
var
  LIndex: Integer;
begin
  for LIndex := Low(FAddressEditors) to High(FAddressEditors) do
    FreeAndNil(FAddressEditors[LIndex]);
end;

procedure TfrmAccAccount.FormCreate(Sender: TObject);
var
  LIndex: Integer;
begin
  inherited;
  pnlContent.Parent := PanelMain;
  pgcMain.ActivePage := tsGeneral;
  FAddressTabs[0] := tsBillingAddress;
  FAddressTabs[1] := tsShippingAddress;
  FAddressTabs[2] := tsLegalAddress;
  FAddressTabs[3] := tsOtherAddress;
  // fatura dışındaki adresler ekrandaki fatura adresinden doldurulabilir
  FAddressEditors[0] := TDocumentAddressEditor.Create(Self, FAddressTabs[0], [aeoContact]);
  for LIndex := 1 to High(FAddressEditors) do
  begin
    FAddressEditors[LIndex] := TDocumentAddressEditor.Create(Self, FAddressTabs[LIndex], [aeoContact, aeoFromBilling]);
    FAddressEditors[LIndex].OnFromBilling := AddressFromBilling;
  end;
  // e-İrsaliye işareti e-Fatura işaretiyle aynı satırda: sekme sırası hemen ardından
  chkEDespatchActive.TabOrder := chkEInvoiceActive.TabOrder + 1;
  edtAccGroupId.OnHelperProcess := HelperProcess;
  edtAccRegionId.OnHelperProcess := HelperProcess;
  edtIbanCurrency.OnHelperProcess := HelperProcess;
  cbbRootCode.OnChange := cbbRootCodeChange;
  cbbSubCode.OnChange := cbbSubCodeChange;
  edtName.thsInputDataType := itString;
  edtName.CharCase := TEditCharCase.ecUpperCase;
  edtIban.thsInputDataType := itString;
  edtIban.CharCase := TEditCharCase.ecUpperCase;
  edtDiscountRate.thsInputDataType := itFloat;
  edtEInvoicePkAlias.thsInputDataType := itString;
  edtEInvoiceGbAlias.thsInputDataType := itString;
  edtEDespatchPkAlias.thsInputDataType := itString;
  edtEDespatchGbAlias.thsInputDataType := itString;
  chkEInvoiceActive.OnClick := chkEDocumentActiveClick;
  chkEDespatchActive.OnClick := chkEDocumentActiveClick;
  btnQueryTaxpayer.OnClick := btnQueryTaxpayerClick;
  edtNotes.thsInputDataType := itString;
  FillTaxpayerTypes;
  cbbTaxpayerType.OnChange := cbbTaxpayerTypeChange;
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
  pgcMain.ActivePage := tsGeneral;
  if cbbRootCode.CanFocus then
    cbbRootCode.SetFocus;
end;

procedure TfrmAccAccount.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.TitleSingular, 'Account Card');
  tsGeneral.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.TabGeneral, 'General');
  tsTaxpayer.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.TabTaxpayer, 'Taxpayer Information');
  tsContact.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.TabContact, 'Contact Information');
  for LIndex := Low(FAddressEditors) to High(FAddressEditors) do
    if Assigned(FAddressEditors[LIndex]) then
    begin
      FAddressTabs[LIndex].Caption := TAccAccountService.AddressTypeCaption(ACC_ADDRESS_TYPES[LIndex]);
      FAddressEditors[LIndex].ApplyLocalization(FAddressTabs[LIndex].Caption);
    end;
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColCode, 'Account Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColName, 'Account Name');
  lblAccGroupId.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColGroup, 'Group');
  lblAccRegionId.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColRegion, 'Region');
  lblRootCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColRootCode, 'Root Code');
  lblSubCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColSubCode, 'Parent Code');
  lblIban.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColIban, 'IBAN');
  lblDiscountRate.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColDiscountRate, 'Discount Rate');
  lblEInvoiceActive.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEInvoiceActive, 'E-Invoice Active');
  chkEDespatchActive.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEDespatchActive, 'e-Despatch Active');
  lblEInvoicePkAlias.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEInvoicePkAlias, 'e-Invoice Mailbox (PK)');
  lblEInvoiceGbAlias.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEInvoiceGbAlias, 'e-Invoice Sender Unit (GB)');
  lblEDespatchPkAlias.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEDespatchPkAlias, 'e-Despatch Mailbox (PK)');
  lblEDespatchGbAlias.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColEDespatchGbAlias, 'e-Despatch Sender Unit (GB)');
  btnQueryTaxpayer.Caption := TLocalizationManager.Translate(TLangKeys.TEInvIntegration.BtnQueryTaxpayer, 'Query GIB');
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
  FillTaxpayerTypes;
  cbbTaxpayerType.ItemIndex := LIndex;
  ApplyTaxpayerType;
end;

// İlk satır boş: mükellef olmayan (muhasebe) hesaplar; sonra AccLookup sırası (ItemIndex = taxpayer_type)
procedure TfrmAccAccount.FillTaxpayerTypes;
begin
  TAccLookup.FillItems(cbbTaxpayerType.Items, alkTaxpayerType);
  cbbTaxpayerType.Items.Insert(0, '');
end;

procedure TfrmAccAccount.cbbTaxpayerTypeChange(Sender: TObject);
begin
  ApplyTaxpayerType;
end;

// Tüzel kişi: vergi dairesi + vergi no (VKN 10 hane) zorunlu. Gerçek kişi: ad, soyad + T.C. kimlik no (vergi no alanı,
// 11 hane) zorunlu, ikinci ad / vergi dairesi isteğe bağlı. Tip yok: mükellef alanları gizli. Görünen satırlar boşluksuz
// dizilir; servis kayıtta aynı kuralı uygular ve tipe ait olmayan alanları boşaltır
procedure TfrmAccAccount.ApplyTaxpayerType;

  procedure ShowField(ALabel: TLabel; AEdit: TEdit; AVisible, ARequired: Boolean);
  begin
    ALabel.Visible := AVisible;
    AEdit.Visible := AVisible;
    AEdit.thsRequiredData := AVisible and ARequired;
    AEdit.Invalidate;
  end;

var
  LType, LTop, I: Integer;
  LLabels: TArray<TLabel>;
  LEdits: TArray<TEdit>;
begin
  LType := cbbTaxpayerType.ItemIndex;
  ShowField(lblTaxpayerName, edtTaxpayerName, LType = ACC_TAXPAYER_REAL, True);
  ShowField(lblTaxpayerName2, edtTaxpayerName2, LType = ACC_TAXPAYER_REAL, False);
  ShowField(lblTaxpayerSurname, edtTaxpayerSurname, LType = ACC_TAXPAYER_REAL, True);
  ShowField(lblTaxOffice, edtTaxOffice, LType in [ACC_TAXPAYER_LEGAL, ACC_TAXPAYER_REAL], LType = ACC_TAXPAYER_LEGAL);
  ShowField(lblTaxNo, edtTaxNo, LType in [ACC_TAXPAYER_LEGAL, ACC_TAXPAYER_REAL], True);
  ShowField(lblNaceCode, edtNaceCode, LType in [ACC_TAXPAYER_LEGAL, ACC_TAXPAYER_REAL], False);
  if LType = ACC_TAXPAYER_REAL then
  begin
    lblTaxNo.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColCitizenNo, 'Citizenship No');
    edtTaxNo.MaxLength := 11;
  end
  else
  begin
    lblTaxNo.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccount.ColTaxNo, 'Tax No');
    edtTaxNo.MaxLength := 10;
  end;

  LLabels := TArray<TLabel>.Create(lblTaxpayerName, lblTaxpayerName2, lblTaxpayerSurname, lblTaxOffice, lblTaxNo, lblNaceCode);
  LEdits := TArray<TEdit>.Create(edtTaxpayerName, edtTaxpayerName2, edtTaxpayerSurname, edtTaxOffice, edtTaxNo, edtNaceCode);
  LTop := cbbTaxpayerType.Top + 23;
  for I := 0 to High(LEdits) do
    if LEdits[I].Visible then
    begin
      LEdits[I].Top := LTop;
      LLabels[I].Top := LTop + 4;
      LEdits[I].TabOrder := I + 1;
      Inc(LTop, 23);
    end;
end;

procedure TfrmAccAccount.chkEDocumentActiveClick(Sender: TObject);
begin
  ApplyAliasState;
end;

// Etiketler yalnız ilgili mükellefiyet işaretliyken girilir (işaretsizse servis kayıtta boşaltır)
procedure TfrmAccAccount.ApplyAliasState;
begin
  lblEInvoicePkAlias.Enabled := chkEInvoiceActive.Checked;
  edtEInvoicePkAlias.Enabled := chkEInvoiceActive.Checked;
  lblEInvoiceGbAlias.Enabled := chkEInvoiceActive.Checked;
  edtEInvoiceGbAlias.Enabled := chkEInvoiceActive.Checked;
  lblEDespatchPkAlias.Enabled := chkEDespatchActive.Checked;
  edtEDespatchPkAlias.Enabled := chkEDespatchActive.Checked;
  lblEDespatchGbAlias.Enabled := chkEDespatchActive.Checked;
  edtEDespatchGbAlias.Enabled := chkEDespatchActive.Checked;
end;

// GİB mükellef sorgusu (vergi no mükellef sekmesinden; e-Fatura entegrasyon servisi): mükellefiyet işaretleri ve ilk PK / GB
// etiketleri ekrana yazılır, kayıt Onayla ile. Birden çok etiket varsa hepsi mesajda listelenir
procedure TfrmAccAccount.btnQueryTaxpayerClick(Sender: TObject);
var
  LSvc: TEInvDocumentService;
  LInfo: TEInvTaxpayerInfo;
  LLines: TStringList;

  function FirstOf(const AItems: TArray<string>): string;
  begin
    if Length(AItems) > 0 then
      Result := AItems[0]
    else
      Result := '';
  end;

  procedure AddLine(ALabel: TLabel; const AItems: TArray<string>);
  begin
    if Length(AItems) > 0 then
      LLines.Add(ALabel.Caption + ': ' + string.Join(', ', AItems));
  end;

begin
  LSvc := TEInvDocumentService.Create;
  try
    Screen.Cursor := crHourGlass;
    try
      LInfo := LSvc.BusinessQueryTaxpayer(edtTaxNo.Text, True);
    finally
      Screen.Cursor := crDefault;
    end;
  finally
    LSvc.Free;
  end;

  if not LInfo.Found or ((Length(LInfo.InvoicePkAliases) = 0) and (Length(LInfo.DespatchPkAliases) = 0)) then
  begin
    TThsDialogHelper.CustomMsgDlg(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.TaxpayerNotFound,
      '%s is not registered at GIB as an e-Invoice / e-Despatch user.'), [LInfo.TaxNo]), mtInformation, [mbOK],
      [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')], mbOK,
      TLocalizationManager.Translate(TLangKeys.TMessage.InformationTitle, 'Information'));
    Exit;
  end;

  chkEInvoiceActive.Checked := Length(LInfo.InvoicePkAliases) > 0;
  chkEDespatchActive.Checked := Length(LInfo.DespatchPkAliases) > 0;
  edtEInvoicePkAlias.Text := FirstOf(LInfo.InvoicePkAliases);
  edtEInvoiceGbAlias.Text := FirstOf(LInfo.InvoiceGbAliases);
  edtEDespatchPkAlias.Text := FirstOf(LInfo.DespatchPkAliases);
  edtEDespatchGbAlias.Text := FirstOf(LInfo.DespatchGbAliases);
  ApplyAliasState;

  LLines := TStringList.Create;
  try
    LLines.Add(Format(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.TaxpayerFound,
      'GIB taxpayer information (%s %s):'), [LInfo.TaxNo, LInfo.Title]));
    AddLine(lblEInvoicePkAlias, LInfo.InvoicePkAliases);
    AddLine(lblEInvoiceGbAlias, LInfo.InvoiceGbAliases);
    AddLine(lblEDespatchPkAlias, LInfo.DespatchPkAliases);
    AddLine(lblEDespatchGbAlias, LInfo.DespatchGbAliases);
    LLines.Add('');
    LLines.Add(TLocalizationManager.Translate(TLangKeys.TEInvIntegration.TaxpayerApplied,
      'The flags and the first aliases were filled in; press Confirm to save.'));
    TThsDialogHelper.CustomMsgDlg(Trim(LLines.Text), mtInformation, [mbOK],
      [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')], mbOK,
      TLocalizationManager.Translate(TLangKeys.TMessage.InformationTitle, 'Information'));
  finally
    LLines.Free;
  end;
end;

// "120-001 - YURTİÇİ ALICILAR" -> "120-001"
function ItemCode(const AText: string): string;
var
  LPos: Integer;
begin
  LPos := Pos(' - ', AText);
  if LPos > 0 then
    Result := Copy(AText, 1, LPos - 1)
  else
    Result := AText;
end;

function ComboCode(ACombo: TComboBox): string;
begin
  if ACombo.ItemIndex < 0 then
    Result := ''
  else
    Result := ItemCode(ACombo.Items[ACombo.ItemIndex]);
end;

// Hesap kodu kademeli seçilir: Ana Kod (birinci seviye) -> Ara Kod (ikinci seviye) -> Hesap Kodu (seçilen üst hesabın
// altında kullanılmayan kodlar, ilki hazır seçili). Listeler serbest yazıma kapalı: biçim dışı kod girilemez. Ana kod boş
// = yeni ana hesap (100-999), ara kod boş = ana kodun altında ara seviye hesap. Listeler tek sorguda satır satır metin gelir
procedure TfrmAccAccount.LoadCodeSelection;
var
  LParts: TArray<string>;
  LRoot, LSub: string;
begin
  LRoot := '';
  LSub := '';
  LParts := Table.Code.Split(['-']);
  if Length(LParts) >= 2 then
    LRoot := LParts[0];
  if Length(LParts) >= 3 then
    LSub := LParts[0] + '-' + LParts[1];
  FCodeLoading := True;
  try
    FillParentCombo(cbbRootCode, '', LRoot);
    FillParentCombo(cbbSubCode, ComboCode(cbbRootCode), LSub);
    FillCodeCombo(Table.Code, True);
  finally
    FCodeLoading := False;
  end;
end;

procedure TfrmAccAccount.FillParentCombo(ACombo: TComboBox; const AParentCode, ASelectCode: string);
var
  I: Integer;
begin
  ACombo.Items.BeginUpdate;
  try
    // ara kod yalnız ana kod seçiliyken listelenir
    if (ACombo = cbbSubCode) and (AParentCode = '') then
      ACombo.Items.Clear
    else
      ACombo.Items.Text := Service.ParentAccountsText(AParentCode);
    ACombo.Items.Insert(0, '');
  finally
    ACombo.Items.EndUpdate;
  end;
  ACombo.ItemIndex := 0;
  if ASelectCode <> '' then
    for I := 1 to ACombo.Items.Count - 1 do
      if ItemCode(ACombo.Items[I]) = ASelectCode then
      begin
        ACombo.ItemIndex := I;
        Break;
      end;
end;

// AKeepCurrent: kayıtlı hesabın kodu üst seçimden bağımsız listede tutulur (inceleme, biçimi eski kodlar)
procedure TfrmAccAccount.FillCodeCombo(const ASelectCode: string; AKeepCurrent: Boolean);
var
  LParent: string;
  I, LIndex: Integer;
begin
  LParent := SelectedParentCode;
  cbbCode.Items.BeginUpdate;
  try
    cbbCode.Items.Text := Service.FreeCodesText(LParent);
    // kayıtlı hesap kendi kodunu korur (inceleme / güncelleme); kopya ve yeni kayıtta yalnız boş kodlar
    if ((FormMode = ifmRewiev) or (FormMode = ifmUpdate)) and (Table.Code <> '') and
      (AKeepCurrent or (TAccAccountService.ParentCodeOf(Table.Code) = LParent)) and
      (cbbCode.Items.IndexOf(Table.Code) < 0) then
    begin
      LIndex := cbbCode.Items.Count;
      for I := 0 to cbbCode.Items.Count - 1 do
        if CompareStr(cbbCode.Items[I], Table.Code) > 0 then
        begin
          LIndex := I;
          Break;
        end;
      cbbCode.Items.Insert(LIndex, Table.Code);
    end;
  finally
    cbbCode.Items.EndUpdate;
  end;

  LIndex := cbbCode.Items.IndexOf(ASelectCode);
  // üst hesap seçilmemiş yeni kayıtta kod seçilmez (yanlışlıkla ana hesap açılmasın); diğerlerinde ilk boş kod
  if (LIndex < 0) and (cbbCode.Items.Count > 0) and ((LParent <> '') or (FormMode = ifmRewiev) or (FormMode = ifmUpdate)) then
    LIndex := 0;
  cbbCode.ItemIndex := LIndex;
end;

function TfrmAccAccount.SelectedParentCode: string;
begin
  Result := ComboCode(cbbSubCode);
  if Result = '' then
    Result := ComboCode(cbbRootCode);
end;

procedure TfrmAccAccount.cbbRootCodeChange(Sender: TObject);
begin
  if FCodeLoading then
    Exit;
  FCodeLoading := True;
  try
    FillParentCombo(cbbSubCode, ComboCode(cbbRootCode), '');
    FillCodeCombo(Table.Code, False);
  finally
    FCodeLoading := False;
  end;
end;

procedure TfrmAccAccount.cbbSubCodeChange(Sender: TObject);
begin
  if FCodeLoading then
    Exit;
  FillCodeCombo(Table.Code, False);
end;

// "Fatura Adresini Kullan": ekrandaki (kaydedilmemiş olabilir) fatura adresi bu sekmeye kopyalanır; kayıt Onayla ile
procedure TfrmAccAccount.AddressFromBilling(Sender: TObject);
begin
  if Sender is TDocumentAddressEditor then
    TDocumentAddressEditor(Sender).AssignFrom(FAddressEditors[0]);
end;

procedure TfrmAccAccount.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccGroupId: TfrmAccGroups;
  LFrmAccRegionId: TfrmAccRegions;
  LFrmIbanCurrency: TfrmSysCurrencies;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccGroupId.Name then
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
var
  LIndex: Integer;
begin
  inherited;
  LoadCodeSelection;
  edtName.Text := Table.Name;
  edtAccGroupId.Text := Table.GroupName;
  edtAccRegionId.Text := Table.RegionName;
  edtIban.Text := Table.Iban;
  edtIbanCurrency.Text := Table.IbanCurrency;
  edtDiscountRate.Text := CurrToStr(Table.DiscountRate);
  chkEInvoiceActive.Checked := Table.EInvoiceActive;
  chkEDespatchActive.Checked := Table.EDespatchActive;
  edtEInvoicePkAlias.Text := Table.EInvoicePkAlias;
  edtEInvoiceGbAlias.Text := Table.EInvoiceGbAlias;
  edtEDespatchPkAlias.Text := Table.EDespatchPkAlias;
  edtEDespatchGbAlias.Text := Table.EDespatchGbAlias;
  ApplyAliasState;
  chkIsPassive.Checked := Table.IsPassive;
  edtNotes.Text := Table.Notes;
  if (Table.TaxpayerType > 0) and (Table.TaxpayerType < cbbTaxpayerType.Items.Count) then
    cbbTaxpayerType.ItemIndex := Table.TaxpayerType
  else
    cbbTaxpayerType.ItemIndex := 0;
  ApplyTaxpayerType;
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

  // listeden gelen kopya (Table.Clone) adres taşımaz: kayıtlı hesapta adresler okunur
  if (Table.Id > 0) and not Table.AddressesAssigned then
    Service.LoadAddresses(Table);
  for LIndex := 0 to Table.Addresses.Count - 1 do
  begin
    FAddressEditors[LIndex].LoadFrom(Table.Addresses[LIndex].Address);
    FAddressEditors[LIndex].SetEditable((FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate));
  end;
end;

end.
