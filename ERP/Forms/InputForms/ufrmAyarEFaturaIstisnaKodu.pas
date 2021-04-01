unit ufrmAyarEFaturaIstisnaKodu;

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
  TfrmAyarEFaturaIstisnaKodu = class(TfrmBaseInputDB)
    cbbFaturaTipi: TComboBox;
    chkIsTamIstisna: TCheckBox;
    edtAciklama: TEdit;
    edtKod: TEdit;
    lblAciklama: TLabel;
    lblFaturaTipi: TLabel;
    lblIsTamIstisna: TLabel;
    lblKod: TLabel;
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
  , Ths.Erp.Database.Table.AyarEFaturaIstisnaKodu
  , Ths.Erp.Database.Table.AyarEFaturaFaturaTipi
  ;

{$R *.dfm}

procedure TfrmAyarEFaturaIstisnaKodu.FormCreate(Sender: TObject);
var
  vFaturaTipi: TAyarEFaturaFaturaTipi;
  n1: Integer;
begin
  inherited;

  edtAciklama.CharCase := ecNormal;

  vFaturaTipi := TAyarEFaturaFaturaTipi.Create(GDataBase);
  try
    cbbFaturaTipi.Clear;
    vFaturaTipi.SelectToList('', False, False);
    for n1 := 0 to vFaturaTipi.List.Count-1 do
      cbbFaturaTipi.Items.Add(TAyarEFaturaFaturaTipi(vFaturaTipi.List[n1]).Tip.Value);
  finally
    vFaturaTipi.Free;
  end;
end;

procedure TfrmAyarEFaturaIstisnaKodu.RefreshData();
begin
  //control i�eri�ini table class ile doldur
  edtKod.Text := TAyarEFaturaIstisnaKodu(Table).Kod.Value;
  edtAciklama.Text := TAyarEFaturaIstisnaKodu(Table).Aciklama.Value;
  cbbFaturaTipi.Text := TAyarEFaturaIstisnaKodu(Table).FaturaTip.Value;
  chkIsTamIstisna.Checked := TAyarEFaturaIstisnaKodu(Table).IsTamIstisna.Value;
end;

procedure TfrmAyarEFaturaIstisnaKodu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TAyarEFaturaIstisnaKodu(Table).Kod.Value := edtKod.Text;
      TAyarEFaturaIstisnaKodu(Table).Aciklama.Value := edtAciklama.Text;
      TAyarEFaturaIstisnaKodu(Table).FaturaTip.Value := cbbFaturaTipi.Text;
      TAyarEFaturaIstisnaKodu(Table).IsTamIstisna.Value := chkIsTamIstisna.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
