unit ufrmSysParaBirimi;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.SysParaBirimleri;

type
  TfrmSysParaBirimi = class(TfrmBaseInputDB)
    lblpara: TLabel;
    edtpara: TEdit;
    lblsembol: TLabel;
    edtsembol: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysParaBirimi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysParaBirimi(Table).Para.Value := edtpara.Text;
      TSysParaBirimi(Table).Sembol.Value := edtsembol.Text;
      TSysParaBirimi(Table).Aciklama.Value := edtaciklama.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysParaBirimi.RefreshData;
begin
  inherited;
  edtpara.Text := TSysParaBirimi(Table).Para.Value;
  edtsembol.Text := TSysParaBirimi(Table).Sembol.Value;
  edtaciklama.Text := TSysParaBirimi(Table).Aciklama.Value;
end;

end.
