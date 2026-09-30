unit ufrmAccAccountAddress;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccAccountAddress.Service, AccAccountAddress;

type
  TfrmAccAccountAddress = class(TfrmInputSimpleDB<TAccAccountAddress, TAccAccountAddressService>)
    pnlContent: TPanel;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblSysAddressId: TLabel;
    edtSysAddressId: TEdit;
    lblAddressType: TLabel;
    cbbAddressType: TComboBox;
    lblIsPrimary: TLabel;
    chkIsPrimary: TCheckBox;
    lblValidFrom: TLabel;
    edtValidFrom: TEdit;
    lblValidTo: TLabel;
    edtValidTo: TEdit;
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
  AccAccount, AccAccount.Service, ufrmAccAccounts,                              // TfrmAccAccounts helper output form
  SysAddress, SysAddress.Service, ufrmSysAddresses;                             // TfrmSysAddresses helper output form

function AddressToText(AAddress: TSysAddress): string;
var
  LParts: TStringList;

  procedure AddPart(const AValue: string);
  begin
    if Trim(AValue) <> '' then
      LParts.Add(Trim(AValue));
  end;

begin
  LParts := TStringList.Create;
  try
    AddPart(AAddress.Neighborhood);
    AddPart(AAddress.Street);
    AddPart(AAddress.DoorNumber);
    AddPart(AAddress.District);
    LParts.Delimiter := ',';
    LParts.StrictDelimiter := True;
    Result := StringReplace(LParts.DelimitedText, ',', ', ', [rfReplaceAll]);
  finally
    LParts.Free;
  end;
end;

procedure TfrmAccAccountAddress.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  if cbbAddressType.ItemIndex >= 0 then
    Table.AddressType := cbbAddressType.Items[cbbAddressType.ItemIndex]
  else
    Table.AddressType := '';
  Table.IsPrimary := chkIsPrimary.Checked;
  Table.ValidFrom := StrToDateDef(edtValidFrom.Text, 0);
  Table.ValidTo := StrToDateDef(edtValidTo.Text, 0);
  inherited;
end;

procedure TfrmAccAccountAddress.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtSysAddressId.OnHelperProcess := HelperProcess;
  edtValidFrom.thsInputDataType := itDate;
  edtValidTo.thsInputDataType := itDate;
end;

procedure TfrmAccAccountAddress.FormShow(Sender: TObject);
begin
  inherited;
  if cbbAddressType.CanFocus then
    cbbAddressType.SetFocus;
end;

procedure TfrmAccAccountAddress.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.TitleSingular, 'Account Address');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColAccount, 'Account');
  lblSysAddressId.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColAddress, 'Address');
  lblAddressType.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColAddressType, 'Address Type');
  lblIsPrimary.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColIsPrimary, 'Primary');
  lblValidFrom.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColValidFrom, 'Valid From');
  lblValidTo.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ColValidTo, 'Valid To');
end;

procedure TfrmAccAccountAddress.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmSysAddressId: TfrmSysAddresses;
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
          Table.AccountName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccAccountId := LFrmAccAccountId.Table.Id;
          Table.AccountName := LFrmAccAccountId.Table.Name;
          LEdit.Text := Table.AccountName;
        end;
    finally
      LFrmAccAccountId.Free;
    end;
  end
  else if LEdit.Name = edtSysAddressId.Name then
  begin
    LFrmSysAddressId := TfrmSysAddresses.Create(LEdit, TSysAddressService.Create, TSysAddress.Create);
    try
      LFrmSysAddressId.IsHelper := True;
      LFrmSysAddressId.ShowModal;
      if LFrmSysAddressId.DataTransfer then
        if LFrmSysAddressId.CleanAndClose then
        begin
          Table.SysAddressId := 0;
          Table.AddressText := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SysAddressId := LFrmSysAddressId.Table.Id;
          Table.AddressText := AddressToText(LFrmSysAddressId.Table);
          LEdit.Text := Table.AddressText;
        end;
    finally
      LFrmSysAddressId.Free;
    end;
  end;
end;

procedure TfrmAccAccountAddress.RefreshData;
begin
  inherited;
  edtAccAccountId.Text := Table.AccountName;
  edtSysAddressId.Text := Table.AddressText;
  cbbAddressType.ItemIndex := cbbAddressType.Items.IndexOf(Table.AddressType);
  if cbbAddressType.ItemIndex < 0 then
    cbbAddressType.ItemIndex := 0;
  chkIsPrimary.Checked := Table.IsPrimary;
  if Table.ValidFrom > 0 then
    edtValidFrom.Text := DateToStr(Table.ValidFrom)
  else
    edtValidFrom.Text := '';
  if Table.ValidTo > 0 then
    edtValidTo.Text := DateToStr(Table.ValidTo)
  else
    edtValidTo.Text := '';
end;

end.
