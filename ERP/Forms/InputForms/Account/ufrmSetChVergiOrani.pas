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
    lblalis_iade_kodu: TLabel;
    lblalis_kodu: TLabel;
    lblsatis_iade_kodu: TLabel;
    lblsatis_kodu: TLabel;
    lblvergi_orani: TLabel;
    edtvergi_orani: TEdit;
    edtsatis_kodu: TEdit;
    edtsatis_iade_kodu: TEdit;
    edtalis_kodu: TEdit;
    edtalis_iade_kodu: TEdit;
    lblalis_hesabi_val: TLabel;
    lblalis_iade_hesabi_val: TLabel;
    lblsatis_hesabi_val: TLabel;
    lblsatis_iade_hesabi_val: TLabel;
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
  edtsatis_kodu.OnHelperProcess := HelperProcess;
  edtsatis_iade_kodu.OnHelperProcess := HelperProcess;
  edtalis_kodu.OnHelperProcess := HelperProcess;
  edtalis_iade_kodu.OnHelperProcess := HelperProcess;

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
      if (TEdit(Sender).Name = edtsatis_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblsatis_hesabi_val.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := TChHesapKarti(LFrmHesap.Table).HesapKodu.AsString;
              lblsatis_hesabi_val.Caption := TChHesapKarti(LFrmHesap.Table).HesapIsmi.AsString;
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtsatis_iade_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblsatis_iade_hesabi_val.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(TChHesapKarti(LFrmHesap.Table).HesapKodu));
              lblsatis_iade_hesabi_val.Caption := VarToStr(FormatedVariantVal(TChHesapKarti(LFrmHesap.Table).HesapIsmi));
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtalis_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblalis_hesabi_val.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(TChHesapKarti(LFrmHesap.Table).HesapKodu));
              lblalis_hesabi_val.Caption := VarToStr(FormatedVariantVal(TChHesapKarti(LFrmHesap.Table).HesapIsmi));
            end;
          end;
        finally
          LFrmHesap.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtalis_iade_kodu.Name) then
      begin
        LFrmHesap := TfrmHesapKartlari.Create(TEdit(Sender), Self, TChHesapKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmHesap.ShowModal;
          if LFrmHesap.DataAktar then
          begin
            if LFrmHesap.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              lblalis_iade_hesabi_val.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(TChHesapKarti(LFrmHesap.Table).HesapKodu));
              lblalis_iade_hesabi_val.Caption := VarToStr(FormatedVariantVal(TChHesapKarti(LFrmHesap.Table).HesapIsmi));
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
  edtvergi_orani.Text := VarToStr(FormatedVariantVal(TSetChVergiOrani(Table).VergiOrani));
  edtsatis_kodu.Text := VarToStr(FormatedVariantVal(TSetChVergiOrani(Table).SatisKodu));
  lblsatis_hesabi_val.Caption := VarToStr(FormatedVariantVal(TSetChVergiOrani(Table).SatisAdi));
  edtsatis_iade_kodu.Text := VarToStr(FormatedVariantVal(TSetChVergiOrani(Table).SatisIadeKodu));
  lblsatis_iade_hesabi_val.Caption := VarToStr(FormatedVariantVal(TSetChVergiOrani(Table).SatisIadeAdi));
  edtalis_kodu.Text := VarToStr(FormatedVariantVal(TSetChVergiOrani(Table).AlisKodu));
  lblalis_hesabi_val.Caption := VarToStr(FormatedVariantVal(TSetChVergiOrani(Table).AlisAdi));
  edtalis_iade_kodu.Text := VarToStr(FormatedVariantVal(TSetChVergiOrani(Table).AlisIadeKodu));
  lblalis_iade_hesabi_val.Caption := VarToStr(FormatedVariantVal(TSetChVergiOrani(Table).AlisIadeAdi));
end;

procedure TfrmSetChVergiOrani.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetChVergiOrani(Table).VergiOrani.Value := StrToFloatDef(edtvergi_orani.Text, 0);
      TSetChVergiOrani(Table).SatisKodu.Value := edtsatis_kodu.Text;
      TSetChVergiOrani(Table).SatisIadeKodu.Value := edtsatis_iade_kodu.Text;
      TSetChVergiOrani(Table).AlisKodu.Value := edtalis_kodu.Text;
      TSetChVergiOrani(Table).AlisIadeKodu.Value := edtalis_iade_kodu.Text;

      TSetChVergiOrani(Table).Validate;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
