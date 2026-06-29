unit ufrmSeTEmpDriverLicence;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  ufrmBase, ufrmBaseInputDB;

type
  TfrmSeTEmpDriverLicence = class(TfrmBaseInputDB)
    lblehliyet: TLabel;
    edtehliyet: TEdit;
  published
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals, ufrmSeTEmpDriverLicenceler, Ths.Database.Table.SeTEmpDriverLicenceler;

{$R *.dfm}

procedure TfrmSeTEmpDriverLicence.RefreshData;
begin
  edtehliyet.Text := TSeTEmpDriverLicence(Table).Ehliyet.AsString;
end;

procedure TfrmSeTEmpDriverLicence.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSeTEmpDriverLicence(Table).Ehliyet.Value := edtehliyet.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.

