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
    lblcurrency: TLabel;
    edtcurrency: TEdit;
    lblsymbol: TLabel;
    edtsymbol: TEdit;
    lblexplanation: TLabel;
    edtexplanation: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysParaBirimi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysParaBirimi(Table).Para.Value := edtcurrency.Text;
      TSysParaBirimi(Table).Sembol.Value := edtsymbol.Text;
      TSysParaBirimi(Table).Aciklama.Value := edtexplanation.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
