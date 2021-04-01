unit ufrmSysLisan;

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
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SysLisan;

type
  TfrmSysLisan = class(TfrmBaseInputDB)
    edtlisan: TEdit;
    lbllisan: TLabel;
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
      TSysLisan(Table).Lisan.Value := edtlisan.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysLisan.FormCreate(Sender: TObject);
begin
  inherited;
  edtlisan.CharCase := ecNormal;
end;

procedure TfrmSysLisan.RefreshData();
begin
  edtlisan.Text := TSysLisan(Table).Lisan.Value;
end;

end.
