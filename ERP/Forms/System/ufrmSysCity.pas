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
    lblCityName: TLabel;
    lblCarPlateCode: TLabel;
    lblCountryId: TLabel;
    lblRegionId: TLabel;
    edtCityName: TEdit;
    edtCarPlateCode: TEdit;
    edtCountryId: TEdit;
    edtRegionId: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysCity.BtnAcceptClick(Sender: TObject);
begin
  Table.CityName := edtCityName.Text;
  Table.CarPlateCode := StrToIntDef(edtCarPlateCode.Text, 0);
  inherited;
end;

procedure TfrmSysCity.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCountryId.OnHelperProcess := HelperProcess;
  edtRegionId.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysCity.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System City';

  edtCityName.SetFocus;
end;

procedure TfrmSysCity.HelperProcess(Sender: TObject);
var
  LFrmCountry: TfrmSysCountries;
  LFrmRegion: TfrmSysRegions;
begin
  if Sender is TEdit then
  begin
    if (Sender as TEdit).Name = edtCountryId.Name then
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
    else if (Sender as TEdit).Name = edtRegionId.Name then
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
  edtCityName.thsInputDataType := itString;
  edtCarPlateCode.thsInputDataType := itInteger;
  edtCountryId.thsInputDataType := itInteger;
  edtRegionId.thsInputDataType := itInteger;

  edtCityName.MaxLength := 32;
end;

procedure TfrmSysCity.RefreshData;
begin
  inherited;
  edtCityName.Text := Table.CityName;
  edtCarPlateCode.Text := IntToStr(Table.CarPlateCode);
  edtCountryId.Text := Table.Country.CountryName;
  edtRegionId.Text := Table.Region.RegionName;
end;

end.
