unit ufrmPrdBomPacketRaw;

// Reçete kalem satır formu (TfrmPrdBomDetail'den modal): bellekteki satırı düzenler, DB'ye reçeteyle birlikte yazılır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdBomPacketRaw.Service, PrdBomPacketRaw;

type
  TfrmPrdBomPacketRaw = class(TfrmInputLineDB<TPrdBomPacketRaw, TPrdBomPacketRawService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblPrdPacketRawId: TLabel;
    edtPrdPacketRawId: TEdit;
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
  PrdPacketRaw, PrdPacketRaw.Service, ufrmPrdPacketRaws;                        // TfrmPrdPacketRaws helper output form

procedure TfrmPrdBomPacketRaw.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; başlık (belge) ana formdan gelir, formda gösterilmez
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdBomPacketRaw.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtPrdPacketRawId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
end;

procedure TfrmPrdBomPacketRaw.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuantity.CanFocus then
    edtQuantity.SetFocus;
end;

procedure TfrmPrdBomPacketRaw.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.TitleSingular, 'BoM Raw Material Packet');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColLineNo, 'Line No');
  lblPrdPacketRawId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColPrdPacketRawId, 'Raw Material Packet');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColQuantity, 'Quantity');
end;

procedure TfrmPrdBomPacketRaw.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdPacketRawId: TfrmPrdPacketRaws;
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
  end;
end;

procedure TfrmPrdBomPacketRaw.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtPrdPacketRawId.Text := Table.PacketName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
