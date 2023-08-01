unit ufrmSysAy;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.Memo, Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB;

type
  TfrmSysLisan = class(TfrmBaseInputDB)
    lblmonth: TLabel;
    edtmonth: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SysAylar;

{$R *.dfm}

procedure TfrmSysLisan.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysAy(Table).AyAdi.Value := edtmonth.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysLisan.FormCreate(Sender: TObject);
begin
  inherited;
  edtmonth.CharCase := ecNormal;
end;

procedure TfrmSysLisan.RefreshData;
begin
  edtmonth.Text := TSysAy(Table).AyAdi.AsString;
end;

end.
