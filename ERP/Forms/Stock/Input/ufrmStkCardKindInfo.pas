unit ufrmStkCardKindInfo;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  StkCardKindInfo.Service, StkCardKindInfo, StkKindProperty;

type
  TfrmStkCardKindInfo = class(TfrmInputSimpleDB<TStkCardKindInfo, TStkCardKindInfoService>)
    pnlContent: TPanel;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblStkKindPropertyId: TLabel;
    edtStkKindPropertyId: TEdit;
    lblS1: TLabel;
    edtS1: TEdit;
    lblS2: TLabel;
    edtS2: TEdit;
    lblS3: TLabel;
    edtS3: TEdit;
    lblS4: TLabel;
    edtS4: TEdit;
    lblS5: TLabel;
    edtS5: TEdit;
    lblS6: TLabel;
    edtS6: TEdit;
    lblS7: TLabel;
    edtS7: TEdit;
    lblS8: TLabel;
    edtS8: TEdit;
    lblS9: TLabel;
    edtS9: TEdit;
    lblS10: TLabel;
    edtS10: TEdit;
    lblI1: TLabel;
    edtI1: TEdit;
    lblI2: TLabel;
    edtI2: TEdit;
    lblI3: TLabel;
    edtI3: TEdit;
    lblI4: TLabel;
    edtI4: TEdit;
    lblI5: TLabel;
    edtI5: TEdit;
    lblD1: TLabel;
    edtD1: TEdit;
    lblD2: TLabel;
    edtD2: TEdit;
    lblD3: TLabel;
    edtD3: TEdit;
    lblD4: TLabel;
    edtD4: TEdit;
    lblD5: TLabel;
    edtD5: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    // Seçilen cinsin alan etiketleri (s1..d5); cins seçiliyse yalnız etiketi tanımlı alanlar gösterilir
    FKind: TStkKindProperty;
    procedure LoadKind(AKindId: Int64);
    procedure ApplyKindLabels;
    function SlotLabels: TArray<TLabel>;
    function SlotEdits: TArray<TEdit>;
  public
    destructor Destroy; override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  StkInventory, StkInventory.Service, ufrmStkInventories,                       // TfrmStkInventories helper output form
  StkKindProperty.Service, ufrmStkKindProperties;                               // TfrmStkKindProperties helper output form

destructor TfrmStkCardKindInfo.Destroy;
begin
  FreeAndNil(FKind);
  inherited;
end;

function TfrmStkCardKindInfo.SlotLabels: TArray<TLabel>;
begin
  Result := [
    lblS1, lblS2, lblS3, lblS4, lblS5, lblS6, lblS7, lblS8, lblS9, lblS10, lblI1, lblI2, lblI3, lblI4, lblI5,
    lblD1, lblD2, lblD3, lblD4, lblD5];
end;

function TfrmStkCardKindInfo.SlotEdits: TArray<TEdit>;
begin
  Result := [
    edtS1, edtS2, edtS3, edtS4, edtS5, edtS6, edtS7, edtS8, edtS9, edtS10, edtI1, edtI2, edtI3, edtI4, edtI5,
    edtD1, edtD2, edtD3, edtD4, edtD5];
end;

procedure TfrmStkCardKindInfo.LoadKind(AKindId: Int64);
var
  LService: TStkKindPropertyService;
begin
  FreeAndNil(FKind);
  if AKindId > 0 then
  begin
    LService := TStkKindPropertyService.Create;
    try
      FKind := LService.FindById(AKindId, False);
    finally
      LService.Free;
    end;
  end;
  ApplyKindLabels;
end;

procedure TfrmStkCardKindInfo.ApplyKindLabels;
var
  LLabels: TArray<TLabel>;
  LEdits: TArray<TEdit>;
  LCaptions: TArray<string>;
  LVisible: Boolean;
  I: Integer;
begin
  LLabels := SlotLabels;
  LEdits := SlotEdits;
  if Assigned(FKind) then
    LCaptions := [
      FKind.S1, FKind.S2, FKind.S3, FKind.S4, FKind.S5, FKind.S6, FKind.S7, FKind.S8, FKind.S9, FKind.S10,
      FKind.I1, FKind.I2, FKind.I3, FKind.I4, FKind.I5, FKind.D1, FKind.D2, FKind.D3, FKind.D4, FKind.D5];

  for I := 0 to High(LLabels) do
  begin
    LVisible := (not Assigned(FKind)) or (Trim(LCaptions[I]) <> '');
    LLabels[I].Visible := LVisible;
    LEdits[I].Visible := LVisible;
    if Assigned(FKind) and LVisible then
      LLabels[I].Caption := LCaptions[I];
  end;
end;

procedure TfrmStkCardKindInfo.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.S1 := edtS1.Text;
  Table.S2 := edtS2.Text;
  Table.S3 := edtS3.Text;
  Table.S4 := edtS4.Text;
  Table.S5 := edtS5.Text;
  Table.S6 := edtS6.Text;
  Table.S7 := edtS7.Text;
  Table.S8 := edtS8.Text;
  Table.S9 := edtS9.Text;
  Table.S10 := edtS10.Text;
  Table.I1 := StrToIntDef(edtI1.Text, 0);
  Table.I2 := StrToIntDef(edtI2.Text, 0);
  Table.I3 := StrToIntDef(edtI3.Text, 0);
  Table.I4 := StrToIntDef(edtI4.Text, 0);
  Table.I5 := StrToIntDef(edtI5.Text, 0);
  Table.D1 := StrToFloatDef(edtD1.Text, 0);
  Table.D2 := StrToFloatDef(edtD2.Text, 0);
  Table.D3 := StrToFloatDef(edtD3.Text, 0);
  Table.D4 := StrToFloatDef(edtD4.Text, 0);
  Table.D5 := StrToFloatDef(edtD5.Text, 0);
  inherited;
