﻿unit ufrmAlsTeklifler;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.StrUtils, System.Types, System.Classes, System.Math, System.UITypes,
  System.Rtti, System.Actions, Vcl.Menus, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.StdCtrls,
  Vcl.Samples.Spin, Vcl.ActnList, Vcl.Grids, Vcl.DBGrids, Data.DB, ufrmBase,
  ufrmBaseDBGrid, udm, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmAlsTeklifler = class(TfrmBaseDBGrid)
    mniSipariseAktar: TMenuItem;
    rgFiltre: TRadioGroup;
    procedure mniSipariseAktarClick(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
    procedure HizliFiltre(Sender: TObject);
    procedure mniPrintClick(Sender: TObject);
    procedure pmDBPopup(Sender: TObject); override;
  private
    FHizliFilterActive: Boolean;
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

const
  FILTRE_BEKLEYEN     = 0;
  FILTRE_SIPARIS_OLAN = 1;
  FILTRE_TUMU         = 2;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database,
  Ths.Database.Table.AlsTeklifler, ufrmAlsTeklifDetaylar,
  Ths.Database.Table.ChHesapKarti,
  Ths.Database.Table.SysParaBirimleri;

{$R *.dfm}

function TfrmAlsTeklifler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmAlsTeklifDetaylar.Create(Application, Self, TAlsTeklif(Table.List[0]).Clone, pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmAlsTeklifDetaylar.Create(Application, Self, TAlsTeklif.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmAlsTeklifDetaylar.Create(Application, Self, TAlsTeklif(Table.List[0]).Clone, pFormMode);
end;

procedure TfrmAlsTeklifler.mniPrintClick(Sender: TObject);
var
  LDump: string;
  Header: TAlsTeklif;
  Detay: TAlsTeklifDetay;
  LCH: TChHesapKarti;
  n1: Integer;
begin
  if TAlsTeklif(Table).TeklifNo.Value = '' then
    Exit;

  Header := TAlsTeklif.Create(Table.Database);
  Detay := TAlsTeklifDetay.Create(Table.Database, TAlsTeklif(Table));
  LCH := TChHesapKarti.Create(Table.Database);
  try
    Header.SelectToList(' AND ' + Header.Id.QryName + '=' + Table.Id.AsString, False, False);
    Detay.SelectToDatasource(' AND header_id=' + Table.Id.AsString, False, False);
    LCH.SelectToList(' AND ' + LCH.HesapKodu.QryName + '=' + QuotedStr(TAlsTeklif(Table).MusteriKodu.Value), False, False);

    LDump := FormatSettings.CurrencyString;
    for n1 := 0 to GParaBirimi.List.Count-1 do
      if TAlsTeklif(Table).ParaBirimi.Value = TSysParaBirimi(GParaBirimi.List[n1]).Para.Value then
      begin
        FormatSettings.CurrencyString := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.Value;
        Break;
      end;
  finally
    FormatSettings.CurrencyString := LDump;
    Header.Free;
    Detay.Free;
    LCH.Free;
  end;
end;

procedure TfrmAlsTeklifler.mniSipariseAktarClick(Sender: TObject);
//var
//  LSatSip, ASiparis: TAlsSiparis;
//  LTeklif: TSatTeklif;
begin
{
  LSatSip := TAlsSiparis.Create(GDataBase);
  LTeklif := TSatTeklif.Create(GDataBase);
  try
    if LSatSip.IsAuthorized(ptAddRecord, True, False) then
    begin
      LTeklif.SelectToList(' AND ' + LTeklif.Id.QryName + '=' + VarToStr(Table.Id.AsString) , False, False);
      ASiparis := TAlsSiparis(LTeklif.ToSiparis);
      TfrmSatSiparisDetaylar.Create(Application, Self, ASiparis, TInputFormMode.ifmCopyNewRecord).Show;
    end
    else
      CustomMsgDlg(
        '"Sipariş Kayıt Hakkı" nız olmadığı için "Sipariş Kaydı yapamazsınız".',
        mtWarning,
        [mbOK],
        ['Tamam'],
        mbNo,
        'Erişim Hakkı Uyarı');
  finally
    LSatSip.Free;
    LTeklif.Free;
  end;
}
end;

procedure TfrmAlsTeklifler.pmDBPopup(Sender: TObject);
begin
  inherited;
  mniSipariseAktar.Enabled := not TAlsTeklif(Table).IsSiparislesti.AsBoolean;
end;

procedure TfrmAlsTeklifler.FormShow(Sender: TObject);
begin
  inherited;

  mniPrint.Visible := True;

  FHizliFilterActive := False;
  rgFiltre.ItemIndex := 0;
  FHizliFilterActive := True;
  HizliFiltre(nil);
end;

procedure TfrmAlsTeklifler.HizliFiltre(Sender: TObject);
begin
  if not IsHelper then
  begin
    if FHizliFilterActive then
    begin
//      grd.DataSource.DataSet.DisableControls;
//      try
        if rgFiltre.ItemIndex = FILTRE_BEKLEYEN then
          QryFiltreVarsayilan := ' AND ' + TAlsTeklif(Table).IsSiparislesti.FieldName + '=False'
        else if rgFiltre.ItemIndex = FILTRE_SIPARIS_OLAN then
          QryFiltreVarsayilan := ' AND ' + TAlsTeklif(Table).IsSiparislesti.FieldName + '=True'
        else if rgFiltre.ItemIndex = FILTRE_TUMU then
          QryFiltreVarsayilan := '';
        RefreshDataFirst;
//      finally
//        grd.DataSource.DataSet.EnableControls;
//      end;
    end;
  end;
end;

end.
