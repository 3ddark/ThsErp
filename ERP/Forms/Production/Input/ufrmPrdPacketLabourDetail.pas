unit ufrmPrdPacketLabourDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdPacketLabourDetail.Service, PrdPacketLabourDetail;

type
  TfrmPrdPacketLabourDetail = class(TfrmInputSimpleDB<TPrdPacketLabourDetail, TPrdPacketLabourDetailService>)
    pnlContent: TPanel;
    lblPrdPacketLabourId: TLabel;
    edtPrdPacketLabourId: TEdit;
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
  PrdPacketLabour, PrdPacketLabour.Service, ufrmPrdPacketLabours,               // TfrmPrdPacketLabours helper output form
  PrdLabour, PrdLabour.Service, ufrmPrdLabours;                                 // TfrmPrdLabours helper output form

procedure TfrmPrdPacketLabourDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdPacketLabourDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPrdLabourId.OnHelperProcess := HelperProcess;
  edtPrdPacketLabourId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
end;

procedure TfrmPrdPacketLabourDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuantity.CanFocus then
    edtQuantity.SetFocus;
end;

procedure TfrmPrdPacketLabourDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.TitleSingular, 'Labour Packet Item');
  lblPrdPacketLabourId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColPrdPacketLabourId, 'Packet');
  lblPrdLabourId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColPrdLabourId, 'Labour / Cost');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.ColQuantity, 'Quantity');
end;

procedure TfrmPrdPacketLabourDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdPacketLabourId: TfrmPrdPacketLabours;
  LFrmPrdLabourId: TfrmPrdLabours;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPrdPacketLabourId.Name then
  begin
    LFrmPrdPacketLabourId := TfrmPrdPacketLabours.Create(LEdit, TPrdPacketLabourService.Create, TPrdPacketLabour.Create);
    try
      LFrmPrdPacketLabourId.IsHelper := True;
      LFrmPrdPacketLabourId.ShowModal;
      if LFrmPrdPacketLabourId.DataTransfer then
        if LFrmPrdPacketLabourId.CleanAndClose then
        begin
          Table.PrdPacketLabourId := 0;
          Table.PacketName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PrdPacketLabourId := LFrmPrdPacketLabourId.Table.Id;
          Table.PacketName := LFrmPrdPacketLabourId.Table.PacketName;
          LEdit.Text := Table.PacketName;
        end;
    finally
      LFrmPrdPacketLabourId.Free;
    end;
  end
  else if LEdit.Name = edtPrdLabourId.Name then
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

procedure TfrmPrdPacketLabourDetail.RefreshData;
begin
  inherited;
  edtPrdPacketLabourId.Text := Table.PacketName;
  edtPrdLabourId.Text := Table.LabourName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
