unit ufrmStkStokGrubu;

interface

{$I Ths.inc}

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
  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,
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
  Ths.Globals,
  Ths.Database.Table.StkGruplar,
  ufrmChHesapKartlari,
  Ths.Database.Table.ChHesapKarti,
  ufrmSetChVergiOranlari,
  Ths.Database.Table.SetChVergiOrani;

{$R *.dfm}

procedure TfrmStkStokGrubu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkStokGrubu(Table).Grup.Value := edtstok_grubu.Text;
      TStkStokGrubu(Table).KDVOrani.Value := edtkdv_orani.Text;
      TStkStokGrubu(Table).IhracHesapKodu.Value := edtihracat_kodu.Text;
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
              TEdit(Sender).Text := LVergi.VergiOrani.AsString;
              edtsatis_kodu.Text := LVergi.SatisHesapKodu.AsString;
              lblsatis_kodu_val.Caption := LVergi.SatisHesapAdi.AsString;
              edtsatis_iade_kodu.Text := LVergi.SatisIadeHesapKodu.AsString;
              lblsatis_iade_kodu_val.Caption := LVergi.SatisIadeHesapAdi.AsString;
              edtalis_kodu.Text := LVergi.AlisHesapKodu.AsString;
              lblalis_kodu_val.Caption := LVergi.AlisHesapAdi.AsString;
              edtalis_iade_kodu.Text := LVergi.AlisIadeHesapKodu.AsString;
              lblalis_iade_kodu_val.Caption := LVergi.AlisIadeHesapAdi.AsString;;
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
              TEdit(Sender).Text := LCH.HesapKodu.AsString;
              lblihracat_kodu_val.Caption := LCH.HesapIsmi.AsString;
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
              TEdit(Sender).Text := LCH.HesapKodu.AsString;
              lblhammadde_kodu_val.Caption := LCH.HesapIsmi.AsString;
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
              TEdit(Sender).Text := LCH.HesapKodu.AsString;
              lblmamul_kodu_val.Caption := LCH.HesapIsmi.AsString;
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
  edtstok_grubu.Text := TStkStokGrubu(Table).Grup.AsString;
  edtkdv_orani.Text := TStkStokGrubu(Table).KDVOrani.AsString;
  edtsatis_kodu.Text := TStkStokGrubu(Table).SatisHesapKodu.AsString;
  lblsatis_kodu_val.Caption := TStkStokGrubu(Table).SatisHesapAdi.AsString;
  edtsatis_iade_kodu.Text := TStkStokGrubu(Table).SatisIadeHesapKodu.AsString;
  lblsatis_iade_kodu_val.Caption := TStkStokGrubu(Table).SatisIadeHesapAdi.AsString;
  edtalis_kodu.Text := TStkStokGrubu(Table).AlisHesapKodu.AsString;
  lblalis_kodu_val.Caption := TStkStokGrubu(Table).AlisHesapAdi.AsString;
  edtalis_iade_kodu.Text := TStkStokGrubu(Table).AlisIadeHesapKodu.AsString;
  lblalis_iade_kodu_val.Caption := TStkStokGrubu(Table).AlisIadeHesapAdi.AsString;
  edtihracat_kodu.Text := TStkStokGrubu(Table).IhracHesapKodu.AsString;
  lblihracat_kodu_val.Caption := TStkStokGrubu(Table).IhracHesapAdi.AsString;
  edthammadde_kodu.Text := TStkStokGrubu(Table).HammaddeKodu.AsString;
  lblhammadde_kodu_val.Caption := TStkStokGrubu(Table).HammaddeAdi.AsString;
  edtmamul_kodu.Text := TStkStokGrubu(Table).MamulKodu.AsString;
  lblmamul_kodu_val.Caption := TStkStokGrubu(Table).MamulAdi.AsString;
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
