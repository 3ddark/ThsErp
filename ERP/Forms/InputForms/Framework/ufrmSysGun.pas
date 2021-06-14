unit ufrmSysGun;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
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
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSysGun = class(TfrmBaseInputDB)
    edtgun_adi: TEdit;
    lblgun_adi: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData; override;
  end;

implementation

uses
    Ths.Erp.Database.Table.SysGun
  ;

{$R *.dfm}

procedure TfrmSysGun.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysGun(Table).GunAdi.Value := edtgun_adi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysGun.FormCreate(Sender: TObject);
begin
  inherited;
  edtgun_adi.CharCase := ecNormal;
end;

procedure TfrmSysGun.RefreshData;
begin
  edtgun_adi.Text := VarToStr(TSysGun(Table).GunAdi.Value);
end;

end.
