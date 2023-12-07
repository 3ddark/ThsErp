unit ufrmSysKaynakGrubu;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.SysKaynakGruplari;

type
  TfrmSysKaynakGrubu = class(TfrmBaseInputDB)
    edtgrup: TEdit;
    lblgrup: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData(); override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysKaynakGrubu.RefreshData();
begin
  edtgrup.Text := TSysKaynakGrubu(Table).Grup.Value;
end;

procedure TfrmSysKaynakGrubu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysKaynakGrubu(Table).Grup.Value := edtgrup.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.

