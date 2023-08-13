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
    lblihracat_iade_hesap_kodu: TLabel;
    lblihracat_hesap_kodu: TLabel;
    lblihracat_hesap_adi: TLabel;
    lblihracat_iade_hesap_adi: TLabel;
    lblithalat_iade_hesap_adi: TLabel;
    lblithalat_hesap_adi: TLabel;
    lblithalat_hesap_kodu: TLabel;
    lblithalat_iade_hesap_kodu: TLabel;
    edtsatis_hesap_kodu: TEdit;
    edtsatis_iade_hesap_kodu: TEdit;
    edtalis_hesap_kodu: TEdit;
    edtalis_iade_hesap_kodu: TEdit;
    edtihracat_hesap_kodu: TEdit;
    edtihracat_iade_hesap_kodu: TEdit;
    edtithalat_hesap_kodu: TEdit;
    edtithalat_iade_hesap_kodu: TEdit;
    edthammadde_hesap_kodu: TEdit;
    edtmamul_hesap_kodu: TEdit;
    lblmamul_hesap_adi: TLabel;
    lblhammadde_hesap_adi: TLabel;
    lblhammadde_hesap_kodu: TLabel;
    lblmamul_hesap_kodu: TLabel;
  protected
    procedure HelperProcess(Sender: TObject); override;
  public
    procedure Repaint; override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table.StkGruplar, ufrmChHesapKartlari,
  Ths.Database.Table.ChHesapKarti, ufrmSetChVergiOranlari,
  Ths.Database.Table.SetChVergiOrani;

{$R *.dfm}

procedure TfrmStkGrup.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkGruplar(Table).Grup.Value := edtgrup.Text;
      TStkGruplar(Table).KDVOrani.Value := edtkdv_orani.Text;
      TStkGruplar(Table).HammaddeHesapKodu.Value := edthammadde_hesap_kodu.Text;
      TStkGruplar(Table).MamulHesapKodu.Value := edtmamul_hesap_kodu.Text;

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
  edthammadde_hesap_kodu.OnHelperProcess := HelperProcess;
  edtmamul_hesap_kodu.OnHelperProcess := HelperProcess;

  edtsatis_hesap_kodu.OnHelperProcess := HelperProcess;
  edtsatis_hesap_kodu.OnHelperProcess := HelperProcess;
  edtihracat_hesap_kodu.OnHelperProcess := HelperProcess;
  edtihracat_iade_hesap_kodu.OnHelperProcess := HelperProcess;
  edtalis_hesap_kodu.OnHelperProcess := HelperProcess;
  edtalis_iade_hesap_kodu.OnHelperProcess := HelperProcess;
  edtithalat_hesap_kodu.OnHelperProcess := HelperProcess;
  edtithalat_iade_hesap_kodu.OnHelperProcess := HelperProcess;

  lblhammadde_hesap_adi.Caption := '';
  lblmamul_hesap_adi.Caption := '';
  lblsatis_hesap_adi.Caption := '';
  lblsatis_iade_hesap_adi.Caption := '';
  lblihracat_hesap_adi.Caption := '';
  lblihracat_iade_hesap_adi.Caption := '';
  lblalis_hesap_adi.Caption := '';
  lblalis_iade_hesap_adi.Caption := '';
  lblithalat_hesap_adi.Caption := '';
  lblithalat_iade_hesap_adi.Caption := '';
end;

