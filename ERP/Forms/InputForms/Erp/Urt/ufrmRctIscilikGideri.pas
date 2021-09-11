unit ufrmRctIscilikGideri;

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
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SetRctIscilikGiderTipi,
  Ths.Erp.Database.Table.SysOlcuBirimi,
  Ths.Erp.Database.Table.SetChHesapTipi;

type
  TfrmRctIscilikGideri = class(TfrmBaseInputDB)
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
    FGider: TSetRctIscilikGiderTipi;
    FBirim: TSysOlcuBirimi;
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
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.RctIscilikGideri,
  Ths.Erp.Database.Table.SysOlcuBirimiTipi,
  Ths.Erp.Database.Table.ChHesapKarti,
  ufrmChHesapKartlari;

{$R *.dfm}

procedure TfrmRctIscilikGideri.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TRctIscilikGideri(Table).GiderKodu.Value := edtgider_kodu.Text;
      TRctIscilikGideri(Table).GiderAdi.Value := edtgider_adi.Text;
      TRctIscilikGideri(Table).Fiyat.Value := edtfiyat.Text;
      if (cbbolcu_birimi_id.ItemIndex > -1) and Assigned(cbbolcu_birimi_id.Items.Objects[cbbolcu_birimi_id.ItemIndex]) then
        TRctIscilikGideri(Table).OlcuBirimiID.Value := TSysOlcuBirimi(cbbolcu_birimi_id.Items.Objects[cbbolcu_birimi_id.ItemIndex]).Id.Value;
      TRctIscilikGideri(Table).OlcuBirimi.Value := cbbolcu_birimi_id.Text;
      if (cbbgider_tipi_id.ItemIndex > -1) and Assigned(cbbgider_tipi_id.Items.Objects[cbbgider_tipi_id.ItemIndex]) then
        TRctIscilikGideri(Table).GiderTipiID.Value := TSetRctIscilikGiderTipi(cbbgider_tipi_id.Items.Objects[cbbgider_tipi_id.ItemIndex]).Id.Value;
      TRctIscilikGideri(Table).GiderTipi.Value := cbbgider_tipi_id.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

destructor TfrmRctIscilikGideri.Destroy;
begin
  FreeAndNil(FGider);
  FreeAndNil(FBirim);
  inherited;
end;

procedure TfrmRctIscilikGideri.FormCreate(Sender: TObject);
begin
  inherited;

  edtgider_kodu.OnHelperProcess := HelperProcess;

  FGider := TSetRctIscilikGiderTipi.Create(Table.Database);
  FBirim := TSysOlcuBirimi.Create(Table.Database);

  fillComboBoxData(cbbolcu_birimi_id, FBirim, [FBirim.OlcuBirimi.FieldName], ' AND ' + FBirim.OlcuBirimiTipiID.QryName + '=' + IntToStr(Ord(TOlcuBirimiTipi.Zaman)) , True);
  fillComboBoxData(cbbgider_tipi_id, FGider, [FGider.GiderTipi.FieldName], '', True);
end;

procedure TfrmRctIscilikGideri.HelperProcess(Sender: TObject);
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
        //Son hesap hane sayýsý > 2 olanlarla iþlem yap.
        LHesapKarti := TChHesapKarti.Create(Table.Database);
        LFrmHesapKarti := TfrmHesapKartlari.Create(TEdit(Sender), Self, LHesapKarti, fomNormal, True);
        try
          LFrmHesapKarti.QryFiltreVarsayilanKullanici :=
            ' AND ' + LHesapKarti.TableName + '.' + LHesapKarti.HesapKodu.FieldName + ' LIKE ''72%'' ' +
            ' AND ' + LHesapKarti.TableName + '.' + LHesapKarti.HesapTipiID.FieldName + '=' + Ord(TChHesapTipi.Son).ToString;
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

procedure TfrmRctIscilikGideri.RefreshData;
begin
  edtgider_kodu.Text := TRctIscilikGideri(Table).GiderKodu.Value;
  edtgider_adi.Text := TRctIscilikGideri(Table).GiderAdi.Value;
  edtfiyat.Text := TRctIscilikGideri(Table).Fiyat.Value;
  cbbolcu_birimi_id.ItemIndex := cbbolcu_birimi_id.Items.IndexOf(TRctIscilikGideri(Table).OlcuBirimi.Value);
  cbbgider_tipi_id.ItemIndex := cbbgider_tipi_id.Items.IndexOf(TRctIscilikGideri(Table).GiderTipi.Value);
end;

end.
