unit ufrmSysUom;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysUom.Service, SysUom, SysUomGroup.Service, SysUomGroup, ufrmSysUomGroups,
  SysLanguage;

type
  TfrmSysUom = class(TfrmInputSimpleDB<TSysUom, TSysUomService>)
    pnlContent: TPanel;
    lblUnit: TLabel;
    edtUnit: TEdit;
    lblUnitEInv: TLabel;
    edtUnitEInv: TEdit;
    lblDecimal: TLabel;
    chkDecimal: TCheckBox;
    lblMeasureTypeId: TLabel;
    edtMeasureTypeId: TEdit;
    lblMultiplier: TLabel;
    edtMultiplier: TEdit;
    scrlbxTranslations: TScrollBox;
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

procedure TfrmSysUom.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair  : TPair<string, string>;
  i      : Integer;
  LTrans : TSysUomTranslation;
  LFound : Boolean;
begin
  Table.UnitCode := edtUnit.Text;
  Table.UnitEInv := edtUnitEInv.Text;
  Table.Decimal := chkDecimal.Checked;
  Table.Multiplier := StrToIntDef(edtMultiplier.Text, 1);

  LValues := CollectTranslationValues(scrlbxTranslations, 'PermissionGroupName');
  try
    for LPair in LValues do
    begin
      LFound := False;
      if Assigned(Table.Translations) then
        for i := 0 to Table.Translations.Count - 1 do
          if SameText(Table.Translations[i].SysLanguage.Locale, LPair.Key) then
          begin
            Table.Translations[i].Name := LPair.Value;
            LFound := True;
            Break;
          end;

      if not LFound and (Trim(LPair.Value) <> '') then
      begin
        LTrans := TSysUomTranslation.Create;
        LTrans.SysUomId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.Name := LPair.Value;
        LTrans.SysLanguage := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LPair.Key;
        Table.Translations.Add(LTrans);
      end;
    end;
  finally
    LValues.Free;
  end;

  inherited;
end;

procedure TfrmSysUom.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtMeasureTypeId.OnHelperProcess := HelperProcess;

  BuildTranslationControls(
    scrlbxTranslations,
    'Description',
    TLocalizationManager.Translate(TLangKeys.TSysUom.ColDescription, 'Description'),
    lblUnitEInv);
end;

procedure TfrmSysUom.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtUnit.SetFocus;
end;

procedure TfrmSysUom.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_uom.title.singular', 'Ölçü Birimi');
  lblUnit.Caption := TLocalizationManager.Translate('sys_uom.unit_code', 'Birim Kodu');
  lblUnitEInv.Caption := TLocalizationManager.Translate('sys_uom.unit_einv', 'E-Fatura Birim Kodu');
  lblDecimal.Caption := TLocalizationManager.Translate('sys_uom.decimal', 'Ondalıklı');
  lblMeasureTypeId.Caption := TLocalizationManager.Translate('sys_uom.measure_type', 'Ölçü Birimi Tipi');
  lblMultiplier.Caption := TLocalizationManager.Translate('sys_uom.multiplier', 'Çarpan');
end;

procedure TfrmSysUom.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysUomTypes;
begin
  if Sender is TEdit then
  begin
    if (Sender as TEdit).Name = edtMeasureTypeId.Name then
    begin
      LFrm := TfrmSysUomTypes.Create((Sender as TEdit), TSysUomGroupService.Create, TSysUomGroup.Create);
      try
        LFrm.IsHelper := True;
        LFrm.ShowModal;
        if LFrm.DataTransfer then
        begin
          if LFrm.CleanAndClose then
          begin
            Table.GroupId := 0;
            (Sender as TEdit).Clear;
          end
          else
          begin
            Table.GroupId := LFrm.Table.Id;
            (Sender as TEdit).Text := LFrm.Table.Key;
          end;
        end;
      finally
        LFrm.Free;
      end;
    end;
  end;
end;

procedure TfrmSysUom.RefreshData;
var
  LValues: TTranslationMap;
  i      : Integer;
  LTrans : TSysUomTranslation;
begin
  inherited;
  edtUnit.Text := Table.UnitCode;
  edtUnitEInv.Text := Table.UnitEInv;
  chkDecimal.Checked := Table.Decimal;
  edtMultiplier.Text := Table.Multiplier.ToString;

  LValues := TTranslationMap.Create;
  try
    if Assigned(Table.Translations) then
      for i := 0 to Table.Translations.Count - 1 do
      begin
        LTrans := Table.Translations[i];
        if Assigned(LTrans.SysLanguage) and (LTrans.SysLanguage.Locale <> '') then
          LValues.AddOrSetValue(LTrans.SysLanguage.Locale, LTrans.Name);
      end;

    FillTranslationControls(scrlbxTranslations, LValues);
  finally
    LValues.Free;
  end;

  if Assigned(Table.SysUomGroup) then
    edtMeasureTypeId.Text := Table.SysUomGroup.Key
  else
    edtMeasureTypeId.Text := '';
end;

end.
