unit ufrmPrdPacketLabourLine;

// Paket kalemi satır formu (TfrmPrdPacketLabourLine'den modal): bellekteki satırı düzenler, DB'ye paketle birlikte yazılır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdPacketLabourDetail.Service, PrdPacketLabourDetail;

type
  TfrmPrdPacketLabourLine = class(TfrmInputLineDB<TPrdPacketLabourDetail, TPrdPacketLabourDetailService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblPrdLabourId: TLabel;
    edtPrdLabourId: TEdit;
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
  PrdLabour, PrdLabour.Service, ufrmPrdLabours;                                 // TfrmPrdLabours helper output form

procedure TfrmPrdPacketLabourLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; başlık (belge) ana formdan gelir, formda gösterilmez
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdPacketLabourLine.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtPrdLabourId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
end;

procedure TfrmPrdPacketLabourLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuantity.CanFocus then
    edtQuantity.SetFocus;
end;

procedure TfrmPrdPacketLabourLine.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.TitleSingular, 'Labour Packet Item');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColLineNo, 'Line No');
  lblPrdLabourId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColPrdLabourId, 'Labour / Cost');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColQuantity, 'Quantity');
end;

procedure TfrmPrdPacketLabourLine.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdLabourId: TfrmPrdLabours;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPrdLabourId.Name then
  begin
    LFrmPrdLabourId := TfrmPrdLabours.Create(LEdit, TPrdLabourService.Create, TPrdLabour.Create);
    try
      LFrmPrdLabourId.IsHelper := True;
      LFrmPrdLabourId.ShowModal;
      if LFrmPrdLabourId.DataTransfer then
        if LFrmPrdLabourId.CleanAndClose then
        begin
          Table.PrdLabourId := 0;
          Table.LabourName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PrdLabourId := LFrmPrdLabourId.Table.Id;
          Table.LabourName := LFrmPrdLabourId.Table.Name;
          LEdit.Text := Table.LabourName;
        end;
    finally
      LFrmPrdLabourId.Free;
    end;
  end;
end;

procedure TfrmPrdPacketLabourLine.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtPrdLabourId.Text := Table.LabourName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
