unit ufrmRctReceteHammadde;

interface

{$I Ths.inc}

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

  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,

  ufrmBase,
  ufrmBaseDetaylarDetay,
  Ths.Database.Table.UrtReceteler;

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
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.StkStokKarti,
  ufrmStkStokKartlari,
  ufrmRctReceteDetaylar;

{$R *.dfm}

procedure TfrmRctReceteHammadde.cbbreceteChange(Sender: TObject);
begin
  if (cbbrecete.ItemIndex > -1) and Assigned(cbbrecete.Items.Objects[cbbrecete.ItemIndex]) then
    lblrecete.Caption := TUrtRecete(cbbrecete.Items.Objects[cbbrecete.ItemIndex]).ReceteAdi.Value;
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
  LRecete: TUrtRecete;
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
          LFrm.QryFiltreVarsayilanKullanici := ' AND ' + LStk.StokKodu.QryName + '<>' + QuotedStr(TfrmRctReceteDetaylar(ParentForm).edtrecete_kodu.Text);
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            edtstok_kodu.Text := TStkStokKarti(LFrm.Table).StokKodu.Value;
            lblstok_aciklama.Caption := TStkStokKarti(LFrm.Table).StokAdi.Value;
            lblmiktar_birim.Caption := TStkStokKarti(LFrm.Table).OlcuBirimi.Value;
            TUrtReceteHammadde(Table).Fiyat.Value := TStkStokKarti(LFrm.Table).AlisFiyat.Value;

            LRecete := TUrtRecete.Create(GDataBase);
            try
              LRecete.SelectToList(' AND ' + LRecete.ReceteKodu.QryName + '=' + QuotedStr(edtstok_kodu.Text), False, False);
              if LRecete.List.Count > 0 then
              begin
                cbbrecete.Clear;
                for n1 := 0 to LRecete.List.Count-1 do
                  cbbrecete.Items.AddObject(TUrtRecete(LRecete.List[n1]).ReceteKodu.Value, TUrtRecete(TUrtRecete(LRecete.List[n1]).Clone));

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
  edtstok_kodu.Text := FormatedVariantVal(TUrtReceteHammadde(Table).StokKodu);
  lblstok_aciklama.Caption := FormatedVariantVal(TUrtReceteHammadde(Table).StokAdi);
  edtmiktar.Text := FormatedVariantVal(TUrtReceteHammadde(Table).Miktar);
  lblmiktar_birim.Caption := FormatedVariantVal(TUrtReceteHammadde(Table).OlcuBirimi);
  edtfire_orani.Text := FormatedVariantVal(TUrtReceteHammadde(Table).FireOrani);
  cbbreceteChange(cbbrecete);
end;

procedure TfrmRctReceteHammadde.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TUrtReceteHammadde(Table).StokKodu.Value := edtstok_kodu.Text;
      TUrtReceteHammadde(Table).StokAdi.Value := lblstok_aciklama.Caption;
      TUrtReceteHammadde(Table).Miktar.Value := StrToFloatDef(edtMiktar.Text, 0);
      TUrtReceteHammadde(Table).OlcuBirimi.Value := lblmiktar_birim.Caption;
      TUrtReceteHammadde(Table).FireOrani.Value := StrToFloatDef(edtfire_orani.Text, 0);
      if (cbbrecete.ItemIndex > -1) and Assigned(cbbrecete.Items.Objects[cbbrecete.ItemIndex]) then
        TUrtReceteHammadde(Table).ReceteID.Value := TUrtRecete(cbbrecete.Items.Objects[cbbrecete.ItemIndex]).Id.Value;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
