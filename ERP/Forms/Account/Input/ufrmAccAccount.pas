unit ufrmAccAccount;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  AccAccount.Service, AccAccount;

type
  TfrmAccAccount = class(TfrmInputSimpleDB<TAccAccount, TAccAccountService>)
    pnlContent: TPanel;
    lblcode: TLabel;
    edtcode: TEdit;
    lblname: TLabel;
    edtname: TEdit;
    lbltype_id: TLabel;
    eddtype_id: TEdit;
    btn_type_sec: TButton;
    lblgroup_id: TLabel;
    edtgroup_id: TEdit;
    btn_group_sec: TButton;
    lblregion_id: TLabel;
    edtregion_id: TEdit;
    btn_region_sec: TButton;
    lbntaxpayer_name: TLabel;
    edtaxpayer_name: TEdit;
    lbntaxpayer_surname: TLabel;
    edtaxpayer_surname: TEdit;
    lbntax_no: TLabel;
    edtax_no: TEdit;
    lbntax_office: TLabel;
    edtax_office: TEdit;
    lbliban: TLabel;
    edtiban: TEdit;
    lblfax: TLabel;
    edtfax: TEdit;
    lblaccountant_phone: TLabel;
    edtaccountant_phone: TEdit;
    lblaccountant_email: TLabel;
    edtaccountant_email: TEdit;
    chk_e_invoice_active: TCheckBox;
    lbldiscount_rate: TLabel;
    edtdiscount_rate: TSpinEdit;
  private
    FTypeId: Int64;
    FGroupId: Int64;
    FRegionId: Int64;
    procedure btn_type_secClick(Sender: TObject);
    procedure btn_group_secClick(Sender: TObject);
    procedure btn_region_secClick(Sender: TObject);
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccAccount.BtnAcceptClick(Sender: TObject);
begin
  Table.Code := edtcode.Text;
  Table.Name := edtname.Text;
  Table.TypeId := FTypeId;
  Table.GroupId := FGroupId;
  Table.RegionId := FRegionId;
  Table.TaxpayerName := edtaxpayer_name.Text;
  Table.TaxpayerSurname := edtaxpayer_surname.Text;
  Table.TaxNo := edtax_no.Text;
  Table.TaxOffice := edtax_office.Text;
  Table.IBAN := edtiban.Text;
  Table.Fax := edtfax.Text;
  Table.AccountantPhone := edtaccountant_phone.Text;
  Table.AccountantEmail := edtaccountant_email.Text;
  Table.EInvoiceActive := chk_e_invoice_active.Checked;
  Table.DiscountRate := StrToFloatDef(edtdiscount_rate.Text, 0);
  inherited;
end;

procedure TfrmAccAccount.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  btn_type_sec.OnClick := btn_type_secClick;
  btn_group_sec.OnClick := btn_group_secClick;
  btn_region_sec.OnClick := btn_region_secClick;
end;

procedure TfrmAccAccount.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Account';
  edtcode.SetFocus;
end;

procedure TfrmAccAccount.btn_type_secClick(Sender: TObject);
var
  LId: Int64;
  LName: string;
begin
  // TODO: Show account type selection helper form
  LId := 0;
  LName := '';
  if LId > 0 then
  begin
    FTypeId := LId;
    eddtype_id.Text := LName;
  end;
end;

procedure TfrmAccAccount.btn_group_secClick(Sender: TObject);
var
  LId: Int64;
  LName: string;
begin
  // TODO: Show group selection helper form (ufrmAccGroups)
  LId := 0;
  LName := '';
  if LId > 0 then
  begin
    FGroupId := LId;
    edtgroup_id.Text := LName;
  end;
end;

procedure TfrmAccAccount.btn_region_secClick(Sender: TObject);
var
  LId: Int64;
  LName: string;
begin
  // TODO: Show region selection helper form (ufrmAccRegions)
  LId := 0;
  LName := '';
  if LId > 0 then
  begin
    FRegionId := LId;
    edtregion_id.Text := LName;
  end;
end;

procedure TfrmAccAccount.RefreshData;
begin
  inherited;
  edtcode.Text := Table.Code;
  edtname.Text := Table.Name;
  eddtype_id.Text := Table.TypeId.ToString;
  edtgroup_id.Text := Table.GroupId.ToString;
  edtregion_id.Text := Table.RegionId.ToString;
  FTypeId := Table.TypeId;
  FGroupId := Table.GroupId;
  FRegionId := Table.RegionId;
  edtaxpayer_name.Text := Table.TaxpayerName;
  edtaxpayer_surname.Text := Table.TaxpayerSurname;
  edtax_no.Text := Table.TaxNo;
  edtax_office.Text := Table.TaxOffice;
  edtiban.Text := Table.IBAN;
  edtfax.Text := Table.Fax;
  edtaccountant_phone.Text := Table.AccountantPhone;
  edtaccountant_email.Text := Table.AccountantEmail;
  chk_e_invoice_active.Checked := Table.EInvoiceActive;
  edtdiscount_rate.Text := FloatToStr(Table.DiscountRate);
end;

end.
