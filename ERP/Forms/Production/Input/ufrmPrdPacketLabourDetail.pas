unit ufrmPrdPacketLabourDetail;

// İşçilik paketi: başlık (prd_packet_labour) + kalemler (Table.Lines, prd_packet_labour_detail) tek ekranda; kalemler
// bellekte, Onayla Service.BusinessSaveWithDetails ile tek transaction'da yazılır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Vcl.ComCtrls, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdPacketLabour.Service, PrdPacketLabour,
  PrdPacketLabourDetail, PrdPacketLabourDetail.Service;

type
  TfrmPrdPacketLabourDetail = class(TfrmInputDetailedDB<TPrdPacketLabour, TPrdPacketLabourService>)
    pnlContent: TPanel;
    lblPacketName: TLabel;
    edtPacketName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FPageLines: TTabSheet;
    FLines: TDetailSet<TPrdPacketLabourDetail>;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache, Grid.Types, ufrmPrdPacketLabourLine;

procedure TfrmPrdPacketLabourDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.PacketName := edtPacketName.Text;
  inherited;
end;

procedure TfrmPrdPacketLabourDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPacketName.thsInputDataType := itString;

  // Kalemler = Table.Lines (satır no sırasıyla)
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.MenuDetails, 'Items'));
  FLines := AddDetail<TPrdPacketLabourDetail>(FPageLines, 'vw_prd_packet_labour_detail',
    function: TObjectList<TPrdPacketLabourDetail>
    begin
      Result := Table.Lines;
    end,
    function: TPrdPacketLabourDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TPrdPacketLabourDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TPrdPacketLabourDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TPrdPacketLabourDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPrdPacketLabourLine.Create(Self, TPrdPacketLabourDetailService.Create, ALine, AMode, nil);
    end);
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('prd_packet_labour_id', 0);
  FLines.Grid.SetColumnProperty('packet_name', 0);
  FLines.Grid.SetColumnProperty('prd_labour_id', 0);
  FLines.Grid.SetColumnProperty('labour_code', 90);
  FLines.Grid.SetColumnProperty('labour_name', 220);
  FLines.Grid.SetColumnProperty('line_no', 50);
end;

procedure TfrmPrdPacketLabourDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtPacketName.CanFocus then
    edtPacketName.SetFocus;
end;

procedure TfrmPrdPacketLabourDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.TitleSingular, 'Labour Packet');
  lblPacketName.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.ColPacketName, 'Packet Name');

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.MenuDetails, 'Items');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('labour_code', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColLabourCode, 'Labour Code'));
    FLines.Grid.SetColumnTitle('labour_name', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColLabourName, 'Labour Name'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColUnitPrice, 'Unit Price'));
    FLines.Grid.SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColCurrency, 'Currency'));
    FLines.Grid.SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColTotalAmount, 'Total Amount'));
  end;
end;

procedure TfrmPrdPacketLabourDetail.RefreshData;
begin
  inherited;
  edtPacketName.Text := Table.PacketName;
end;

end.
