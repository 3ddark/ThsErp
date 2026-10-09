unit ufrmPrdPacketRaw;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdPacketRaw.Service, PrdPacketRaw;

type
  TfrmPrdPacketRaw = class(TfrmInputSimpleDB<TPrdPacketRaw, TPrdPacketRawService>)
    pnlContent: TPanel;
    lblPacketName: TLabel;
    edtPacketName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmPrdPacketRaw.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.PacketName := edtPacketName.Text;
  inherited;
end;

procedure TfrmPrdPacketRaw.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPacketName.thsInputDataType := itString;
end;

procedure TfrmPrdPacketRaw.FormShow(Sender: TObject);
begin
  inherited;
  if edtPacketName.CanFocus then
    edtPacketName.SetFocus;
end;

procedure TfrmPrdPacketRaw.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.TitleSingular, 'Raw Material Packet');
  lblPacketName.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.ColPacketName, 'Packet Name');
end;

procedure TfrmPrdPacketRaw.RefreshData;
begin
  inherited;
  edtPacketName.Text := Table.PacketName;
end;

end.
