unit ufrmPrdLabour;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdLabour.Service, PrdLabour;

type
  TfrmPrdLabour = class(TfrmInputSimpleDB<TPrdLabour, TPrdLabourService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblCostType: TLabel;
    cbbCostType: TComboBox;
    lblSysUomId: TLabel;
    edtSysUomId: TEdit;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblAccAccountCode: TLabel;
    edtAccAccountCode: TEdit;
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
  PrdLookup,
  SysUom, SysUom.Service, ufrmSysUoms,                                          // TfrmSysUoms helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies,                          // TfrmSysCurrencies helper output form
  AccAccount, AccAccount.Service, ufrmAccAccounts;                              // TfrmAccAccounts helper output form

procedure TfrmPrdLabour.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.CostType := cbbCostType.ItemIndex + 1;  // seçim yoksa 0 -> zorunluluk kontrolü
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  inherited;
end;

procedure TfrmPrdLabour.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtAccAccountCode.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtSysUomId.OnHelperProcess := HelperProcess;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  TPrdLookup.FillItems(cbbCostType.Items, plkCostType);
  edtUnitPrice.thsInputDataType := itFloat;
end;

procedure TfrmPrdLabour.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmPrdLabour.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.TitleSingular, 'Labour / Cost');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColCode, 'Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColName, 'Name');
  lblCostType.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColCostType, 'Cost Type');
  lblSysUomId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColSysUomId, 'Unit');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColUnitPrice, 'Unit Price');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColCurrency, 'Currency');
  lblAccAccountCode.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColAccAccountCode, 'Expense Account');
  LIndex := cbbCostType.ItemIndex;
  TPrdLookup.FillItems(cbbCostType.Items, plkCostType);
  cbbCostType.ItemIndex := LIndex;
end;

procedure TfrmPrdLabour.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmSysUomId: TfrmSysUoms;
  LFrmCurrency: TfrmSysCurrencies;
  LFrmAccAccountCode: TfrmAccAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtSysUomId.Name then
  begin
    LFrmSysUomId := TfrmSysUoms.Create(LEdit, TSysUomService.Create, TSysUom.Create);
    try
      LFrmSysUomId.IsHelper := True;
      LFrmSysUomId.ShowModal;
      if LFrmSysUomId.DataTransfer then
        if LFrmSysUomId.CleanAndClose then
        begin
          Table.SysUomId := 0;
          Table.UomCode := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SysUomId := LFrmSysUomId.Table.Id;
          Table.UomCode := LFrmSysUomId.Table.UnitCode;
          LEdit.Text := Table.UomCode;
        end;
    finally
      LFrmSysUomId.Free;
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

procedure TfrmPrdLabour.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  cbbCostType.ItemIndex := Table.CostType - 1;
  edtSysUomId.Text := Table.UomCode;
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtCurrency.Text := Table.Currency;
  edtAccAccountCode.Text := Table.AccAccountCode;
end;

end.
