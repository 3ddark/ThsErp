unit ufrmPrdPacketRawDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdPacketRawDetail.Service, PrdPacketRawDetail;

type
  TfrmPrdPacketRawDetail = class(TfrmInputSimpleDB<TPrdPacketRawDetail, TPrdPacketRawDetailService>)
    pnlContent: TPanel;
    lblPrdPacketRawId: TLabel;
    edtPrdPacketRawId: TEdit;
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
  PrdPacketRaw, PrdPacketRaw.Service, ufrmPrdPacketRaws,                        // TfrmPrdPacketRaws helper output form
  StkInventory, StkInventory.Service, ufrmStkInventories,                       // TfrmStkInventories helper output form
  PrdBom, PrdBom.Service, ufrmPrdBoms;                                          // TfrmPrdBoms helper output form

procedure TfrmPrdPacketRawDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdPacketRawDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSubPrdBomId.OnHelperProcess := HelperProcess;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtPrdPacketRawId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
end;

procedure TfrmPrdPacketRawDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuantity.CanFocus then
    edtQuantity.SetFocus;
end;

procedure TfrmPrdPacketRawDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.TitleSingular, 'Raw Material Packet Item');
  lblPrdPacketRawId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColPrdPacketRawId, 'Packet');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColStkInventoryId, 'Raw Material');
  lblSubPrdBomId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColSubPrdBomId, 'Sub BoM (Semi-Product)');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColQuantity, 'Quantity');
end;

procedure TfrmPrdPacketRawDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdPacketRawId: TfrmPrdPacketRaws;
  LFrmStkInventoryId: TfrmStkInventories;
  LFrmSubPrdBomId: TfrmPrdBoms;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPrdPacketRawId.Name then
  begin
    LFrmPrdPacketRawId := TfrmPrdPacketRaws.Create(LEdit, TPrdPacketRawService.Create, TPrdPacketRaw.Create);
    try
      LFrmPrdPacketRawId.IsHelper := True;
      LFrmPrdPacketRawId.ShowModal;
      if LFrmPrdPacketRawId.DataTransfer then
        if LFrmPrdPacketRawId.CleanAndClose then
        begin
          Table.PrdPacketRawId := 0;
          Table.PacketName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PrdPacketRawId := LFrmPrdPacketRawId.Table.Id;
          Table.PacketName := LFrmPrdPacketRawId.Table.PacketName;
          LEdit.Text := Table.PacketName;
        end;
    finally
      LFrmPrdPacketRawId.Free;
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

procedure TfrmPrdPacketRawDetail.RefreshData;
begin
  inherited;
  edtPrdPacketRawId.Text := Table.PacketName;
  edtStkInventoryId.Text := Table.InventoryName;
  edtSubPrdBomId.Text := Table.SubBomName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
