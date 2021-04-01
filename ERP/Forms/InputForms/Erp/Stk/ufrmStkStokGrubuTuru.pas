unit ufrmStkStokGrubuTuru;

interface

{$I ThsERP.inc}

uses
  System.Classes,
  System.StrUtils,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.Samples.Spin,
  Ths.Erp.Helper.Edit,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmStkStokGrubuTuru = class(TfrmBaseInputDB)
    edtstok_grubu_tur: TEdit;
    lblstok_grubu_tur: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Database.Table.StkStokGrubuTuru,
  Ths.Erp.Globals;

{$R *.dfm}

procedure TfrmStkStokGrubuTuru.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkStokGrubuTuru(Table).StokGrubuTur.Value := edtstok_grubu_tur.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmStkStokGrubuTuru.RefreshData;
begin
  edtstok_grubu_tur.Text := TStkStokGrubuTuru(Table).StokGrubuTur.Value;
end;

end.
