unit ufrmSysAy;

interface

{$I ThsERP.inc}

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
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSysAy = class(TfrmBaseInputDB)
    edtay_adi: TEdit;
    lblay_adi: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysAy;

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

procedure TfrmSysAy.RefreshData();
begin
  edtay_adi.Text := VarToStr(FormatedVariantVal(TSysAy(Table).AyAdi));
end;

end.
