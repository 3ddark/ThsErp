unit ufrmPrdBomPacketLabour;

// Reçete kalem satır formu (TfrmPrdBomDetail'den modal): bellekteki satırı düzenler, DB'ye reçeteyle birlikte yazılır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdBomPacketLabour.Service, PrdBomPacketLabour;

type
  TfrmPrdBomPacketLabour = class(TfrmInputLineDB<TPrdBomPacketLabour, TPrdBomPacketLabourService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblPrdPacketLabourId: TLabel;
    edtPrdPacketLabourId: TEdit;
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
  PrdPacketLabour, PrdPacketLabour.Service, ufrmPrdPacketLabours;               // TfrmPrdPacketLabours helper output form

procedure TfrmPrdBomPacketLabour.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; başlık (belge) ana formdan gelir, formda gösterilmez
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdBomPacketLabour.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtPrdPacketLabourId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
end;

procedure TfrmPrdBomPacketLabour.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuantity.CanFocus then
    edtQuantity.SetFocus;
end;

procedure TfrmPrdBomPacketLabour.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.TitleSingular, 'BoM Labour Packet');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColLineNo, 'Line No');
  lblPrdPacketLabourId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColPrdPacketLabourId, 'Labour Packet');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColQuantity, 'Quantity');
end;

procedure TfrmPrdBomPacketLabour.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdPacketLabourId: TfrmPrdPacketLabours;
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
  end;
end;

procedure TfrmPrdBomPacketLabour.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtPrdPacketLabourId.Text := Table.PacketName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
