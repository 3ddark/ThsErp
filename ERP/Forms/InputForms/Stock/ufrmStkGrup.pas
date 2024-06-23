unit ufrmStkGrup;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.AppEvnts,
  Vcl.Samples.Spin, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,
  ufrmBase, ufrmBaseInputDB;

type
  TfrmStkGrup = class(TfrmBaseInputDB)
    lblgrup: TLabel;
    lblkdv_orani: TLabel;
    edtgrup: TEdit;
    edtkdv_orani: TEdit;
    lblalis_iade_hesap_kodu: TLabel;
    lblalis_hesap_kodu: TLabel;
    lblsatis_iade_hesap_kodu: TLabel;
    lblsatis_hesap_kodu: TLabel;
    lblalis_hesap_adi: TLabel;
    lblalis_iade_hesap_adi: TLabel;
    lblsatis_hesap_adi: TLabel;
    lblsatis_iade_hesap_adi: TLabel;
    edtsatis_hesap_kodu: TEdit;
    edtsatis_iade_hesap_kodu: TEdit;
    edtalis_hesap_kodu: TEdit;
    edtalis_iade_hesap_kodu: TEdit;
    edthammadde_stok_hesap_kodu: TEdit;
    edthammadde_kullanim_hesap_kodu: TEdit;
    lblhammadde_kullanim_hesap_adi: TLabel;
    lblhammadde_stok_hesap_adi: TLabel;
    lblhammadde_stok_hesap_kodu: TLabel;
    lblhammadde_kullanim_hesap_kodu: TLabel;
    lblyari_mamul_hesap_adi: TLabel;
    lblyari_mamul_hesap_kodu: TLabel;
    edtyari_mamul_hesap_kodu: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  public
    procedure Repaint; override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table.StkGruplar, ufrmChHesapKartlari,
  Ths.Database.Table.ChHesapKarti, ufrmSetChVergiOranlari,
  Ths.Database.Table.SetChVergiOranlari;

{$R *.dfm}

procedure TfrmStkGrup.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkGruplar(Table).Grup.Value := edtgrup.Text;
      TStkGruplar(Table).KDVOrani.Value := edtkdv_orani.Text;
      TStkGruplar(Table).HammaddeStokHesapKodu.Value := edthammadde_stok_hesap_kodu.Text;
      TStkGruplar(Table).HammaddeKullanimHesapKodu.Value := edthammadde_kullanim_hesap_kodu.Text;
      TStkGruplar(Table).YariMamulHesapKodu.Value := edtyari_mamul_hesap_kodu.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmStkGrup.FormCreate(Sender: TObject);
begin
  inherited;

  edtkdv_orani.OnHelperProcess := HelperProcess;
  edthammadde_stok_hesap_kodu.OnHelperProcess := HelperProcess;
  edthammadde_kullanim_hesap_kodu.OnHelperProcess := HelperProcess;
  edtyari_mamul_hesap_kodu.OnHelperProcess := HelperProcess;

  edtsatis_hesap_kodu.OnHelperProcess := HelperProcess;
  edtsatis_hesap_kodu.OnHelperProcess := HelperProcess;
  edtalis_hesap_kodu.OnHelperProcess := HelperProcess;
  edtalis_iade_hesap_kodu.OnHelperProcess := HelperProcess;

  lblhammadde_stok_hesap_adi.Caption := '';
  lblhammadde_kullanim_hesap_adi.Caption := '';
  lblyari_mamul_hesap_adi.Caption := '';
  lblsatis_hesap_adi.Caption := '';
  lblsatis_iade_hesap_adi.Caption := '';
  lblalis_hesap_adi.Caption := '';
  lblalis_iade_hesap_adi.Caption := '';
end;

