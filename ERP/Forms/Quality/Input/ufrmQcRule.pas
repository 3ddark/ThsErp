unit ufrmQcRule;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  QcRule.Service, QcRule;

type
  // Kural: stok grubu YA DA stok kartı (biri seçilince diğeri temizlenir), kontrol gerekli mi, kontrol kriterleri
  TfrmQcRule = class(TfrmInputSimpleDB<TQcRule, TQcRuleService>)
    pnlContent: TPanel;
    lblStkGroupId: TLabel;
    edtStkGroupId: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    chkIsRequired: TCheckBox;
    lblInspectionCriteria: TLabel;
    edtInspectionCriteria: TEdit;
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
  StkGroup, StkGroup.Service, ufrmStkGroups,              // TfrmStkGroups helper output form
  StkInventory, StkInventory.Service, ufrmStkInventories; // TfrmStkInventories helper output form

procedure TfrmQcRule.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.IsRequired := chkIsRequired.Checked;
  Table.InspectionCriteria := edtInspectionCriteria.Text;
  inherited;
end;

procedure TfrmQcRule.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtStkGroupId.OnHelperProcess := HelperProcess;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtInspectionCriteria.thsInputDataType := itString;
end;

procedure TfrmQcRule.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkGroupId.CanFocus then
    edtStkGroupId.SetFocus;
end;

procedure TfrmQcRule.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TQcRule.TitleSingular, 'Quality Control Rule');
  lblStkGroupId.Caption := TLocalizationManager.Translate(TLangKeys.TQcRule.ColGroupName, 'Stock Group');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TQcRule.ColInventoryName, 'Stock Name');
  chkIsRequired.Caption := TLocalizationManager.Translate(TLangKeys.TQcRule.ColIsRequired, 'Inspection Required');
  lblInspectionCriteria.Caption := TLocalizationManager.Translate(TLangKeys.TQcRule.ColInspectionCriteria, 'Inspection Criteria');
end;

procedure TfrmQcRule.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmGroup: TfrmStkGroups;
  LFrmInventory: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;
  LEdit := (Sender as TEdit);
  if LEdit.Name = edtStkGroupId.Name then
  begin
    LFrmGroup := TfrmStkGroups.Create(LEdit, TStkGroupService.Create, TStkGroup.Create);
    try
      LFrmGroup.IsHelper := True;
      LFrmGroup.ShowModal;
      if LFrmGroup.DataTransfer then
        if LFrmGroup.CleanAndClose then
        begin
          Table.StkGroupId := 0;
          Table.GroupName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkGroupId := LFrmGroup.Table.Id;
          Table.GroupName := LFrmGroup.Table.Name;
          LEdit.Text := Table.GroupName;
          // kural ya grup ya kart içindir
          Table.StkInventoryId := 0;
          Table.InventoryCode := '';
          Table.InventoryName := '';
          edtStkInventoryId.Clear;
        end;
    finally
      LFrmGroup.Free;
    end;
  end
  else if LEdit.Name = edtStkInventoryId.Name then
  begin
    LFrmInventory := TfrmStkInventories.Create(LEdit, TStkInventoryService.Create, TStkInventory.Create);
    try
      LFrmInventory.IsHelper := True;
      LFrmInventory.ShowModal;
      if LFrmInventory.DataTransfer then
        if LFrmInventory.CleanAndClose then
        begin
          Table.StkInventoryId := 0;
          Table.InventoryCode := '';
          Table.InventoryName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmInventory.Table.Id;
          Table.InventoryCode := LFrmInventory.Table.Code;
          Table.InventoryName := LFrmInventory.Table.Name;
          LEdit.Text := Table.InventoryName;
          Table.StkGroupId := 0;
          Table.GroupName := '';
          edtStkGroupId.Clear;
        end;
    finally
      LFrmInventory.Free;
    end;
  end;
end;

procedure TfrmQcRule.RefreshData;
begin
  inherited;
  edtStkGroupId.Text := Table.GroupName;
  edtStkInventoryId.Text := Table.InventoryName;
  chkIsRequired.Checked := Table.IsRequired;
  edtInspectionCriteria.Text := Table.InspectionCriteria;
end;

end.
