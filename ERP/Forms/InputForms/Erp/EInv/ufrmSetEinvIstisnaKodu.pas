unit ufrmSetEinvIstisnaKodu;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , System.StrUtils
  , System.DateUtils
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.ComCtrls
  , Vcl.Menus
  , Vcl.Buttons
  , Vcl.AppEvnts
  , Vcl.Samples.Spin

  , Data.DB
  , FireDAC.Comp.Client
  , Ths.Erp.Database.Singleton

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB
  ;

type
  TfrmSetEinvIstisnaKodu = class(TfrmBaseInputDB)
    lblkod: TLabel;
    edtkod: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lblfatura_tipi_id: TLabel;
    cbbfatura_tipi_id: TComboBox;
    lblis_tam_istisna: TLabel;
    chkis_tam_istisna: TCheckBox;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Table.SetEinvIstisnaKodu
  , Ths.Erp.Database.Table.SetEInvFaturaTipi
  ;

{$R *.dfm}

procedure TfrmSetEinvIstisnaKodu.FormCreate(Sender: TObject);
var
  vFaturaTipi: TSetEinvFaturaTipi;
  n1: Integer;
begin
  inherited;

  edtAciklama.CharCase := ecNormal;

  vFaturaTipi := TSetEinvFaturaTipi.Create(GDataBase);
  try
    cbbfatura_tipi_id.Clear;
    vFaturaTipi.SelectToList('', False, False);
    for n1 := 0 to vFaturaTipi.List.Count-1 do
      cbbfatura_tipi_id.Items.Add(TSetEinvFaturaTipi(vFaturaTipi.List[n1]).FaturaTipi.Value);
  finally
    vFaturaTipi.Free;
  end;
end;

procedure TfrmSetEinvIstisnaKodu.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtKod.Text := TSetEinvIstisnaKodu(Table).IstisnaKodu.Value;
  edtAciklama.Text := TSetEinvIstisnaKodu(Table).Aciklama.Value;
  cbbfatura_tipi_id.Text := TSetEinvIstisnaKodu(Table).FaturaTipi.Value;
  chkis_tam_istisna.Checked := TSetEinvIstisnaKodu(Table).IsTamIstisna.Value;
end;

procedure TfrmSetEinvIstisnaKodu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvIstisnaKodu(Table).IstisnaKodu.Value := edtKod.Text;
      TSetEinvIstisnaKodu(Table).Aciklama.Value := edtAciklama.Text;
      TSetEinvIstisnaKodu(Table).FaturaTipi.Value := cbbfatura_tipi_id.Text;
      TSetEinvIstisnaKodu(Table).IsTamIstisna.Value := chkis_tam_istisna.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
