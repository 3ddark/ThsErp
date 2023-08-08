unit ufrmChHesapKartiAra;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Types, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  Vcl.AppEvnts, Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.ComboBox, Ths.Helper.Memo, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.ChHesapPlanlari, ufrmChHesapPlanlari, Ths.Constants;

type
  TfrmHesapKartiAra = class(TfrmBaseInputDB)
    lblhesap_kodu: TLabel;
    lblhesap_ismi: TLabel;
    lblmuhasebe_kodu: TLabel;
    edtkok_hesap_kodu: TEdit;
    lblspl1: TLabel;
    cbbara_hesap_kodu: TComboBox;
    edthesap_kodu: TEdit;
    edthesap_ismi: TEdit;
    procedure edtkok_hesap_koduExit(Sender: TObject);
    procedure cbbara_hesap_koduExit(Sender: TObject);
  private
    procedure fillAraHesapNumbers;
    function getHesapKodu: string;
  public
    procedure Repaint; override;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData(); override;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table, Ths.Database.Table.ChHesapKartiAra,
  Ths.Database.Table.ChHesapKarti;

{$R *.dfm}

procedure TfrmHesapKartiAra.cbbara_hesap_koduExit(Sender: TObject);
begin
  inherited;
  edthesap_kodu.Text := getHesapKodu;
end;

procedure TfrmHesapKartiAra.edtkok_hesap_koduExit(Sender: TObject);
begin
  inherited;
  edthesap_kodu.Text := getHesapKodu;
end;

procedure TfrmHesapKartiAra.fillAraHesapNumbers;
var
  n1: Integer;
  LHesapKarti: TChHesapKarti;
  LAraKodlar: TStringList;
begin
  cbbara_hesap_kodu.Clear;
  LHesapKarti := TChHesapKarti.Create(Table.Database);
  try
    cbbara_hesap_kodu.Items.BeginUpdate;
    for n1 := 1 to 100 do
      cbbara_hesap_kodu.Items.Add(Format('%.*d', [3, n1])); // n1.ToString;

    if (FormMode = ifmUpdate) or (FormMode = ifmRewiev) or (FormMode = ifmReadOnly) then
      LAraKodlar := LHesapKarti.GetAraHesapKodlari(edtkok_hesap_kodu.Text, TChHesapKartiAra(Table).KokKod.AsString, True)
    else
      LAraKodlar := LHesapKarti.GetAraHesapKodlari(edtkok_hesap_kodu.Text, '', False);

    for n1 := 0 to LAraKodlar.Count - 1 do
    begin
      if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
        cbbara_hesap_kodu.Items.Delete(cbbara_hesap_kodu.Items.IndexOf(LAraKodlar.Strings[0]));
    end;
  finally
    LHesapKarti.Free;
    cbbara_hesap_kodu.Items.EndUpdate;
  end;
end;

procedure TfrmHesapKartiAra.FormShow(Sender: TObject);
begin
  edtkok_hesap_kodu.OnHelperProcess := HelperProcess;

  inherited;

  edtkok_hesap_kodu.SetFocus;
end;

function TfrmHesapKartiAra.getHesapKodu: string;
begin
  Result := edtkok_hesap_kodu.Text + '-' + cbbara_hesap_kodu.Text
end;

procedure TfrmHesapKartiAra.HelperProcess(Sender: TObject);
var
  LFrmHesapPlani: TfrmChHesapPlanlari;
  LHesapPlani: TChHesapPlani;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtkok_hesap_kodu.Name then
      begin
        LHesapPlani := TChHesapPlani.Create(Table.Database);
        LFrmHesapPlani := TfrmChHesapPlanlari.Create(TEdit(Sender), Self, LHesapPlani, fomNormal, True);
        try
          //Hesap Planýnda seviyesi 3 olanlarýn ara hesabý olabilir. Bu nedenle 3 seviyeliler acýlýr
          LFrmHesapPlani.QryFiltreVarsayilanKullanici := ' AND ' + LHesapPlani.Seviye.QryName + '=' + IntToStr(3);
          LFrmHesapPlani.ShowModal;

          if LFrmHesapPlani.DataAktar then
          begin
            if LFrmHesapPlani.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              cbbara_hesap_kodu.Clear;
              edthesap_kodu.Clear;
            end
            else
            begin
              TEdit(Sender).Text := LHesapPlani.PlanKodu.AsString;
              fillAraHesapNumbers;
              cbbara_hesap_kodu.ItemIndex := 0;
            end;
          end;
        finally
          LFrmHesapPlani.Free;
        end;
      end;
    end;
  end
end;

procedure TfrmHesapKartiAra.RefreshData();
var
  LSplit: TStringDynArray;
begin
  edtkok_hesap_kodu.Text := TChHesapKartiAra(Table).KokKod.Value;
  fillAraHesapNumbers;

  LSplit := SplitString(TChHesapKartiAra(Table).HesapKodu.Value, ACC_DELIM);
  if Length(LSplit) > 1 then
    cbbara_hesap_kodu.ItemIndex := cbbara_hesap_kodu.Items.IndexOf(LSplit[1]);

  edthesap_kodu.Text := TChHesapKartiAra(Table).HesapKodu.Value;
  edthesap_ismi.Text := TChHesapKartiAra(Table).HesapIsmi.Value;
end;

procedure TfrmHesapKartiAra.Repaint;
begin
  inherited;
  edthesap_kodu.ReadOnly := True;
end;

procedure TfrmHesapKartiAra.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChHesapKartiAra(Table).HesapKodu.Value := edthesap_kodu.Text;
      TChHesapKartiAra(Table).HesapIsmi.Value := edthesap_ismi.Text;
      TChHesapKartiAra(Table).HesapTipiID.Value := Ord(htAra);
      TChHesapKartiAra(Table).KokKod.Value := edtkok_hesap_kodu.Text;

      TChHesapKartiAra(Table).Validate;

      inherited;
    end;
  end
  else
    inherited;
end;

end.

