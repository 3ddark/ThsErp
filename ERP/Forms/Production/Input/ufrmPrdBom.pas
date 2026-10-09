unit ufrmPrdBom;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdBom.Service, PrdBom;

type
  TfrmPrdBom = class(TfrmInputSimpleDB<TPrdBom, TPrdBomService>)
    pnlContent: TPanel;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblBomName: TLabel;
    edtBomName: TEdit;
    lblBaseQuantity: TLabel;
    edtBaseQuantity: TEdit;
    lblIsDefault: TLabel;
    chkIsDefault: TCheckBox;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    lblDescription: TLabel;
    edtDescription: TEdit;
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
  StkInventory, StkInventory.Service, ufrmStkInventories;                       // TfrmStkInventories helper output form

procedure TfrmPrdBom.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.BomName := edtBomName.Text;
  Table.BaseQuantity := StrToCurrDef(edtBaseQuantity.Text, 0);
  Table.IsDefault := chkIsDefault.Checked;
  Table.IsActive := chkIsActive.Checked;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPrdBom.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtBomName.thsInputDataType := itString;
  edtBaseQuantity.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmPrdBom.FormShow(Sender: TObject);
begin
  inherited;
  if edtBomName.CanFocus then
    edtBomName.SetFocus;
end;

procedure TfrmPrdBom.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.TitleSingular, 'BoM');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColStkInventoryId, 'Product');
  lblBomName.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBomName, 'BoM Name');
  lblBaseQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBaseQuantity, 'Base Quantity');
  lblIsDefault.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColIsDefault, 'Default BoM');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColIsActive, 'Active');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColDescription, 'Description');
end;

procedure TfrmPrdBom.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkInventoryId: TfrmStkInventories;
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
          Table.InventoryCode := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          LEdit.Text := Table.InventoryName;
        end;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

procedure TfrmPrdBom.RefreshData;
begin
  inherited;
  edtStkInventoryId.Text := Table.InventoryName;
  edtBomName.Text := Table.BomName;
  edtBaseQuantity.Text := CurrToStr(Table.BaseQuantity);
  chkIsDefault.Checked := Table.IsDefault;
  chkIsActive.Checked := Table.IsActive;
  edtDescription.Text := Table.Description;
end;

end.
