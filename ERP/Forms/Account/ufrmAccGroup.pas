unit ufrmAccGroup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  AccGroup.Service, AccGroup;

type
  TfrmAccGroup = class(TfrmInputSimpleDB<TAccGroup, TAccGroupService>)
    pnlContent: TPanel;
    lblgrup: TLabel;
    edtgrup: TEdit;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccGroup.BtnAcceptClick(Sender: TObject);
begin
  Table.Name := edtgrup.Text;
  inherited;
end;

procedure TfrmAccGroup.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmAccGroup.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Hesap Grubu';
  edtgrup.SetFocus;
end;

procedure TfrmAccGroup.RefreshData;
begin
  inherited;
  edtgrup.Text := Table.Name;
end;

end.