procedure TfrmStkGrup.HelperProcess(Sender: TObject);
var
  LFrmVergi: TfrmSetChVergiOranlari;
  LVergi: TSetChVergiOrani;
  LFrmCH: TfrmHesapKartlari;
  LCH: TChHesapKarti;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtkdv_orani.Name then
      begin
        LVergi := TSetChVergiOrani.Create(Table.Database);
        LFrmVergi := TfrmSetChVergiOranlari.Create(TEdit(Sender), Self, LVergi, fomNormal, True);
        try
          LFrmVergi.ShowModal;
          if LFrmVergi.DataAktar then
          begin
            if LFrmVergi.CleanAndClose then
            begin
              TEdit(Sender).Clear
            end
            else
            begin
              TEdit(Sender).Text := LVergi.VergiOrani.AsString;

              edtsatis_hesap_kodu.Text := LVergi.SatisHesapKodu.AsString;
              lblsatis_hesap_adi.Caption := LVergi.SatisHesapAdi.AsString;
              edtsatis_iade_hesap_kodu.Text := LVergi.SatisIadeHesapKodu.AsString;
              lblsatis_iade_hesap_adi.Caption := LVergi.SatisIadeHesapAdi.AsString;

              edtalis_hesap_kodu.Text := LVergi.AlisHesapKodu.AsString;
              lblalis_hesap_adi.Caption := LVergi.AlisHesapAdi.AsString;
              edtalis_iade_hesap_kodu.Text := LVergi.AlisIadeHesapKodu.AsString;
              lblalis_iade_hesap_adi.Caption := LVergi.AlisIadeHesapAdi.AsString;
            end;
          end;
        finally
          LFrmVergi.Free;
        end;
      end
      else if TEdit(Sender).Name = edthammadde_stok_hesap_kodu.Name then
      begin
        LCH := TChHesapKarti.Create(Table.Database);
        LFrmCH := TfrmHesapKartlari.Create(TEdit(Sender), Self, LCH, fomNormal, True);
        try
          LFrmCH.ShowModal;
          if LFrmCH.DataAktar then
          begin
            if LFrmCH.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblhammadde_stok_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := LCH.HesapKodu.AsString;
              lblhammadde_stok_hesap_adi.Caption := LCH.HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmCH.Free;
        end;
      end
      else if TEdit(Sender).Name = edthammadde_kullanim_hesap_kodu.Name then
      begin
        LCH := TChHesapKarti.Create(Table.Database);
        LFrmCH := TfrmHesapKartlari.Create(TEdit(Sender), Self, LCH, fomNormal, True);
        try
          LFrmCH.ShowModal;
          if LFrmCH.DataAktar then
          begin
            if LFrmCH.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblhammadde_kullanim_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := LCH.HesapKodu.AsString;
              lblhammadde_kullanim_hesap_adi.Caption := LCH.HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmCH.Free;
        end;
      end
      else if TEdit(Sender).Name = edtyari_mamul_hesap_kodu.Name then
      begin
        LCH := TChHesapKarti.Create(Table.Database);
        LFrmCH := TfrmHesapKartlari.Create(TEdit(Sender), Self, LCH, fomNormal, True);
        try
          LFrmCH.ShowModal;
          if LFrmCH.DataAktar then
          begin
            if LFrmCH.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblyari_mamul_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := LCH.HesapKodu.AsString;
              lblyari_mamul_hesap_adi.Caption := LCH.HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmCH.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmStkGrup.RefreshData;
begin
  edtgrup.Text := TStkGruplar(Table).Grup.AsString;
  edtkdv_orani.Text := TStkGruplar(Table).KDVOrani.AsString;
  edthammadde_stok_hesap_kodu.Text := TStkGruplar(Table).HammaddeStokHesapKodu.AsString;
  lblhammadde_stok_hesap_adi.Caption := TStkGruplar(Table).HammaddeStokHesapAdi.AsString;
  edthammadde_kullanim_hesap_kodu.Text := TStkGruplar(Table).HammaddeKullanimHesapKodu.AsString;
  lblhammadde_kullanim_hesap_adi.Caption := TStkGruplar(Table).HammaddeKullanimHesapAdi.AsString;
  edtyari_mamul_hesap_kodu.Text := TStkGruplar(Table).YariMamulHesapKodu.AsString;
  lblyari_mamul_hesap_adi.Caption := TStkGruplar(Table).YariMamulHesapAdi.AsString;
  edtsatis_hesap_kodu.Text := TStkGruplar(Table).SatisHesapKodu.AsString;
  lblsatis_hesap_adi.Caption := TStkGruplar(Table).SatisHesapAdi.AsString;
  edtsatis_iade_hesap_kodu.Text := TStkGruplar(Table).SatisIadeHesapKodu.AsString;
  lblsatis_iade_hesap_adi.Caption := TStkGruplar(Table).SatisIadeHesapAdi.AsString;
  edtalis_hesap_kodu.Text := TStkGruplar(Table).AlisHesapKodu.AsString;
  lblalis_hesap_adi.Caption := TStkGruplar(Table).AlisHesapAdi.AsString;
  edtalis_iade_hesap_kodu.Text := TStkGruplar(Table).AlisIadeHesapKodu.AsString;
  lblalis_iade_hesap_adi.Caption := TStkGruplar(Table).AlisIadeHesapAdi.AsString;
end;

procedure TfrmStkGrup.Repaint;
begin
  inherited;
  edtsatis_hesap_kodu.ReadOnly := True;
  edtsatis_iade_hesap_kodu.ReadOnly := True;
  edtalis_hesap_kodu.ReadOnly := True;
  edtalis_iade_hesap_kodu.ReadOnly := True;
end;

end.

