unit ufrmSysSehir;

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
  Ths.Erp.Database.Table.SysUlke;

type
  TfrmSysSehir = class(TfrmBaseInputDB)
    lblulke_adi_id: TLabel;
    lblsehir_adi: TLabel;
    lblplaka_kodu: TLabel;
    cbbulke_adi_id: TComboBox;
    edtsehir_adi: TEdit;
    edtplaka_kodu: TEdit;
    procedure btnAcceptClick(Sender: TObject);override;
  private
    FSysUlke: TSysUlke;
  public
  protected
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysSehir;

{$R *.dfm}

procedure TfrmSysSehir.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      btnAcceptAuto;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysSehir.FormCreate(Sender: TObject);
begin
  inherited;
  FSysUlke := TSysUlke.Create(Table.Database);
  fillComboBoxData(cbbulke_adi_id, FSysUlke, [FSysUlke.UlkeAdi.FieldName], '', True);
end;

procedure TfrmSysSehir.FormDestroy(Sender: TObject);
begin
  FSysUlke.Free;
  inherited;
end;

end.
