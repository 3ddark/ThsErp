unit ufrmSysLisanVeriIcerik;

interface

{$I Ths.inc}

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
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Database.Table.SysLisanVeriIcerikler;

type
  TfrmSysLisanVeriIcerik = class(TfrmBaseInputDB)
    lbllang: TLabel;
    edtlang: TEdit;
    lblvalue: TLabel;
    edtvalue: TEdit;
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
  ufrmSysLisanlar, Ths.Database.Table.SysLisanlar;  //use for helper form

{$R *.dfm}

procedure TfrmSysLisanVeriIcerik.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysLisanVeriIcerik(Table).Lisan.Value := edtlang.Text;
      TSysLisanVeriIcerik(Table).Deger.Value := edtvalue.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysLisanVeriIcerik.FormCreate(Sender: TObject);
begin
  inherited;
  edtlang.CharCase := ecNormal;
  edtvalue.CharCase := ecNormal;
end;

procedure TfrmSysLisanVeriIcerik.FormShow(Sender: TObject);
begin
  edtlang.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysLisanVeriIcerik.HelperProcess(Sender: TObject);
var
  LfrmLisan: TfrmSysLisanlar;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtlang.Name then
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

procedure TfrmSysLisanVeriIcerik.RefreshData;
begin
  edtlang.Text := TSysLisanVeriIcerik(Table).Lisan.Value;
  edtvalue.Text := TSysLisanVeriIcerik(Table).Deger.Value;
end;

end.
