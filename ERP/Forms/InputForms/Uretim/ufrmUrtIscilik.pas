unit ufrmUrtIscilik;

interface

{$I Ths.inc}

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
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Database.Table.SysOlcuBirimleri,
  Ths.Database.Table.SetChHesapTipi;

type
  TfrmUrtIscilik = class(TfrmBaseInputDB)
    edtgider_kodu: TEdit;
    lblgider_kodu: TLabel;
    lblgider_adi: TLabel;
    edtgider_adi: TEdit;
    lblfiyat: TLabel;
    edtfiyat: TEdit;
    cbbolcu_birimi_id: TComboBox;
    lblolcu_birimi_id: TLabel;
    cbbgider_tipi_id: TComboBox;
    lblgider_tipi_id: TLabel;
  private
    FSysUnit: TSysOlcuBirimi;
  public
    destructor Destroy; override;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Database.Table.UrtIscilikler,
  Ths.Database.Table.SysOlcuBirimiTipleri,
  Ths.Database.Table.ChHesapKarti,
  ufrmChHesapKartlari;

{$R *.dfm}

procedure TfrmUrtIscilik.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TUrtIscilik(Table).GiderKodu.Value := edtgider_kodu.Text;
      TUrtIscilik(Table).GiderAdi.Value := edtgider_adi.Text;
      TUrtIscilik(Table).Fiyat.Value := edtfiyat.Text;
      if (cbbolcu_birimi_id.ItemIndex > -1) and Assigned(cbbolcu_birimi_id.Items.Objects[cbbolcu_birimi_id.ItemIndex]) then
        TUrtIscilik(Table).BirimID.Value := TSysOlcuBirimi(cbbolcu_birimi_id.Items.Objects[cbbolcu_birimi_id.ItemIndex]).Id.Value;
      TUrtIscilik(Table).Birim.Value := cbbolcu_birimi_id.Text;
      TUrtIscilik(Table).GiderTipi.Value := cbbgider_tipi_id.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

destructor TfrmUrtIscilik.Destroy;
begin
  FreeAndNil(FSysUnit);
  inherited;
end;

procedure TfrmUrtIscilik.FormCreate(Sender: TObject);
begin
  inherited;

  edtgider_kodu.OnHelperProcess := HelperProcess;

  FSysUnit := TSysOlcuBirimi.Create(Table.Database);

  fillComboBoxData(cbbolcu_birimi_id, FSysUnit, [FSysUnit.Birim.FieldName], ' AND ' + FSysUnit.BirimiTipiID.QryName + '=' + IntToStr(Ord(TOlcuBirimiTipi.Zaman)) , True);
  cbbgider_tipi_id.Items.Add('Değişken 1');
  cbbgider_tipi_id.Items.Add('Sabit 2');
end;

procedure TfrmUrtIscilik.HelperProcess(Sender: TObject);
var
  LFrmHesapKarti: TfrmHesapKartlari;
  LHesapKarti: TChHesapKarti;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtgider_kodu.Name then
      begin
        //Son hesap hane saysı > 2 olanlarla işlem yap.
        LHesapKarti := TChHesapKarti.Create(Table.Database);
        LFrmHesapKarti := TfrmHesapKartlari.Create(TEdit(Sender), Self, LHesapKarti, fomNormal, True);
        try
          LFrmHesapKarti.QryFiltreVarsayilanKullanici :=
            ' AND ' + LHesapKarti.TableName + '.' + LHesapKarti.HesapKodu.FieldName + ' LIKE ''72%'' ' +
            ' AND ' + LHesapKarti.TableName + '.' + LHesapKarti.HesapTipiID.FieldName + '=' + Ord(TAccAccountType.Son).ToString;
          LFrmHesapKarti.ShowModal;

          TEdit(Sender).Text := LHesapKarti.HesapKodu.Value;
          edtgider_adi.Text := LHesapKarti.HesapIsmi.Value;
        finally
          LFrmHesapKarti.Free;
        end;
      end
    end;
  end
end;

procedure TfrmUrtIscilik.RefreshData;
begin
  edtgider_kodu.Text := TUrtIscilik(Table).GiderKodu.Value;
  edtgider_adi.Text := TUrtIscilik(Table).GiderAdi.Value;
  edtfiyat.Text := TUrtIscilik(Table).Fiyat.AsString;
  cbbolcu_birimi_id.ItemIndex := cbbolcu_birimi_id.Items.IndexOf(TUrtIscilik(Table).BirimID.Value);
  cbbgider_tipi_id.ItemIndex := cbbgider_tipi_id.Items.IndexOf(TUrtIscilik(Table).GiderTipi.Value);
end;

end.
