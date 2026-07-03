unit ufrmAccBankBranch;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,
  AccBankBranch.Service, AccBankBranch;

type
  TfrmAccBankBranch = class(TfrmInputSimpleDB<TAccBankBranch, TAccBankBranchService>)
    pnlContent: TPanel;
    lblsube_kodu: TLabel;
    edtsube_kodu: TEdit;
    lblsube_adi: TLabel;
    edtsube_adi: TEdit;
    lblbanka: TLabel;
    btnbanka_sec: TButton;
    edtbanka_adi: TEdit;
    lblsehir: TLabel;
    btnsehir_sec: TButton;
    edtsehir_adi: TEdit;
  private
    FBankId: Int64;
    FCityId: Int64;
    procedure btnbanka_secClick(Sender: TObject);
    procedure btnsehir_secClick(Sender: TObject);
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccBankBranch.BtnAcceptClick(Sender: TObject);
begin
  Table.Code := StrToIntDef(edtsube_kodu.Text, 0);
  Table.Name := edtsube_adi.Text;
  Table.BankId := FBankId;
  Table.CityId := FCityId;
  inherited;
end;

procedure TfrmAccBankBranch.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  btnbanka_sec.OnClick := btnbanka_secClick;
  btnsehir_sec.OnClick := btnsehir_secClick;
end;

procedure TfrmAccBankBranch.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Banka Şubesi';
  edtsube_kodu.SetFocus;
end;

procedure TfrmAccBankBranch.btnbanka_secClick(Sender: TObject);
var
  LId: Int64;
  LName: string;
begin
  // TODO: Show bank selection helper form (ufrmAccBanks)
  // For now, use a placeholder
  LId := 0;
  LName := '';
  if LId > 0 then
  begin
    FBankId := LId;
    edtbanka_adi.Text := LName;
  end;
end;

procedure TfrmAccBankBranch.btnsehir_secClick(Sender: TObject);
var
  LId: Int64;
  LName: string;
begin
  // TODO: Show city selection helper form (ufrmSysSehirler)
  // For now, use a placeholder
  LId := 0;
  LName := '';
  if LId > 0 then
  begin
    FCityId := LId;
    edtsehir_adi.Text := LName;
  end;
end;

procedure TfrmAccBankBranch.RefreshData;
begin
  inherited;
  edtsube_kodu.Text := IntToStr(Table.Code);
  edtsube_adi.Text := Table.Name;
  FBankId := Table.BankId;
  FCityId := Table.CityId;
  // TODO: Load bank name from Table.Bank if available
  edtbanka_adi.Text := '';
  // TODO: Load city name from related table if available
  edtsehir_adi.Text := '';
end;

end.
