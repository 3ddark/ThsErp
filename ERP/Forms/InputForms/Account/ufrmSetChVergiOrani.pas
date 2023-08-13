unit ufrmSetChVergiOrani;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  Vcl.Samples.Spin, Vcl.AppEvnts, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB, Ths.Constants,
  Ths.Database.Table.ChHesapKarti;

type
  TfrmSetChVergiOrani = class(TfrmBaseInputDB)
    lblalis_iade_hesap_kodu: TLabel;
    lblalis_hesap_kodu: TLabel;
    lblsatis_iade_hesap_kodu: TLabel;
    lblsatis_hesap_kodu: TLabel;
    lblvergi_orani: TLabel;
    edtvergi_orani: TEdit;
    edtsatis_hesap_kodu: TEdit;
    edtsatis_iade_hesap_kodu: TEdit;
    edtalis_hesap_kodu: TEdit;
    edtalis_iade_hesap_kodu: TEdit;
    lblalis_hesap_adi: TLabel;
    lblalis_iade_hesap_adi: TLabel;
    lblsatis_hesap_adi: TLabel;
    lblsatis_iade_hesap_adi: TLabel;
    lblihracat_iade_hesap_kodu: TLabel;
    lblihracat_hesap_kodu: TLabel;
    lblihracat_hesap_adi: TLabel;
    lblihracat_iade_hesap_adi: TLabel;
    edtihracat_hesap_kodu: TEdit;
    edtihracat_iade_hesap_kodu: TEdit;
    edtithalat_hesap_kodu: TEdit;
    edtithalat_iade_hesap_kodu: TEdit;
    lblithalat_iade_hesap_adi: TLabel;
    lblithalat_hesap_adi: TLabel;
    lblithalat_hesap_kodu: TLabel;
    lblithalat_iade_hesap_kodu: TLabel;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Globals,
  ufrmChHesapKartlari,
  Ths.Database.Table.SetChVergiOrani;

{$R *.dfm}

procedure TfrmSetChVergiOrani.FormShow(Sender: TObject);
begin
  edtsatis_hesap_kodu.OnHelperProcess := HelperProcess;
  edtsatis_iade_hesap_kodu.OnHelperProcess := HelperProcess;
  edtihracat_hesap_kodu.OnHelperProcess := HelperProcess;
  edtihracat_iade_hesap_kodu.OnHelperProcess := HelperProcess;
  edtalis_hesap_kodu.OnHelperProcess := HelperProcess;
  edtalis_iade_hesap_kodu.OnHelperProcess := HelperProcess;
  edtithalat_hesap_kodu.OnHelperProcess := HelperProcess;
  edtithalat_iade_hesap_kodu.OnHelperProcess := HelperProcess;

  inherited;
end;

