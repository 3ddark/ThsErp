unit ufrmPrdBomByProduct;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdBomByProduct.Service, PrdBomByProduct;

type
  TfrmPrdBomByProduct = class(TfrmInputSimpleDB<TPrdBomByProduct, TPrdBomByProductService>)
    pnlContent: TPanel;
    lblPrdBomId: TLabel;
    edtPrdBomId: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
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
  PrdBom, PrdBom.Service, ufrmPrdBoms,                                          // TfrmPrdBoms helper output form
  StkInventory, StkInventory.Service, ufrmStkInventories;                       // TfrmStkInventories helper output form

procedure TfrmPrdBomByProduct.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdBomByProduct.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtPrdBomId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
end;

procedure TfrmPrdBomByProduct.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuantity.CanFocus then
    edtQuantity.SetFocus;
end;

procedure TfrmPrdBomByProduct.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.TitleSingular, 'BoM By-Product');
  lblPrdBomId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColPrdBomId, 'BoM');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColStkInventoryId, 'By-Product');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColQuantity, 'Quantity');
end;

procedure TfrmPrdBomByProduct.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdBomId: TfrmPrdBoms;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPrdBomId.Name then
  begin
    LFrmPrdBomId := TfrmPrdBoms.Create(LEdit, TPrdBomService.Create, TPrdBom.Create);
    try
      LFrmPrdBomId.IsHelper := True;
      LFrmPrdBomId.ShowModal;
      if LFrmPrdBomId.DataTransfer then
        if LFrmPrdBomId.CleanAndClose then
        begin
          Table.PrdBomId := 0;
          Table.BomName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PrdBomId := LFrmPrdBomId.Table.Id;
          Table.BomName := LFrmPrdBomId.Table.BomName;
          LEdit.Text := Table.BomName;
        end;
    finally
      LFrmPrdBomId.Free;
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

procedure TfrmPrdBomByProduct.RefreshData;
begin
  inherited;
  edtPrdBomId.Text := Table.BomName;
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
