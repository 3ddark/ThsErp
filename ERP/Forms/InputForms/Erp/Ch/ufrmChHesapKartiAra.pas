unit ufrmChHesapKartiAra;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.Types,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SetChHesapTipi,
  Ths.Erp.Database.Table.SetChHesapPlani,
  ufrmSetChHesapPlanlari,
  ufrmChHesapKartlariAra,
  Ths.Erp.Constants;

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
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormShow(Sender: TObject);override;
    procedure RefreshData();override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.ChHesapKartiAra;

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
  vSP: TFDStoredProc;
begin
  cbbara_hesap_kodu.Clear;
  vSP := GDataBase.NewStoredProcedure();
  try
    cbbara_hesap_kodu.Items.BeginUpdate;
    for n1 := 1 to 100 do
      cbbara_hesap_kodu.Items.Add(n1.ToString);// Format('%.*d',[3, n1]);

    vSP.ResourceOptions.DirectExecute := False;
    vSP.StoredProcName := 'spget_hesap_kodu_ara_kodlar';
    vSP.Prepare;
    vSP.ParamByName('pkok_kod').Text := edtkok_hesap_kodu.Text;
    vSP.ParamByName('para_kod').Text := '';
    vSP.ParamByName('pis_update').AsBoolean := False;
    if (FormMode = ifmUpdate) OR (FormMode = ifmRewiev) OR (FormMode = ifmReadOnly) then
    begin
      vSP.ParamByName('para_kod').Text := TChHesapKartiAra(Table).KokHesapKodu.Value;
      vSP.ParamByName('pis_update').AsBoolean := True;
    end;
    vSP.Open();
    vSP.First;
    while not vSP.Eof do
    begin
      if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
        cbbara_hesap_kodu.Items.Delete(cbbara_hesap_kodu.Items.IndexOf(vSP.Fields.Fields[0].AsString));
      vSP.Next;
    end;
  finally
    vSP.Free;
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
  LFrmHesapPlani: TfrmSetChHesapPlanlari;
  LHesapPlani: TSetChHesapPlani;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtkok_hesap_kodu.Name then
      begin
        LHesapPlani := TSetChHesapPlani.Create(Table.Database);
        LfrmHesapPlani := TfrmSetChHesapPlanlari.Create(TEdit(Sender), Self, LHesapPlani, fomNormal, True);
        try
          //Hesap Planýnda seviyesi 3 olanlarýn ara hesabý olabilir. Bu nedenle 3 seviyeliler acýlýr
          LFrmHesapPlani.QryFiltreVarsayilanKullanici := ' AND ' +
            LHesapPlani.TableName + '.' + LHesapPlani.SeviyeSayisi.FieldName + '=' + IntToStr(3);
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
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(LHesapPlani.TekDuzenKodu));
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
  edtkok_hesap_kodu.Text := TChHesapKartiAra(Table).KokHesapKodu.Value;
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
      TChHesapKartiAra(Table).MuhasebeKodu.Value := TChHesapKartiAra(Table).HesapKodu.Value;
      TChHesapKartiAra(Table).HesapTipiID.Value := Ord(htAra);
      TChHesapKartiAra(Table).KokHesapKodu.Value := edtkok_hesap_kodu.Text;

      TChHesapKartiAra(Table).Validate;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