procedure TfrmSetChVergiOrani.HelperProcess(Sender: TObject);
var
  LFrmHesap: TfrmHesapKartlari;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if (TEdit(Sender).Name = edtsatis_hesap_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblsatis_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := TChHesapKarti(LFrmHesap.Table).HesapKodu.AsString;
              lblsatis_hesap_adi.Caption := TChHesapKarti(LFrmHesap.Table).HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtsatis_iade_hesap_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblsatis_iade_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := TChHesapKarti(LFrmHesap.Table).HesapKodu.AsString;
              lblsatis_iade_hesap_adi.Caption := TChHesapKarti(LFrmHesap.Table).HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtihracat_hesap_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblihracat_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := TChHesapKarti(LFrmHesap.Table).HesapKodu.AsString;
              lblihracat_hesap_adi.Caption := TChHesapKarti(LFrmHesap.Table).HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtihracat_iade_hesap_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblihracat_iade_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := TChHesapKarti(LFrmHesap.Table).HesapKodu.AsString;
              lblihracat_iade_hesap_adi.Caption := TChHesapKarti(LFrmHesap.Table).HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtalis_hesap_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblalis_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := TChHesapKarti(LFrmHesap.Table).HesapKodu.AsString;
              lblalis_hesap_adi.Caption := TChHesapKarti(LFrmHesap.Table).HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtalis_iade_hesap_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblalis_iade_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := TChHesapKarti(LFrmHesap.Table).HesapKodu.AsString;
              lblalis_iade_hesap_adi.Caption := TChHesapKarti(LFrmHesap.Table).HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtithalat_hesap_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblithalat_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := TChHesapKarti(LFrmHesap.Table).HesapKodu.AsString;
              lblithalat_hesap_adi.Caption := TChHesapKarti(LFrmHesap.Table).HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtithalat_iade_hesap_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblithalat_iade_hesap_adi.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := TChHesapKarti(LFrmHesap.Table).HesapKodu.AsString;
              lblithalat_iade_hesap_adi.Caption := TChHesapKarti(LFrmHesap.Table).HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
    end
  end;
end;

procedure TfrmSetChVergiOrani.RefreshData;
begin
  edtvergi_orani.Text := TSetChVergiOrani(Table).VergiOrani.AsString;
  edtsatis_hesap_kodu.Text := TSetChVergiOrani(Table).SatisHesapKodu.AsString;
  lblsatis_hesap_adi.Caption := TSetChVergiOrani(Table).SatisHesapAdi.AsString;
  edtsatis_iade_hesap_kodu.Text := TSetChVergiOrani(Table).SatisIadeHesapKodu.AsString;
  lblsatis_iade_hesap_adi.Caption := TSetChVergiOrani(Table).SatisIadeHesapAdi.AsString;
  edtihracat_hesap_kodu.Text := TSetChVergiOrani(Table).IhracatHesapKodu.AsString;
  lblihracat_hesap_adi.Caption := TSetChVergiOrani(Table).IhracatHesapAdi.AsString;
  edtihracat_iade_hesap_kodu.Text := TSetChVergiOrani(Table).IhracatIadeHesapKodu.AsString;
  lblihracat_iade_hesap_adi.Caption := TSetChVergiOrani(Table).IhracatIadeHesapAdi.AsString;
  edtalis_hesap_kodu.Text := TSetChVergiOrani(Table).AlisHesapKodu.AsString;
  lblalis_hesap_adi.Caption := TSetChVergiOrani(Table).AlisHesapAdi.AsString;
  edtalis_iade_hesap_kodu.Text := TSetChVergiOrani(Table).AlisIadeHesapKodu.AsString;
  lblalis_iade_hesap_adi.Caption := TSetChVergiOrani(Table).AlisIadeHesapAdi.AsString;
  edtithalat_hesap_kodu.Text := TSetChVergiOrani(Table).IthalatHesapKodu.AsString;
  lblithalat_hesap_adi.Caption := TSetChVergiOrani(Table).IthalatHesapAdi.AsString;
  edtithalat_iade_hesap_kodu.Text := TSetChVergiOrani(Table).IthalatIadeHesapKodu.AsString;
  lblithalat_iade_hesap_adi.Caption := TSetChVergiOrani(Table).IthalatIadeHesapAdi.AsString;
end;

procedure TfrmSetChVergiOrani.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetChVergiOrani(Table).VergiOrani.Value := StrToFloatDef(edtvergi_orani.Text, 0);
      TSetChVergiOrani(Table).SatisHesapKodu.Value := edtsatis_hesap_kodu.Text;
      TSetChVergiOrani(Table).SatisIadeHesapKodu.Value := edtsatis_iade_hesap_kodu.Text;
      TSetChVergiOrani(Table).IhracatHesapKodu.Value := edtihracat_hesap_kodu.Text;
      TSetChVergiOrani(Table).IhracatIadeHesapKodu.Value := edtihracat_iade_hesap_kodu.Text;
      TSetChVergiOrani(Table).AlisHesapKodu.Value := edtalis_hesap_kodu.Text;
      TSetChVergiOrani(Table).AlisIadeHesapKodu.Value := edtalis_iade_hesap_kodu.Text;
      TSetChVergiOrani(Table).IthalatHesapKodu.Value := edtithalat_hesap_kodu.Text;
      TSetChVergiOrani(Table).IthalatIadeHesapKodu.Value := edtithalat_iade_hesap_kodu.Text;

      TSetChVergiOrani(Table).Validate;

      inherited;
    end;
  end
  else
    inherited;
end;

end.