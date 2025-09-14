unit ufrmSysCity;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysCity.Service, SysCity, Vcl.ExtCtrls;

type
  TfrmSysCity = class(TfrmInputSimpleDbX<TSysCity, TSysCityService>)
    pnlMain: TPanel;
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
  end;

implementation

{$R *.dfm}

procedure TfrmSysCity.BtnAcceptClick(Sender: TObject);
begin
  Table.CityName.Value := edtcity_name.Text;
  Table.CarPlateCode.Value := StrToIntDef(edtcar_plate_code.Text, 0);
  inherited;
end;

procedure TfrmSysCity.FormCreate(Sender: TObject);
begin
  inherited;

  pnlMain.Parent := PanelMain;
  PanelMain := pnlMain;
end;

procedure TfrmSysCity.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System City';

  edtcity_name.SetFocus;
end;

procedure TfrmSysCity.RefreshData;
begin
  inherited;
  edtcity_name.Text := Table.CityName.Value;
  edtcar_plate_code.Text := Table.CarPlateCode.Value.ToString;
end;

end.

