unit ufrmPrdPacketLabour;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdPacketLabour.Service, PrdPacketLabour;

type
  TfrmPrdPacketLabour = class(TfrmInputSimpleDB<TPrdPacketLabour, TPrdPacketLabourService>)
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

procedure TfrmPrdPacketLabour.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.PacketName := edtPacketName.Text;
  inherited;
end;

procedure TfrmPrdPacketLabour.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPacketName.thsInputDataType := itString;
end;

procedure TfrmPrdPacketLabour.FormShow(Sender: TObject);
begin
  inherited;
  if edtPacketName.CanFocus then
    edtPacketName.SetFocus;
end;

procedure TfrmPrdPacketLabour.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.TitleSingular, 'Labour Packet');
  lblPacketName.Caption := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.ColPacketName, 'Packet Name');
end;

procedure TfrmPrdPacketLabour.RefreshData;
begin
  inherited;
  edtPacketName.Text := Table.PacketName;
end;

end.
