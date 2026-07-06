unit ufrmAccBank;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  AccBank.Service, AccBank;

type
  TfrmAccBank = class(TfrmInputSimpleDB<TAccBank, TAccBankService>)
    pnlContent: TPanel;
    lblbanka_adi: TLabel;
    edtbanka_adi: TEdit;
    lblswift_kodu: TLabel;
    edtswift_kodu: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccBank.BtnAcceptClick(Sender: TObject);
begin
  Table.Name := edtbanka_adi.Text;
  Table.SWiftCode := edtswift_kodu.Text;
  inherited;
end;

procedure TfrmAccBank.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmAccBank.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Banka';
  edtbanka_adi.SetFocus;
end;

procedure TfrmAccBank.RefreshData;
begin
  inherited;
  edtbanka_adi.Text := Table.Name;
  edtswift_kodu.Text := Table.SWiftCode;
end;

end.