end;

procedure TfrmStkCardKindInfo.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtStkKindPropertyId.OnHelperProcess := HelperProcess;
  edtS1.thsInputDataType := itString;
  edtS2.thsInputDataType := itString;
  edtS3.thsInputDataType := itString;
  edtS4.thsInputDataType := itString;
  edtS5.thsInputDataType := itString;
  edtS6.thsInputDataType := itString;
  edtS7.thsInputDataType := itString;
  edtS8.thsInputDataType := itString;
  edtS9.thsInputDataType := itString;
  edtS10.thsInputDataType := itString;
  edtI1.thsInputDataType := itInteger;
  edtI2.thsInputDataType := itInteger;
  edtI3.thsInputDataType := itInteger;
  edtI4.thsInputDataType := itInteger;
  edtI5.thsInputDataType := itInteger;
  edtD1.thsInputDataType := itFloat;
  edtD2.thsInputDataType := itFloat;
  edtD3.thsInputDataType := itFloat;
  edtD4.thsInputDataType := itFloat;
  edtD5.thsInputDataType := itFloat;
end;

procedure TfrmStkCardKindInfo.FormShow(Sender: TObject);
begin
  inherited;
  if edtS1.CanFocus then
    edtS1.SetFocus;
end;

procedure TfrmStkCardKindInfo.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.TitleSingular, 'Stock Kind Information');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColInventory, 'Stock Card');
  lblStkKindPropertyId.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColKind, 'Kind');
  lblS1.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS1, 'Text 1');
  lblS2.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS2, 'Text 2');
  lblS3.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS3, 'Text 3');
  lblS4.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS4, 'Text 4');
  lblS5.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS5, 'Text 5');
  lblS6.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS6, 'Text 6');
  lblS7.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS7, 'Text 7');
  lblS8.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS8, 'Text 8');
  lblS9.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS9, 'Text 9');
  lblS10.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColS10, 'Text 10');
  lblI1.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI1, 'Integer 1');
  lblI2.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI2, 'Integer 2');
  lblI3.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI3, 'Integer 3');
  lblI4.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI4, 'Integer 4');
  lblI5.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColI5, 'Integer 5');
  lblD1.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD1, 'Decimal 1');
  lblD2.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD2, 'Decimal 2');
  lblD3.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD3, 'Decimal 3');
  lblD4.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD4, 'Decimal 4');
  lblD5.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColD5, 'Decimal 5');
  ApplyKindLabels;
end;

procedure TfrmStkCardKindInfo.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkInventoryId: TfrmStkInventories;
  LFrmStkKindPropertyId: TfrmStkKindProperties;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtStkInventoryId.Name then
  begin
    LFrmStkInventoryId := TfrmStkInventories.Create(LEdit, TStkInventoryService.Create, TStkInventory.Create);
    try
      LFrmStkInventoryId.IsHelper := True;
      LFrmStkInventoryId.ShowModal;
      if LFrmStkInventoryId.DataTransfer then
        if LFrmStkInventoryId.CleanAndClose then
        begin
          Table.StkInventoryId := 0;
          Table.InventoryName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          LEdit.Text := Table.InventoryName;
        end;
    finally
      LFrmStkInventoryId.Free;
    end;
  end
  else if LEdit.Name = edtStkKindPropertyId.Name then
  begin
    LFrmStkKindPropertyId := TfrmStkKindProperties.Create(LEdit, TStkKindPropertyService.Create, TStkKindProperty.Create);
    try
      LFrmStkKindPropertyId.IsHelper := True;
      LFrmStkKindPropertyId.ShowModal;
      if LFrmStkKindPropertyId.DataTransfer then
        if LFrmStkKindPropertyId.CleanAndClose then
        begin
          Table.StkKindPropertyId := 0;
          Table.KindName := '';
          LoadKind(0);
          LEdit.Clear;
        end
        else
        begin
          Table.StkKindPropertyId := LFrmStkKindPropertyId.Table.Id;
          Table.KindName := LFrmStkKindPropertyId.Table.Kind;
          LoadKind(Table.StkKindPropertyId);
          LEdit.Text := Table.KindName;
        end;
    finally
      LFrmStkKindPropertyId.Free;
    end;
  end;
end;

procedure TfrmStkCardKindInfo.RefreshData;
begin
  inherited;
  edtStkInventoryId.Text := Table.InventoryName;
  edtStkKindPropertyId.Text := Table.KindName;
  LoadKind(Table.StkKindPropertyId);
  edtS1.Text := Table.S1;
  edtS2.Text := Table.S2;
  edtS3.Text := Table.S3;
  edtS4.Text := Table.S4;
  edtS5.Text := Table.S5;
  edtS6.Text := Table.S6;
  edtS7.Text := Table.S7;
  edtS8.Text := Table.S8;
  edtS9.Text := Table.S9;
  edtS10.Text := Table.S10;
  edtI1.Text := IntToStr(Table.I1);
  edtI2.Text := IntToStr(Table.I2);
  edtI3.Text := IntToStr(Table.I3);
  edtI4.Text := IntToStr(Table.I4);
  edtI5.Text := IntToStr(Table.I5);
  edtD1.Text := FloatToStr(Table.D1);
  edtD2.Text := FloatToStr(Table.D2);
  edtD3.Text := FloatToStr(Table.D3);
  edtD4.Text := FloatToStr(Table.D4);
  edtD5.Text := FloatToStr(Table.D5);
end;

end.
