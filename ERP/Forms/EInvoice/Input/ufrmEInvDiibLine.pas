unit ufrmEInvDiibLine;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvDiibLine.Service, EInvDiibLine;

type
  TfrmEInvDiibLine = class(TfrmInputSimpleDB<TEInvDiibLine, TEInvDiibLineService>)
    pnlContent: TPanel;
    lblEinvDiibId: TLabel;
    edtEinvDiibId: TEdit;
    lblLineCode: TLabel;
    edtLineCode: TEdit;
    lblLineKind: TLabel;
    cbbLineKind: TComboBox;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblEinvGtipId: TLabel;
    edtEinvGtipId: TEdit;
    lblProductDescription: TLabel;
    edtProductDescription: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblSysUomId: TLabel;
    edtSysUomId: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
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
  EInvLookup,
  EInvDiib, EInvDiib.Service, ufrmEInvDiibs,
  StkInventory, StkInventory.Service, ufrmStkInventories,
  EInvGtip, EInvGtip.Service, ufrmEInvGtips,
  SysUom, SysUom.Service, ufrmSysUoms;

procedure TfrmEInvDiibLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.LineCode := edtLineCode.Text;
  Table.LineKind := cbbLineKind.ItemIndex + 1;
  Table.ProductDescription := edtProductDescription.Text;
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvDiibLine.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtEinvDiibId.OnHelperProcess := HelperProcess;
  edtLineCode.thsInputDataType := itString;
  edtLineCode.CharCase := TEditCharCase.ecUpperCase;
  TEInvLookup.FillItems(cbbLineKind.Items, elkDiibLineKind);
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtEinvGtipId.OnHelperProcess := HelperProcess;
  edtProductDescription.thsInputDataType := itString;
  edtQuantity.thsInputDataType := itFloat;
  edtSysUomId.OnHelperProcess := HelperProcess;
end;

procedure TfrmEInvDiibLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtLineCode.CanFocus then
    edtLineCode.SetFocus;
end;

procedure TfrmEInvDiibLine.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.TitleSingular, 'DIIB Line');
  lblEinvDiibId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColEinvDiibId, 'DIIB No');
  lblLineCode.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColLineCode, 'DIIB Line Code');
  lblLineKind.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColLineKind, 'Line Kind');
  LIndex := cbbLineKind.ItemIndex;
  TEInvLookup.FillItems(cbbLineKind.Items, elkDiibLineKind);
  cbbLineKind.ItemIndex := LIndex;
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColStkInventoryId, 'Stock Card');
  lblEinvGtipId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColEinvGtipId, 'GTIP Code');
  lblProductDescription.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColProductDescription, 'DIIB Product Description');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColQuantity, 'Quantity');
  lblSysUomId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColSysUomId, 'Unit');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColIsActive, 'Active');
end;

procedure TfrmEInvDiibLine.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmEinvDiibId: TfrmEInvDiibs;
  LFrmStkInventoryId: TfrmStkInventories;
  LFrmEinvGtipId: TfrmEInvGtips;
  LFrmSysUomId: TfrmSysUoms;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtEinvDiibId.Name then
  begin
    LFrmEinvDiibId := TfrmEInvDiibs.Create(LEdit, TEInvDiibService.Create, TEInvDiib.Create);
    try
      LFrmEinvDiibId.IsHelper := True;
      LFrmEinvDiibId.ShowModal;
      if LFrmEinvDiibId.DataTransfer then
        if LFrmEinvDiibId.CleanAndClose then
        begin
          Table.EinvDiibId := 0;
          Table.DocumentNo := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EinvDiibId := LFrmEinvDiibId.Table.Id;
          Table.DocumentNo := LFrmEinvDiibId.Table.DocumentNo;
          LEdit.Text := Table.DocumentNo;
        end;
    finally
      LFrmEinvDiibId.Free;
    end;
  end
  else if LEdit.Name = edtStkInventoryId.Name then
  begin
    LFrmStkInventoryId := TfrmStkInventories.Create(LEdit, TStkInventoryService.Create, TStkInventory.Create);
    try
      LFrmStkInventoryId.IsHelper := True;
      LFrmStkInventoryId.ShowModal;
      if LFrmStkInventoryId.DataTransfer then
        if LFrmStkInventoryId.CleanAndClose then
        begin
          Table.StkInventoryId := 0;
          Table.InventoryCode := '';
          Table.InventoryName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          LEdit.Text := Table.InventoryName;
        end;
      if LFrmStkInventoryId.DataTransfer and not LFrmStkInventoryId.CleanAndClose then
      begin
        if (Table.EinvGtipId <= 0) and (LFrmStkInventoryId.Table.EinvGtipId > 0) then
        begin
          Table.EinvGtipId := LFrmStkInventoryId.Table.EinvGtipId;
          Table.GtipCode := LFrmStkInventoryId.Table.GtipCode;
          Table.GtipName := LFrmStkInventoryId.Table.GtipName;
          edtEinvGtipId.Text := Table.GtipCode;
        end;
        if Trim(edtProductDescription.Text) = '' then
        begin
          if LFrmStkInventoryId.Table.DiibProductDescription <> '' then
            edtProductDescription.Text := LFrmStkInventoryId.Table.DiibProductDescription
          else
            edtProductDescription.Text := LFrmStkInventoryId.Table.Name;
        end;
      end;
    finally
      LFrmStkInventoryId.Free;
    end;
  end
  else if LEdit.Name = edtEinvGtipId.Name then
  begin
    LFrmEinvGtipId := TfrmEInvGtips.Create(LEdit, TEInvGtipService.Create, TEInvGtip.Create);
    try
      LFrmEinvGtipId.IsHelper := True;
      LFrmEinvGtipId.ShowModal;
      if LFrmEinvGtipId.DataTransfer then
        if LFrmEinvGtipId.CleanAndClose then
        begin
          Table.EinvGtipId := 0;
          Table.GtipCode := '';
          Table.GtipName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EinvGtipId := LFrmEinvGtipId.Table.Id;
          Table.GtipCode := LFrmEinvGtipId.Table.Code;
          Table.GtipName := LFrmEinvGtipId.Table.Name;
          LEdit.Text := Table.GtipCode;
        end;
    finally
      LFrmEinvGtipId.Free;
    end;
  end
  else if LEdit.Name = edtSysUomId.Name then
  begin
    LFrmSysUomId := TfrmSysUoms.Create(LEdit, TSysUomService.Create, TSysUom.Create);
    try
      LFrmSysUomId.IsHelper := True;
      LFrmSysUomId.ShowModal;
      if LFrmSysUomId.DataTransfer then
        if LFrmSysUomId.CleanAndClose then
        begin
          Table.SysUomId := 0;
          Table.UnitCode := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SysUomId := LFrmSysUomId.Table.Id;
          Table.UnitCode := LFrmSysUomId.Table.UnitCode;
          LEdit.Text := Table.UnitCode;
        end;
    finally
      LFrmSysUomId.Free;
    end;
  end;
end;

procedure TfrmEInvDiibLine.RefreshData;
begin
  inherited;
  edtEinvDiibId.Text := Table.DocumentNo;
  edtLineCode.Text := Table.LineCode;
  cbbLineKind.ItemIndex := Table.LineKind - 1;
  edtStkInventoryId.Text := Table.InventoryName;
  edtEinvGtipId.Text := Table.GtipCode;
  edtProductDescription.Text := Table.ProductDescription;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtSysUomId.Text := Table.UnitCode;
  chkIsActive.Checked := Table.IsActive;
end;

end.
