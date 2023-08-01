unit ufrmSetEmpEducationLevel;

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
  TfrmSetEmpEducationLevel = class(TfrmBaseInputDB)
    lbleducation_level: TLabel;
    edteducation_level: TEdit;
  published
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  ufrmSetEmpEducationLevels,
  Ths.Database.Table.SetPrsLisanSeviyeleri;

{$R *.dfm}

procedure TfrmSetEmpEducationLevel.RefreshData;
begin
  edteducation_level.Text := TSetPrsLisanSeviyesi(Table).LisanSeviyesi.AsString;
end;

procedure TfrmSetEmpEducationLevel.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetPrsLisanSeviyesi(Table).LisanSeviyesi.Value := edteducation_level.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