procedure TfrmStkGrup.FormDestroy(Sender: TObject);
begin
  inherited;
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

              edtihracat_hesap_kodu.Text := LVergi.IhracatHesapKodu.AsString;
              lblihracat_hesap_adi.Caption := LVergi.IhracatHesapAdi.AsString;
              edtihracat_iade_hesap_kodu.Text := LVergi.IhracatIadeHesapKodu.AsString;
              lblihracat_iade_hesap_adi.Caption := LVergi.IhracatIadeHesapAdi.AsString;

              edtalis_hesap_kodu.Text := LVergi.AlisHesapKodu.AsString;
              lblalis_hesap_adi.Caption := LVergi.AlisHesapAdi.AsString;
              edtalis_iade_hesap_kodu.Text := LVergi.AlisIadeHesapKodu.AsString;
              lblalis_iade_hesap_adi.Caption := LVergi.AlisIadeHesapAdi.AsString;

              edtithalat_hesap_kodu.Text := LVergi.IthalatHesapKodu.AsString;
              lblithalat_hesap_adi.Caption := LVergi.IthalatHesapAdi.AsString;
              edtithalat_iade_hesap_kodu.Text := LVergi.IthalatIadeHesapKodu.AsString;
              lblithalat_iade_hesap_adi.Caption := LVergi.IthalatIadeHesapAdi.AsString;
            end;
          end;
        finally
          LFrmVergi.Free;
        end;
      end
      else if TEdit(Sender).Name = edthammadde_hesap_kodu.Name then
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
              lblhammadde_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := LCH.HesapKodu.AsString;
              lblhammadde_hesap_adi.Caption := LCH.HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmCH.Free;
        end;
      end
      else if TEdit(Sender).Name = edtmamul_hesap_kodu.Name then
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
              lblmamul_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := LCH.HesapKodu.AsString;
              lblmamul_hesap_adi.Caption := LCH.HesapIsmi.AsString;
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
  edthammadde_hesap_kodu.Text := TStkGruplar(Table).HammaddeHesapKodu.AsString;
  lblhammadde_hesap_adi.Caption := TStkGruplar(Table).HammaddeHesapAdi.AsString;
  edtmamul_hesap_kodu.Text := TStkGruplar(Table).MamulHesapKodu.AsString;
  lblmamul_hesap_adi.Caption := TStkGruplar(Table).MamulHesapAdi.AsString;
  edtsatis_hesap_kodu.Text := TStkGruplar(Table).SatisHesapKodu.AsString;
  lblsatis_hesap_adi.Caption := TStkGruplar(Table).SatisHesapAdi.AsString;
  edtsatis_iade_hesap_kodu.Text := TStkGruplar(Table).SatisIadeHesapKodu.AsString;
  lblsatis_iade_hesap_adi.Caption := TStkGruplar(Table).SatisIadeHesapAdi.AsString;
  edtihracat_hesap_kodu.Text := TStkGruplar(Table).IhracatHesapKodu.AsString;
  lblihracat_hesap_adi.Caption := TStkGruplar(Table).IhracatHesapAdi.AsString;
  edtihracat_iade_hesap_kodu.Text := TStkGruplar(Table).IhracatIadeHesapKodu.AsString;
  lblihracat_iade_hesap_adi.Caption := TStkGruplar(Table).IhracatIadeHesapAdi.AsString;
  edtalis_hesap_kodu.Text := TStkGruplar(Table).AlisHesapKodu.AsString;
  lblalis_hesap_adi.Caption := TStkGruplar(Table).AlisHesapAdi.AsString;
  edtalis_iade_hesap_kodu.Text := TStkGruplar(Table).AlisIadeHesapKodu.AsString;
  lblalis_iade_hesap_adi.Caption := TStkGruplar(Table).AlisIadeHesapAdi.AsString;
  edtithalat_hesap_kodu.Text := TStkGruplar(Table).IthalatHesapKodu.AsString;
  lblithalat_hesap_adi.Caption := TStkGruplar(Table).IthalatIhracHesapAdi.AsString;
  edtithalat_iade_hesap_kodu.Text := TStkGruplar(Table).IthalatIadeHesapKodu.AsString;
  lblithalat_iade_hesap_adi.Caption := TStkGruplar(Table).IthalatIadeHesapAdi.AsString;
end;

procedure TfrmStkGrup.Repaint;
begin
  inherited;
  edtsatis_hesap_kodu.ReadOnly := True;
  edtsatis_iade_hesap_kodu.ReadOnly := True;
  edtihracat_hesap_kodu.ReadOnly := True;
  edtihracat_iade_hesap_kodu.ReadOnly := True;
  edtalis_hesap_kodu.ReadOnly := True;
  edtalis_iade_hesap_kodu.ReadOnly := True;
  edtithalat_hesap_kodu.ReadOnly := True;
  edtithalat_iade_hesap_kodu.ReadOnly := True;
end;

end.

