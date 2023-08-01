unit ufrmSetEmpDrivingLicence;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetEmpDrivingLicence = class(TfrmBaseInputDB)
    lbldriving_licence: TLabel;
    edtdriving_licence: TEdit;
  published
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  ufrmSetEmpDrivingLicences,
  Ths.Database.Table.SetPrsEhliyetler;

{$R *.dfm}

procedure TfrmSetEmpDrivingLicence.RefreshData;
begin
  edtdriving_licence.Text := TSetPrsEhliyet(Table).Ehliyet.AsString;
end;

procedure TfrmSetEmpDrivingLicence.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetPrsEhliyet(Table).Ehliyet.Value := edtdriving_licence.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
