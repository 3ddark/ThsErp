unit ufrmSysUom;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysUom.Service, SysUom,
  SysUomGroup.Service, SysUomGroup, ufrmSysUomGroups,
  SysLanguage, LocalizationManager;

type
  TfrmSysUom = class(TfrmInputSimpleDB<TSysUom, TSysUomService>)
    pnlContent: TPanel;
    lblUnit: TLabel;
    edtUnit: TEdit;
    lblUnitEInv: TLabel;
    edtUnitEInv: TEdit;
    lblDescriptionEN: TLabel;
    edtDescriptionEN: TEdit;
    lblDescriptionTR: TLabel;
    edtDescriptionTR: TEdit;
    lblDecimal: TLabel;
    chkDecimal: TCheckBox;
    lblMeasureTypeId: TLabel;
    edtMeasureTypeId: TEdit;
    lblMultiplier: TLabel;
    edtMultiplier: TEdit;
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
  procedure SetOrAddTranslation(ALangId: Int64; const ALocale, ADesc: string);
  var
    i: Integer;
    LTrans: TSysUomTranslation;
    LFound: Boolean;
  begin
    LFound := False;
    if Assigned(Table.Translations) then
    begin
      for i := 0 to Table.Translations.Count - 1 do
      begin
        if (Assigned(Table.Translations[i].SysLanguage) and SameText(Table.Translations[i].SysLanguage.Locale, ALocale))
        or (Table.Translations[i].SysLanguageId = ALangId) then
        begin
          Table.Translations[i].Name := ADesc;
          LFound := True;
          Break;
        end;
      end;
    end;

    if not LFound and (Trim(ADesc) <> '') then
    begin
      LTrans := TSysUomTranslation.Create;
      LTrans.SysUomId := Table.Id;
      LTrans.SysLanguageId := ALangId;
      LTrans.Name := ADesc;
      LTrans.SysLanguage := TSysLanguage.Create;
      LTrans.SysLanguage.Id := ALangId;
      LTrans.SysLanguage.Locale := ALocale;
      Table.Translations.Add(LTrans);
    end;
  end;
begin
  Table.UnitCode := edtUnit.Text;
  Table.UnitEInv := edtUnitEInv.Text;
  Table.Decimal := chkDecimal.Checked;
  Table.Multiplier := StrToIntDef(edtMultiplier.Text, 1);

  SetOrAddTranslation(CLangID_EN, CLangLocaleEN, edtDescriptionEN.Text);
  SetOrAddTranslation(CLangID_TR, CLangLocaleTR, edtDescriptionTR.Text);

  inherited;
end;

procedure TfrmSysUom.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtMeasureTypeId.OnHelperProcess := HelperProcess;
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
  lblDescriptionEN.Caption := TLocalizationManager.Translate('sys_uom.desc_en', 'Açıklama (İngilizce)');
  lblDescriptionTR.Caption := TLocalizationManager.Translate('sys_uom.desc_tr', 'Açıklama (Türkçe)');
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
  i: Integer;
begin
  inherited;
  edtUnit.Text := Table.UnitCode;
  edtUnitEInv.Text := Table.UnitEInv;
  edtDescriptionEN.Text := '';
  edtDescriptionTR.Text := '';
  chkDecimal.Checked := Table.Decimal;
  edtMultiplier.Text := Table.Multiplier.ToString;

  if Assigned(Table.Translations) then
  begin
    for i := 0 to Table.Translations.Count - 1 do
    begin
      if Assigned(Table.Translations[i].SysLanguage) then
      begin
        if SameText(Table.Translations[i].SysLanguage.Locale, CLangLocaleEN) then
          edtDescriptionEN.Text := Table.Translations[i].Name
        else if SameText(Table.Translations[i].SysLanguage.Locale, CLangLocaleTR) then
          edtDescriptionTR.Text := Table.Translations[i].Name;
      end
      else
      begin
        if Table.Translations[i].SysLanguageId = CLangID_EN then
          edtDescriptionEN.Text := Table.Translations[i].Name
        else if Table.Translations[i].SysLanguageId = CLangID_TR then
          edtDescriptionTR.Text := Table.Translations[i].Name;
      end;
    end;
  end;

  if Assigned(Table.SysUomGroup) then
    edtMeasureTypeId.Text := Table.SysUomGroup.Key
  else
    edtMeasureTypeId.Text := '';
end;

end.
