unit ufrmAccRegion;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  AccRegion.Service, AccRegion;

type
  TfrmAccRegion = class(TfrmInputSimpleDB<TAccRegion, TAccRegionService>)
    pnlContent: TPanel;
    lblbolge: TLabel;
    edtbolge: TEdit;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccRegion.BtnAcceptClick(Sender: TObject);
begin
  Table.Name := edtbolge.Text;
  inherited;
end;

procedure TfrmAccRegion.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmAccRegion.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Bölge';
  edtbolge.SetFocus;
end;

procedure TfrmAccRegion.RefreshData;
begin
  inherited;
  edtbolge.Text := Table.Name;
end;

end.
