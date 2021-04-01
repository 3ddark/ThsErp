unit ufrmSetChFasonMarka;

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
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetChFasonMarka = class(TfrmBaseInputDB)
    lblfason_marka: TLabel;
    edtfason_marka: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Database.Table.SetChFasonMarka,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Constants,
  Ths.Erp.Globals;

{$R *.dfm}

procedure TfrmSetChFasonMarka.RefreshData();
begin
  edtfason_marka.Text := VarToStr( FormatedVariantVal(TSetChFasonMarka(Table).FasonMarka) );
end;

procedure TfrmSetChFasonMarka.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetChFasonMarka(Table).FasonMarka.Value := edtfason_marka.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
