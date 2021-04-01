unit ufrmStkStokGrubu;

interface

{$I ThsERP.inc}

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  StrUtils,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.Samples.Spin,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmStkStokGrubu = class(TfrmBaseInputDB)
    lblstok_grubu: TLabel;
    lblkdv_orani: TLabel;
    lblalis_kodu: TLabel;
    lblalis_iade_kodu: TLabel;
    lblsatis_kodu: TLabel;
    lblsatis_iade_kodu: TLabel;
    lblihracat_kodu: TLabel;
    lblhammadde_kodu: TLabel;
    lblmamul_kodu: TLabel;
    edtstok_grubu: TEdit;
    edtkdv_orani: TEdit;
    edtalis_kodu: TEdit;
    edtalis_iade_kodu: TEdit;
    edtsatis_kodu: TEdit;
    edtsatis_iade_kodu: TEdit;
    edtihracat_kodu: TEdit;
    edthammadde_kodu: TEdit;
    edtmamul_kodu: TEdit;
    lblalis_kodu_val: TLabel;
    lblalis_iade_kodu_val: TLabel;
    lblsatis_kodu_val: TLabel;
    lblsatis_iade_kodu_val: TLabel;
    lblihracat_kodu_val: TLabel;
    lblhammadde_kodu_val: TLabel;
    lblmamul_kodu_val: TLabel;
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
  Ths.Erp.Database.Singleton,
  Ths.Erp.Globals,
  Ths.Erp.Database.Table.StkStokGrubu,
  ufrmChHesapKartlari,
  Ths.Erp.Database.Table.ChHesapKarti,
  ufrmSetChVergiOranlari,
  Ths.Erp.Database.Table.SetChVergiOrani;

{$R *.dfm}

procedure TfrmStkStokGrubu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkStokGrubu(Table).StokGrubu.Value := edtstok_grubu.Text;
      TStkStokGrubu(Table).KDVOrani.Value := edtkdv_orani.Text;
      TStkStokGrubu(Table).IhracatKodu.Value := edtihracat_kodu.Text;
      TStkStokGrubu(Table).HammaddeKodu.Value := edthammadde_kodu.Text;
      TStkStokGrubu(Table).MamulKodu.Value := edtmamul_kodu.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmStkStokGrubu.FormCreate(Sender: TObject);
begin
  inherited;

  edtkdv_orani.OnHelperProcess := HelperProcess;
  edtihracat_kodu.OnHelperProcess := HelperProcess;
  edthammadde_kodu.OnHelperProcess := HelperProcess;
  edtmamul_kodu.OnHelperProcess := HelperProcess;

  lblalis_kodu_val.Caption := '';
  lblalis_iade_kodu_val.Caption := '';
  lblsatis_kodu_val.Caption := '';
  lblsatis_iade_kodu_val.Caption := '';
  lblihracat_kodu_val.Caption := '';
  lblhammadde_kodu_val.Caption := '';
  lblmamul_kodu_val.Caption := '';
end;

procedure TfrmStkStokGrubu.FormDestroy(Sender: TObject);
begin
  inherited;
end;

procedure TfrmStkStokGrubu.HelperProcess(Sender: TObject);
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
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(LVergi.VergiOrani));
              edtsatis_kodu.Text := VarToStr(FormatedVariantVal(LVergi.SatisKodu));
              lblsatis_kodu_val.Caption := VarToStr(FormatedVariantVal(LVergi.SatisAdi));
              edtsatis_iade_kodu.Text := VarToStr(FormatedVariantVal(LVergi.SatisIadeKodu));
              lblsatis_iade_kodu_val.Caption := VarToStr(FormatedVariantVal(LVergi.SatisIadeAdi));
              edtalis_kodu.Text := VarToStr(FormatedVariantVal(LVergi.AlisKodu));
              lblalis_kodu_val.Caption := VarToStr(FormatedVariantVal(LVergi.AlisAdi));
              edtalis_iade_kodu.Text := VarToStr(FormatedVariantVal(LVergi.AlisIadeKodu));
              lblalis_iade_kodu_val.Caption := VarToStr(FormatedVariantVal(LVergi.AlisIadeAdi));
            end;
          end;
        finally
          LFrmVergi.Free;
        end;
      end
      else if TEdit(Sender).Name = edtihracat_kodu.Name then
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
              lblihracat_kodu_val.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(LCH.HesapKodu));
              lblihracat_kodu_val.Caption := VarToStr(FormatedVariantVal(LCH.HesapIsmi));
            end;
          end;
        finally
          LFrmCH.Free;
        end;
      end
      else if TEdit(Sender).Name = edthammadde_kodu.Name then
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
              lblhammadde_kodu_val.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(LCH.HesapKodu));
              lblhammadde_kodu_val.Caption := VarToStr(FormatedVariantVal(LCH.HesapIsmi));
            end;
          end;
        finally
          LFrmCH.Free;
        end;
      end
      else if TEdit(Sender).Name = edtmamul_kodu.Name then
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
              lblmamul_kodu_val.Caption := '';
            end
            else
            begin
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(LCH.HesapKodu));
              lblmamul_kodu_val.Caption := VarToStr(FormatedVariantVal(LCH.HesapIsmi));
            end;
          end;
        finally
          LFrmCH.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmStkStokGrubu.RefreshData;
begin
  edtstok_grubu.Text := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).StokGrubu));
  edtkdv_orani.Text := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).KDVOrani));
  edtsatis_kodu.Text := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).SatisKodu));
  lblsatis_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).SatisAdi));
  edtsatis_iade_kodu.Text := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).SatisIadeKodu));
  lblsatis_iade_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).SatisIadeAdi));
  edtalis_kodu.Text := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).AlisKodu));
  lblalis_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).AlisAdi));
  edtalis_iade_kodu.Text := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).AlisIadeKodu));
  lblalis_iade_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).AlisIadeAdi));
  edtihracat_kodu.Text := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).IhracatKodu));
  lblihracat_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).IhracatAdi));
  edthammadde_kodu.Text := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).HammaddeKodu));
  lblhammadde_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).HammaddeAdi));
  edtmamul_kodu.Text := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).MamulKodu));
  lblmamul_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(Table).MamulAdi));
end;

procedure TfrmStkStokGrubu.Repaint;
begin
  inherited;
  edtsatis_kodu.ReadOnly := True;
  edtsatis_iade_kodu.ReadOnly := True;
  edtalis_kodu.ReadOnly := True;
  edtalis_iade_kodu.ReadOnly := True;
end;

end.
