unit ufrmPrdPacketRawDetail;

// Hammadde paketi: başlık (prd_packet_raw) + kalemler (Table.Lines, prd_packet_raw_detail) tek ekranda; kalemler bellekte,
// Onayla Service.BusinessSaveWithDetails ile tek transaction'da yazılır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Vcl.ComCtrls, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdPacketRaw.Service, PrdPacketRaw,
  PrdPacketRawDetail, PrdPacketRawDetail.Service;

type
  TfrmPrdPacketRawDetail = class(TfrmInputDetailedDB<TPrdPacketRaw, TPrdPacketRawService>)
    pnlContent: TPanel;
    lblPacketName: TLabel;
    edtPacketName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FPageLines: TTabSheet;
    FLines: TDetailSet<TPrdPacketRawDetail>;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache, Grid.Types, ufrmPrdPacketRawLine;

procedure TfrmPrdPacketRawDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.PacketName := edtPacketName.Text;
  inherited;
end;

procedure TfrmPrdPacketRawDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPacketName.thsInputDataType := itString;

  // Kalemler = Table.Lines (satır no sırasıyla)
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.MenuDetails, 'Items'));
  FLines := AddDetail<TPrdPacketRawDetail>(FPageLines, 'vw_prd_packet_raw_detail',
    function: TObjectList<TPrdPacketRawDetail>
    begin
      Result := Table.Lines;
    end,
    function: TPrdPacketRawDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TPrdPacketRawDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TPrdPacketRawDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TPrdPacketRawDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPrdPacketRawLine.Create(Self, TPrdPacketRawDetailService.Create, ALine, AMode, nil);
    end);
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('prd_packet_raw_id', 0);
  FLines.Grid.SetColumnProperty('packet_name', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('sub_prd_bom_id', 0);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 220);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('sub_bom_name', 160);
end;

procedure TfrmPrdPacketRawDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtPacketName.CanFocus then
    edtPacketName.SetFocus;
end;

procedure TfrmPrdPacketRawDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.TitleSingular, 'Raw Material Packet');
  lblPacketName.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.ColPacketName, 'Packet Name');

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.MenuDetails, 'Items');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColInventoryCode, 'Inventory Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColInventoryName, 'Inventory Name'));
    FLines.Grid.SetColumnTitle('sub_bom_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColSubBomName, 'Sub Bom Name'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColQuantity, 'Quantity'));
  end;
end;

procedure TfrmPrdPacketRawDetail.RefreshData;
begin
  inherited;
  edtPacketName.Text := Table.PacketName;
end;

end.
