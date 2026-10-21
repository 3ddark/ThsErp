unit ufrmPrdPacketRawLine;

// Paket kalemi satır formu (TfrmPrdPacketRawLine'den modal): bellekteki satırı düzenler, DB'ye paketle birlikte yazılır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdPacketRawDetail.Service, PrdPacketRawDetail;

type
  TfrmPrdPacketRawLine = class(TfrmInputLineDB<TPrdPacketRawDetail, TPrdPacketRawDetailService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblSubPrdBomId: TLabel;
    edtSubPrdBomId: TEdit;
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
  StkInventory, StkInventory.Service, ufrmStkInventories,                       // TfrmStkInventories helper output form
  PrdBom, PrdBom.Service, ufrmPrdBoms;                                          // TfrmPrdBoms helper output form

procedure TfrmPrdPacketRawLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; başlık (belge) ana formdan gelir, formda gösterilmez
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdPacketRawLine.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtSubPrdBomId.OnHelperProcess := HelperProcess;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
end;

procedure TfrmPrdPacketRawLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuantity.CanFocus then
    edtQuantity.SetFocus;
end;

procedure TfrmPrdPacketRawLine.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.TitleSingular, 'Raw Material Packet Item');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColStkInventoryId, 'Raw Material');
  lblSubPrdBomId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColSubPrdBomId, 'Sub BoM (Semi-Product)');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColQuantity, 'Quantity');
end;

procedure TfrmPrdPacketRawLine.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkInventoryId: TfrmStkInventories;
  LFrmSubPrdBomId: TfrmPrdBoms;
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
  end
  else if LEdit.Name = edtSubPrdBomId.Name then
  begin
    LFrmSubPrdBomId := TfrmPrdBoms.Create(LEdit, TPrdBomService.Create, TPrdBom.Create);
    try
      LFrmSubPrdBomId.IsHelper := True;
      LFrmSubPrdBomId.ShowModal;
      if LFrmSubPrdBomId.DataTransfer then
        if LFrmSubPrdBomId.CleanAndClose then
        begin
          Table.SubPrdBomId := 0;
          Table.SubBomName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SubPrdBomId := LFrmSubPrdBomId.Table.Id;
          Table.SubBomName := LFrmSubPrdBomId.Table.BomName;
          LEdit.Text := Table.SubBomName;
        end;
    finally
      LFrmSubPrdBomId.Free;
    end;
  end;
end;

procedure TfrmPrdPacketRawLine.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtSubPrdBomId.Text := Table.SubBomName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
