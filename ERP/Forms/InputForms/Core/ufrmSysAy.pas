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
  TfrmSysAy = class(TfrmBaseInputDB)
    lblay_adi: TLabel;
    edtay_adi: TEdit;
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

procedure TfrmSysAy.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysAy(Table).AyAdi.Value := edtay_adi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysAy.FormCreate(Sender: TObject);
begin
  inherited;
  edtay_adi.CharCase := ecNormal;
end;

procedure TfrmSysAy.RefreshData;
begin
  edtay_adi.Text := TSysAy(Table).AyAdi.AsString;
end;

end.
