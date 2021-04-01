unit ufrmOthMailReciever;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts,

  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,

  ufrmBase, ufrmBaseInputDB;

type
  TfrmOthMailReciever = class(TfrmBaseInputDB)
    lblMailAdresi: TLabel;
    edtmail_adresi: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  protected
  published
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.OthMailReciever
  ;

{$R *.dfm}

procedure TfrmOthMailReciever.FormCreate(Sender: TObject);
begin
  inherited;

  edtmail_adresi.CharCase := ecNormal;
end;

procedure TfrmOthMailReciever.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtmail_adresi.Text := FormatedVariantVal(TOthMailReciever(Table).MailAdresi.DataType, TOthMailReciever(Table).MailAdresi.Value);
end;

procedure TfrmOthMailReciever.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TOthMailReciever(Table).MailAdresi.Value := edtmail_adresi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
