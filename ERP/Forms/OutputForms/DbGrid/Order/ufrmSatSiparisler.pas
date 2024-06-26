unit ufrmSatSiparisler;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.StrUtils,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Graphics, Vcl.Samples.Spin, Vcl.StdCtrls,
  Vcl.Grids, Vcl.Dialogs, Data.DB, ufrmBase, ufrmBaseDBGrid, System.Actions,
  Vcl.ActnList, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmSatSiparisler = class(TfrmBaseDBGrid)
    mniSiparisDurumGuncelle: TMenuItem;
    rgFiltre: TRadioGroup;
    mniPrintPackingList: TMenuItem;
    procedure mniSiparisDurumGuncelleClick(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
    procedure HizliFiltre(Sender: TObject);
    procedure mniPrintPackingListClick(Sender: TObject);
  private
    FHizliFilterActive: Boolean;
//    FHizliFilter: string;
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

const
  FILTRE_BEKLEYEN     = 0;
  FILTRE_HAZIR        = 1;
  FILTRE_GIDEN        = 2;
  FILTRE_TUMU         = 3;

implementation

uses
  ufrmSatSiparisDetaylar,
  Ths.Globals,
  Ths.Constants,
  Ths.Database,
  Ths.Database.Table.SysParaBirimleri,
  Ths.Database.Table.SatSiparis,
  Ths.Database.Table.SetSatSiparisDurum,
  Ths.Database.Table.ChHesapKarti;

{$R *.dfm}

function TfrmSatSiparisler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSatSiparisDetaylar.Create(Application, Self, TSatSiparis(Table.List[0]).Clone, pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSatSiparisDetaylar.Create(Application, Self, TSatsiparis.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSatSiparisDetaylar.Create(Application, Self, TSatSiparis(Table.List[0]).Clone, pFormMode);
end;

procedure TfrmSatSiparisler.FormShow(Sender: TObject);
begin
  inherited;

  FHizliFilterActive := False;
  rgFiltre.ItemIndex := 0;
  FHizliFilterActive := True;
  HizliFiltre(nil);
end;

procedure TfrmSatSiparisler.HizliFiltre(Sender: TObject);
begin
  if not IsHelper then
  begin
    if FHizliFilterActive then
    begin
//      grd.DataSource.DataSet.DisableControls;
//      try
        if rgFiltre.ItemIndex = FILTRE_BEKLEYEN then
          QryFiltreVarsayilan := ' AND ' + TSatSiparis(Table).SiparisDurumID.FieldName + '=' + Ord(TSatSiparisDurum.Beklemede).ToString
        else if rgFiltre.ItemIndex = FILTRE_HAZIR then
          QryFiltreVarsayilan := ' AND ' + TSatSiparis(Table).SiparisDurumID.FieldName + '=' + Ord(TSatSiparisDurum.Hazir).ToString
        else if rgFiltre.ItemIndex = FILTRE_GIDEN then
          QryFiltreVarsayilan := ' AND ' + TSatSiparis(Table).SiparisDurumID.FieldName + '=' + Ord(TSatSiparisDurum.Gitti).ToString
        else if rgFiltre.ItemIndex = FILTRE_TUMU then
          QryFiltreVarsayilan := '';
        RefreshDataFirst;
//      finally
//        grd.DataSource.DataSet.EnableControls;
//      end;
    end;
  end;
end;

procedure TfrmSatSiparisler.mniPrintPackingListClick(Sender: TObject);
var
  Detay: TSatSiparisDetay;
  LCH: TChHesapKarti;
  n1: Integer;
  LDump: string;
begin
  if TSatSiparis(Table).SiparisNo.Value = '' then
    Exit;

  Detay := TSatSiparisDetay.Create(Table.Database);
  LCH := TChHesapKarti.Create(Table.Database);
  try
    Detay.SelectToDatasource(' AND header_id=' + Table.Id.AsString, False, False);
    LCH.SelectToList(' AND ' + LCH.HesapKodu.QryName + '=' + QuotedStr(TSatSiparis(Table).MusteriKodu.Value), False, False);

    LDump := FormatSettings.CurrencyString;
    for n1 := 0 to GParaBirimi.List.Count-1 do
      if TSatSiparis(Table).ParaBirimi.Value = TSysParaBirimi(GParaBirimi.List[n1]).Para.Value then
      begin
        FormatSettings.CurrencyString := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.Value;
        if TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = GSysApplicationSetting.Para.AsString then
          FormatSettings.CurrencyString := (TSysParaBirimi(GParaBirimi.List[n1]).Sembol.AsString);
        Break;
      end;
  finally
    FormatSettings.CurrencyString := LDump;
    Detay.Free;
    LCH.Free;
  end;
end;

procedure TfrmSatSiparisler.mniSiparisDurumGuncelleClick(Sender: TObject);
var
  LSip: TSatSiparis;
begin
  if Table.IsAuthorized(ptSpecial, True, False) then
  begin
    SetSelectedItem;
    LSip := TSatSiparis.Create(GDataBase);
    try
      LSip.SelectToList(' AND ' + LSip.Id.QryName + '=' + IntToStr(VarToInt(TSatSiparis(Table).Id.Value)) , False, False);
      if isCtrlDown then
      begin
        if LSip.SiparisDurumID.Value = Ord(TSatSiparisDurum.Hazir) then
        begin
          if CustomMsgDlg(
            'Sipariş Durum "Hazır" dan "Bekleme" ye geri alınsın mı?',
            mtConfirmation,
            mbYesNo,
            ['Evet', 'Hayır'],
            mbNo,
            'Sipariş Durum Geri Alma Onayı') = mrYes
          then
          begin
            LSip.SiparisDurumID.Value := Ord(TSatSiparisDurum.Beklemede);
            LSip.Update();
            grd.DataSource.DataSet.Refresh;
          end;
        end
        else if LSip.SiparisDurumID.Value = Ord(TSatSiparisDurum.Gitti) then
        begin
          if CustomMsgDlg(
            'Sipariş Durum "Gitti" den "Hazır" a geri alınsın mı?',
            mtConfirmation,
            mbYesNo,
            ['Evet', 'Hayır'],
            mbNo,
            'Sipariş Durum Geri Alma Onayı') = mrYes
          then
          begin
            LSip.SiparisDurumID.Value := Ord(TSatSiparisDurum.Hazir);
            LSip.Update();
            grd.DataSource.DataSet.Refresh;
          end;
        end;
      end
      else
      begin
        if LSip.SiparisDurumID.Value = Ord(TSatSiparisDurum.Beklemede) then
        begin
          if CustomMsgDlg(
            'Sipariş Durum "Bekleme" den "Hazır" a getirilsin mi?',
            mtConfirmation,
            mbYesNo,
            ['Evet', 'Hayır'],
            mbNo,
            'Sipariş Durum Değişiklik Onayı') = mrYes
          then
          begin
            LSip.SiparisDurumID.Value := Ord(TSatSiparisDurum.Hazir);
            LSip.Update();
            grd.DataSource.DataSet.Refresh;
          end;
        end
        else if TSatSiparis(Table).SiparisDurumID.Value = Ord(TSatSiparisDurum.Hazir) then
        begin
          if CustomMsgDlg(
            'Sipariş Durum "Hazır" dan "Gitti" ye getirilsin mi?',
            mtConfirmation,
            mbYesNo,
            ['Evet', 'Hayır'],
            mbNo,
            'Sipariş Durum Değişiklik Onayı') = mrYes
          then
          begin
            LSip.SiparisDurumID.Value := Ord(TSatSiparisDurum.Gitti);
            LSip.Update();
            grd.DataSource.DataSet.Refresh;
          end;
        end;
      end;
    finally
      LSip.Free;
    end;
  end
  else
    CustomMsgDlg('Durum Güncelleme hakkınız olmadığı için bu işlemi yapamazsınız.' + AddLBs(3) +
                 Table.TableSourceCode + ' ' + PermissionTypeAsString(ptSpecial), mtInformation, [mbOK], ['Tamam'], mbOK, 'İşlem Hakkı Bilgilendirme');
end;

end.
