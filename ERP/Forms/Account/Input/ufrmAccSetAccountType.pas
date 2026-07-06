unit ufrmAccSetAccountType;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SetAccAccountType.Service, SetAccAccountType;

type
  TfrmAccSetAccountType = class(TfrmInputSimpleDB<TSetAccAccountType, TSetAccAccountTypeService>)
    pnlContent: TPanel;
    lblname: TLabel;
    edtname: TEdit;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccSetAccountType.BtnAcceptClick(Sender: TObject);
begin
  Table.Name := edtname.Text;
  inherited;
end;

procedure TfrmAccSetAccountType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmAccSetAccountType.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Account Type';
  edtname.SetFocus;
end;

procedure TfrmAccSetAccountType.RefreshData;
begin
  inherited;
  edtname.Text := Table.Name;
end;

end.
