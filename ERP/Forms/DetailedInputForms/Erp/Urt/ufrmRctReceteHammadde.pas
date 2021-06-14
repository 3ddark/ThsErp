unit ufrmRctReceteHammadde;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.DateUtils,
  System.NetEncoding,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Buttons,
  Vcl.AppEvnts,
  Vcl.Samples.Spin,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,

  FireDAC.Comp.Client,

  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,

  ufrmBase,
  ufrmBaseDetaylarDetay,
  Ths.Erp.Database.Table.RctRecete;

type
  TfrmRctReceteHammadde = class(TfrmBaseDetaylarDetay)
    lblfire_orani: TLabel;
    lblmiktar: TLabel;
    lblrecete: TLabel;
    lblstok_kodu: TLabel;
    lblmiktar_birim: TLabel;
    lblrecete_adi: TLabel;
    edtstok_kodu: TEdit;
    edtmiktar: TEdit;
    edtfire_orani: TEdit;
    cbbrecete: TComboBox;
    lblstok_aciklama: TLabel;
    procedure cbbreceteChange(Sender: TObject);
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
    procedure HelperProcess(Sender: TObject);
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.StkStokKarti,
  ufrmStkStokKartlari,
  ufrmRctReceteDetaylar;

{$R *.dfm}

procedure TfrmRctReceteHammadde.cbbreceteChange(Sender: TObject);
begin
  if (cbbrecete.ItemIndex > -1) and Assigned(cbbrecete.Items.Objects[cbbrecete.ItemIndex]) then
    lblrecete.Caption := TRctRecete(cbbrecete.Items.Objects[cbbrecete.ItemIndex]).ReceteAdi.Value;
end;

procedure TfrmRctReceteHammadde.FormCreate(Sender: TObject);
begin
  inherited;

  edtmiktar.Text := '1';
  edtfire_orani.Text := '0';
  lblmiktar.Caption := '';
  lblstok_aciklama.Caption := '';
  lblrecete_adi.Caption := '';
end;

procedure TfrmRctReceteHammadde.FormShow(Sender: TObject);
begin
  edtstok_kodu.OnHelperProcess := HelperProcess;
  inherited;
//  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
//  begin
//    edtmiktar.Text := '1';
//    edtfire_orani.Text := '0';
//    lblmiktar.Caption := '';
//    lblstok_aciklama.Caption := '';
//    lblrecete_adi.Caption := '';
//  end;
end;

procedure TfrmRctReceteHammadde.HelperProcess(Sender: TObject);
var
  LFrm: TfrmStkStokKartlari;
  LStk: TStkStokKarti;
  LRecete: TRctRecete;
  n1: Integer;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtstok_kodu.Name then
      begin
        LStk := TStkStokKarti.Create(Table.Database);
        LFrm := TfrmStkStokKartlari.Create(edtstok_kodu, Self, LStk, fomNormal, True);
        try
          LFrm.QryFiltreVarsayilanKullanici := ' AND ' + LStk.StokKodu.QryName + '!=' + QuotedStr(TfrmRctReceteDetaylar(ParentForm).edturun_kodu.Text);
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            edtstok_kodu.Text := TStkStokKarti(LFrm.Table).StokKodu.Value;
            lblstok_aciklama.Caption := TStkStokKarti(LFrm.Table).StokAdi.Value;
            lblmiktar_birim.Caption := TStkStokKarti(LFrm.Table).OlcuBirimi.Value;
            TRctReceteHammadde(Table).Fiyat.Value := TStkStokKarti(LFrm.Table).AlisFiyat.Value;

            LRecete := TRctRecete.Create(GDataBase);
            try
              LRecete.SelectToList(' AND ' + LRecete.ReceteKodu.FieldName + '=' + QuotedStr(edtstok_kodu.Text), False, False);
              if LRecete.List.Count > 0 then
              begin
                cbbrecete.Clear;
                for n1 := 0 to LRecete.List.Count-1 do
                  cbbrecete.Items.AddObject(TRctRecete(LRecete.List[n1]).ReceteKodu.Value, TRctRecete(TRctRecete(LRecete.List[n1]).Clone));

                cbbrecete.ItemIndex := 0;
              end;
            finally
              LRecete.Free;
            end;
          end;
        finally
          LFrm.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmRctReceteHammadde.RefreshData();
begin
  edtstok_kodu.Text := FormatedVariantVal(TRctReceteHammadde(Table).StokKodu);
  lblstok_aciklama.Caption := FormatedVariantVal(TRctReceteHammadde(Table).StokAdi);
  edtmiktar.Text := FormatedVariantVal(TRctReceteHammadde(Table).Miktar);
  lblmiktar_birim.Caption := FormatedVariantVal(TRctReceteHammadde(Table).OlcuBirimi);
  edtfire_orani.Text := FormatedVariantVal(TRctReceteHammadde(Table).FireOrani);
  cbbreceteChange(cbbrecete);
end;

procedure TfrmRctReceteHammadde.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TRctReceteHammadde(Table).StokKodu.Value := edtstok_kodu.Text;
      TRctReceteHammadde(Table).StokAdi.Value := lblstok_aciklama.Caption;
      TRctReceteHammadde(Table).Miktar.Value := StrToFloatDef(edtMiktar.Text, 0);
      TRctReceteHammadde(Table).OlcuBirimi.Value := lblmiktar_birim.Caption;
      TRctReceteHammadde(Table).FireOrani.Value := StrToFloatDef(edtfire_orani.Text, 0);
      if cbbrecete.ItemIndex > -1 then
        if Assigned(cbbrecete.Items.Objects[cbbrecete.ItemIndex]) then
        begin
          TRctReceteHammadde(Table).ReceteID.Value := TRctRecete(cbbrecete.Items.Objects[cbbrecete.ItemIndex]).Id.Value;
        end;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
