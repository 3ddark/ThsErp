unit ufrmSysCity;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysCity.Service, SysCity,
  SysCountry.Service, SysCountry, ufrmSysCountries,
  SysRegion.Service, SysRegion, ufrmSysRegions;

type
  TfrmSysCity = class(TfrmInputSimpleDB<TSysCity, TSysCityService>)
    pnlContent: TPanel;
    lblcity_name: TLabel;
    edtcity_name: TEdit;
    lblcar_plate_code: TLabel;
    edtcar_plate_code: TEdit;
    lblcountry_id: TLabel;
    edtcountry_id: TEdit;
    lblregion_id: TLabel;
    edtregion_id: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;

  published
    procedure BtnAcceptClick(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure HelperProcess(Sender: TObject);
    procedure InitializeInputCase; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysCity.BtnAcceptClick(Sender: TObject);
begin
  Table.CityName := edtcity_name.Text;
  Table.CarPlateCode := StrToIntDef(edtcar_plate_code.Text, 0);
  inherited;
end;

procedure TfrmSysCity.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtcountry_id.OnHelperProcess := HelperProcess;
  edtregion_id.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysCity.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System City';

  edtcity_name.SetFocus;
end;

procedure TfrmSysCity.HelperProcess(Sender: TObject);
var
  LFrmCountry: TfrmSysCountries;
  LFrmRegion: TfrmSysRegions;
begin
  if Sender is TEdit then
  begin
    if (Sender as TEdit).Name = edtcountry_id.Name then
    begin
      LFrmCountry := TfrmSysCountries.Create((Sender as TEdit), TSysCountryService.Create, TSysCountry.Create);
      try
        LFrmCountry.IsHelper := True;
        LFrmCountry.ShowModal;
        if LFrmCountry.DataAktar then
        begin
          if LFrmCountry.CleanAndClose then
          begin
            Table.CountryId := 0;
            (Sender as TEdit).Clear;
          end
          else
          begin
            Table.CountryId := LFrmCountry.Table.Id;
            (Sender as TEdit).Text := LFrmCountry.Table.CountryName;
          end;
        end;
      finally
        LFrmCountry.Free;
      end;
    end
    else if (Sender as TEdit).Name = edtregion_id.Name then
    begin
      LFrmRegion := TfrmSysRegions.Create((Sender as TEdit), TSysRegionService.Create, TSysRegion.Create);
      try
        LFrmRegion.IsHelper := True;
        LFrmRegion.ShowModal;
        if LFrmRegion.DataAktar then
        begin
          if LFrmRegion.CleanAndClose then
          begin
            Table.RegionId := 0;
            (Sender as TEdit).Clear;
          end
          else
          begin
            Table.RegionId := LFrmRegion.Table.Id;
            (Sender as TEdit).Text := LFrmRegion.Table.RegionName;
          end;
        end;
      finally
        LFrmRegion.Free;
      end;
    end;
  end;
end;

procedure TfrmSysCity.InitializeInputCase;
begin
  inherited;
  edtcity_name.thsInputDataType := itString;
  edtcar_plate_code.thsInputDataType := itInteger;
  edtcountry_id.thsInputDataType := itInteger;
  edtregion_id.thsInputDataType := itInteger;

  edtcity_name.MaxLength := 32;
end;

procedure TfrmSysCity.RefreshData;
begin
  inherited;
  edtcity_name.Text := Table.CityName;
  edtcar_plate_code.Text := IntToStr(Table.CarPlateCode);
  edtcountry_id.Text := Table.Country.CountryName;
  edtregion_id.Text := Table.Region.RegionName;
end;

end.

