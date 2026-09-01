unit ufrmSysAddress;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysAddress.Service, SysAddress, SysCity, SysCity.Service, LocalizationManager;

type
  TfrmSysAddress = class(TfrmInputSimpleDB<TSysAddress, TSysAddressService>)
    pnlContent: TPanel;
    lblCityId: TLabel;
    edtCityId: TEdit;
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
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmSysCities;

procedure TfrmSysAddress.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmCity: TfrmSysCities;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtCityId.Name then
    begin
      LFrmCity := TfrmSysCities.Create(LEdit, TSysCityService.Create, TSysCity.Create);
      try
        LFrmCity.IsHelper := True;
        LFrmCity.ShowModal;
        if LFrmCity.DataTransfer then
          if LFrmCity.CleanAndClose then
          begin
            Table.SysCityId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.SysCityId := LFrmCity.Table.Id;
            LEdit.Text := LFrmCity.Table.CityName;
          end;
      finally
        LFrmCity.Free;
      end;
    end;
  end;
end;

procedure TfrmSysAddress.BtnAcceptClick(Sender: TObject);
begin
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
  edtCityId.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysAddress.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtDistrict.SetFocus;
end;

procedure TfrmSysAddress.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.TitleSingular, 'Address');
  lblCityId.Caption := TLocalizationManager.Translate(TLangKeys.TSysCity.ColCityName, 'City Name');
  lblDistrict.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColDistrict, 'District');
  lblNeighborhood.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColNeighborhood, 'Neighborhood');
  lblQuarter.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColQuarter, 'Quarter');
  lblRoad.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColRoad, 'Road');
  lblStreet.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColStreet, 'Street');
  lblBuildingName.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColBuildingName, 'Building Name');
  lblDoorNumber.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColDoorNumber, 'Door Number');
  lblZipCode.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColZipCode, 'Zip Code');
  lblWeb.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColWeb, 'Web');
  lblEmail.Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColEmail, 'e-Mail');
end;

procedure TfrmSysAddress.RefreshData;
begin
  inherited;
  edtCityId.Text := Table.SysCity.CityName;
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
end;

end.
