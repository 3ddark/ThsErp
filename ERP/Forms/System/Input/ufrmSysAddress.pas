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
    lblCityId: TLabel;
    edtCityId: TEdit;
    btnCitySelect: TButton;
    lblDistrict: TLabel;
    edtDistrict: TEdit;
    lblNeighborhood: TLabel;
    edtNeighborhood: TEdit;
    lblQuarter: TLabel;
    edtQuarter: TEdit;
    lblRoad: TLabel;
    edtRoad: TEdit;
    lblStreet: TLabel;
    edtStreet: TEdit;
    lblBuildingName: TLabel;
    edtBuildingName: TEdit;
    lblDoorNumber: TLabel;
    edtDoorNumber: TEdit;
    lblZipCode: TLabel;
    edtZipCode: TEdit;
    lblWeb: TLabel;
    edtWeb: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
  private
    FCityId: Int64;
    procedure btnCitySelectClick(Sender: TObject);
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysAddress.BtnAcceptClick(Sender: TObject);
begin
  Table.CityId := FCityId;
  Table.District := edtDistrict.Text;
  Table.Neighborhood := edtNeighborhood.Text;
  Table.Quarter := edtQuarter.Text;
  Table.Road := edtRoad.Text;
  Table.Street := edtStreet.Text;
  Table.BuildingName := edtBuildingName.Text;
  Table.DoorNumber := edtDoorNumber.Text;
  Table.ZipCode := edtZipCode.Text;
  Table.Web := edtWeb.Text;
  Table.Email := edtEmail.Text;
  inherited;
end;

procedure TfrmSysAddress.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  btnCitySelect.OnClick := btnCitySelectClick;
end;

procedure TfrmSysAddress.InitializeInputCase;
begin
  inherited;
  edtCityId.thsInputDataType := itInteger;
  edtDoorNumber.thsInputDataType := itInteger;
  edtZipCode.thsInputDataType := itInteger;
end;

procedure TfrmSysAddress.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Address';
  edtDistrict.SetFocus;
end;

procedure TfrmSysAddress.btnCitySelectClick(Sender: TObject);
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
    edtCityId.Text := LName;
  end;
end;

procedure TfrmSysAddress.RefreshData;
begin
  inherited;
  edtCityId.Text := Table.CityId.ToString;
  edtDistrict.Text := Table.District;
  edtNeighborhood.Text := Table.Neighborhood;
  edtQuarter.Text := Table.Quarter;
  edtRoad.Text := Table.Road;
  edtStreet.Text := Table.Street;
  edtBuildingName.Text := Table.BuildingName;
  edtDoorNumber.Text := Table.DoorNumber;
  edtZipCode.Text := Table.ZipCode;
  edtWeb.Text := Table.Web;
  edtEmail.Text := Table.Email;
  FCityId := Table.CityId;
end;

end.
