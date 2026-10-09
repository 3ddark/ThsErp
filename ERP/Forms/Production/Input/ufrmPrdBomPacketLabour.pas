unit ufrmPrdBomPacketLabour;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdBomPacketLabour.Service, PrdBomPacketLabour;

type
  TfrmPrdBomPacketLabour = class(TfrmInputSimpleDB<TPrdBomPacketLabour, TPrdBomPacketLabourService>)
    pnlContent: TPanel;
    lblPrdBomId: TLabel;
    edtPrdBomId: TEdit;
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
  PrdBom, PrdBom.Service, ufrmPrdBoms,                                          // TfrmPrdBoms helper output form
  PrdPacketLabour, PrdPacketLabour.Service, ufrmPrdPacketLabours;               // TfrmPrdPacketLabours helper output form

procedure TfrmPrdBomPacketLabour.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdBomPacketLabour.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPrdPacketLabourId.OnHelperProcess := HelperProcess;
  edtPrdBomId.OnHelperProcess := HelperProcess;
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
  lblPrdBomId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColPrdBomId, 'BoM');
  lblPrdPacketLabourId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColPrdPacketLabourId, 'Labour Packet');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColQuantity, 'Quantity');
end;

procedure TfrmPrdBomPacketLabour.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdBomId: TfrmPrdBoms;
  LFrmPrdPacketLabourId: TfrmPrdPacketLabours;
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
  else if LEdit.Name = edtPrdPacketLabourId.Name then
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
  edtPrdBomId.Text := Table.BomName;
  edtPrdPacketLabourId.Text := Table.PacketName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
