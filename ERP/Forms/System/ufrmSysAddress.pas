unit ufrmSysAddress;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysAddress.Service, SysAddress;

type
  TfrmSysAddress = class(TfrmInputSimpleDB<TSysAddress, TSysAddressService>)
    pnlContent: TPanel;
    lblcity_id: TLabel;
    edtcity_id: TEdit;
    btncity_sec: TButton;
    lbldistrict: TLabel;
    edtdistrict: TEdit;
    lblneighborhood: TLabel;
    edtneighborhood: TEdit;
    lblquarter: TLabel;
    edtquarter: TEdit;
    lblroad: TLabel;
    edtroad: TEdit;
    lblstreet: TLabel;
    edtstreet: TEdit;
    lblbuilding_name: TLabel;
    edtbuilding_name: TEdit;
    lbldoor_number: TLabel;
    edtdoor_number: TEdit;
    lblzip_code: TLabel;
    edtzip_code: TEdit;
    lblweb: TLabel;
    edtweb: TEdit;
    lblemail: TLabel;
    edtemail: TEdit;
  private
    FCityId: Int64;
    procedure btncity_secClick(Sender: TObject);
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysAddress.BtnAcceptClick(Sender: TObject);
begin
  Table.CityId := FCityId;
  Table.District := edtdistrict.Text;
  Table.Neighborhood := edtneighborhood.Text;
  Table.Quarter := edtquarter.Text;
  Table.Road := edtroad.Text;
  Table.Street := edtstreet.Text;
  Table.BuildingName := edtbuilding_name.Text;
  Table.DoorNumber := edtdoor_number.Text;
  Table.ZipCode := edtzip_code.Text;
  Table.Web := edtweb.Text;
  Table.Email := edtemail.Text;
  inherited;
end;

procedure TfrmSysAddress.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  btncity_sec.OnClick := btncity_secClick;
end;

procedure TfrmSysAddress.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Address';
  edtdistrict.SetFocus;
end;

procedure TfrmSysAddress.btncity_secClick(Sender: TObject);
var
  LId: Int64;
  LName: string;
begin
  // TODO: Show city selection helper form (ufrmSysCities)
  LId := 0;
  LName := '';
  if LId > 0 then
  begin
    FCityId := LId;
    edtcity_id.Text := LName;
  end;
end;

procedure TfrmSysAddress.RefreshData;
begin
  inherited;
  edtcity_id.Text := Table.CityId.ToString;
  edtdistrict.Text := Table.District;
  edtneighborhood.Text := Table.Neighborhood;
  edtquarter.Text := Table.Quarter;
  edtroad.Text := Table.Road;
  edtstreet.Text := Table.Street;
  edtbuilding_name.Text := Table.BuildingName;
  edtdoor_number.Text := Table.DoorNumber;
  edtzip_code.Text := Table.ZipCode;
  edtweb.Text := Table.Web;
  edtemail.Text := Table.Email;
  FCityId := Table.CityId;
end;

end.
