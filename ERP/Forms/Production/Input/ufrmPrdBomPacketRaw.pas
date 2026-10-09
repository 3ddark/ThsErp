unit ufrmPrdBomPacketRaw;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdBomPacketRaw.Service, PrdBomPacketRaw;

type
  TfrmPrdBomPacketRaw = class(TfrmInputSimpleDB<TPrdBomPacketRaw, TPrdBomPacketRawService>)
    pnlContent: TPanel;
    lblPrdBomId: TLabel;
    edtPrdBomId: TEdit;
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
  PrdBom, PrdBom.Service, ufrmPrdBoms,                                          // TfrmPrdBoms helper output form
  PrdPacketRaw, PrdPacketRaw.Service, ufrmPrdPacketRaws;                        // TfrmPrdPacketRaws helper output form

procedure TfrmPrdBomPacketRaw.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdBomPacketRaw.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPrdPacketRawId.OnHelperProcess := HelperProcess;
  edtPrdBomId.OnHelperProcess := HelperProcess;
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
  lblPrdBomId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColPrdBomId, 'BoM');
  lblPrdPacketRawId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColPrdPacketRawId, 'Raw Material Packet');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColQuantity, 'Quantity');
end;

procedure TfrmPrdBomPacketRaw.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdBomId: TfrmPrdBoms;
  LFrmPrdPacketRawId: TfrmPrdPacketRaws;
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
  else if LEdit.Name = edtPrdPacketRawId.Name then
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
  edtPrdBomId.Text := Table.BomName;
  edtPrdPacketRawId.Text := Table.PacketName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
