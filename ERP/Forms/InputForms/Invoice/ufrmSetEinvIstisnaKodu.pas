unit ufrmSetEinvIstisnaKodu;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
  System.Classes,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.Menus,
  Vcl.Dialogs,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.Samples.Spin,
  Vcl.ExtCtrls,
  ufrmBase,
  ufrmBaseInputDB;

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
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData(); override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SetEinvIstisnaKodu,
  Ths.Database.Table.SetEInvFaturaTipleri;

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
