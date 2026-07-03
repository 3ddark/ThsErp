unit ufrmAccAccountLookup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,
  AccAccount.Service, AccAccount;

type
  TfrmAccAccountLookup = class(TfrmInputSimpleDB<TAccAccount, TAccAccountService>)
    pnlContent: TPanel;
    lblroot_code: TLabel;
    edtroot_code: TEdit;
    lblintermediate_code: TLabel;
    cbbintermediate_code: TComboBox;
    lblfinal_code: TLabel;
    edtfinal_code: TEdit;
    lblaccount_name: TLabel;
    edtaccount_name: TEdit;
  private
    procedure fillIntermediateCodes;
    function getAccountCode: string;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure edtroot_codeExit(Sender: TObject);
    procedure cbbintermediate_codeExit(Sender: TObject);
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccAccountLookup.BtnAcceptClick(Sender: TObject);
begin
  // Return the constructed account code and name to parent form
  inherited;
end;

procedure TfrmAccAccountLookup.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmAccAccountLookup.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Select Account';
  edtroot_code.SetFocus;
  fillIntermediateCodes;
end;

procedure TfrmAccAccountLookup.edtroot_codeExit(Sender: TObject);
begin
  edtfinal_code.Text := getAccountCode;
end;

procedure TfrmAccAccountLookup.cbbintermediate_codeExit(Sender: TObject);
begin
  edtfinal_code.Text := getAccountCode;
end;

procedure TfrmAccAccountLookup.fillIntermediateCodes;
var
  n1: Integer;
begin
  cbbintermediate_code.Clear;
  for n1 := 1 to 100 do
    cbbintermediate_code.Items.Add(Format('%.*d', [3, n1]));
end;

function TfrmAccAccountLookup.getAccountCode: string;
begin
  Result := edtroot_code.Text + '-' + cbbintermediate_code.Text + '-' + edtfinal_code.Text;
end;

procedure TfrmAccAccountLookup.RefreshData;
begin
  inherited;
  edtroot_code.Text := Table.Code; // Root code portion
  edtaccount_name.Text := Table.Name;
end;

end.
