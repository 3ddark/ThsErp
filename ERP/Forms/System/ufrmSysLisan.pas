unit ufrmSysLisan;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB, Ths.Database.Table.SysLisanlar;

type
  TfrmSysLisan = class(TfrmBaseInputDB)
    edtlang: TEdit;
    lbllang: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData(); override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysLisan.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysLisan(Table).Lisan.Value := edtlang.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysLisan.FormCreate(Sender: TObject);
begin
  inherited;
  edtlang.CharCase := ecNormal;
end;

procedure TfrmSysLisan.RefreshData();
begin
  edtlang.Text := TSysLisan(Table).Lisan.Value;
end;

end.
