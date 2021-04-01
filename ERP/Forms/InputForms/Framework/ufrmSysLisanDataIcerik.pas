unit ufrmSysLisanDataIcerik;

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
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SysLisanDataIcerik;

type
  TfrmSysLangDataContent = class(TfrmBaseInputDB)
    lbllisan: TLabel;
    edtlisan: TEdit;
    lbldeger: TLabel;
    edtdeger: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  ufrmSysLisanlar, Ths.Erp.Database.Table.SysLisan;  //use for helper form

{$R *.dfm}

procedure TfrmSysLangDataContent.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysLisanDataIcerik(Table).Lisan.Value := edtlisan.Text;
      TSysLisanDataIcerik(Table).Deger.Value := edtdeger.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysLangDataContent.FormCreate(Sender: TObject);
begin
  inherited;
  edtlisan.CharCase := ecNormal;
  edtdeger.CharCase := ecNormal;
end;

procedure TfrmSysLangDataContent.FormShow(Sender: TObject);
begin
  edtlisan.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysLangDataContent.HelperProcess(Sender: TObject);
var
  LfrmLisan: TfrmSysLisanlar;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtlisan.Name then
      begin
        LfrmLisan := TfrmSysLisanlar.Create(TEdit(Sender), Self, TSysLisan.Create(Table.Database), fomNormal, True);
        try
          LfrmLisan.ShowModal;
          TEdit(Sender).Text := TSysLisan(LfrmLisan.Table).Lisan.Value;
        finally
          LfrmLisan.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysLangDataContent.RefreshData;
begin
  edtlisan.Text := TSysLisanDataIcerik(Table).Lisan.Value;
  edtdeger.Text := TSysLisanDataIcerik(Table).Deger.Value;
end;

end.
