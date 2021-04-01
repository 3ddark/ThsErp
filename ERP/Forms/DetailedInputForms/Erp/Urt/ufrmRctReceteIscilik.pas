unit ufrmRctReceteIscilik;

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
  TfrmRctReceteIscilik = class(TfrmBaseDetaylarDetay)
    lblmiktar: TLabel;
    lblgider_kodu: TLabel;
    lblmiktar_birim: TLabel;
    edtgider_kodu: TEdit;
    edtmiktar: TEdit;
    lblgider_adi: TLabel;
    Label1: TLabel;
    lblfiyat_brm: TLabel;
    edtfiyat: TEdit;
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
  Ths.Erp.Database.Table.RctIscilikGideri,
  ufrmRctIscilikGiderleri,
  ufrmRctReceteDetaylar;

{$R *.dfm}

procedure TfrmRctReceteIscilik.FormCreate(Sender: TObject);
begin
  inherited;

  edtmiktar.Text := '1';
  lblmiktar.Caption := '';
  lblgider_adi.Caption := '';
end;

procedure TfrmRctReceteIscilik.FormShow(Sender: TObject);
begin
  edtgider_kodu.OnHelperProcess := HelperProcess;
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

procedure TfrmRctReceteIscilik.HelperProcess(Sender: TObject);
var
  LFrmIsc: TfrmRctIscilikGiderleri;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtgider_kodu.Name then
      begin
        LFrmIsc := TfrmRctIscilikGiderleri.Create(edtgider_kodu, Self, TRctIscilikGideri.Create(Table.Database), fomNormal, True);
        try
          LFrmIsc.ShowModal;

          if LFrmIsc.DataAktar then
          begin
            edtgider_kodu.Text := TRctIscilikGideri(LFrmIsc.Table).GiderKodu.Value;
            lblgider_adi.Caption := TRctIscilikGideri(LFrmIsc.Table).GiderAdi.Value;
            lblmiktar_birim.Caption := TRctIscilikGideri(LFrmIsc.Table).OlcuBirimi.Value;
            edtfiyat.Text := TRctIscilikGideri(LFrmIsc.Table).Fiyat.Value;
          end;
        finally
          LFrmIsc.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmRctReceteIscilik.RefreshData();
begin
  edtgider_kodu.Text := FormatedVariantVal(TRctReceteIscilik(Table).GiderKodu);
  lblgider_adi.Caption := FormatedVariantVal(TRctReceteIscilik(Table).GiderAdi);
  edtmiktar.Text := FormatedVariantVal(TRctReceteIscilik(Table).Miktar);
  lblmiktar_birim.Caption := FormatedVariantVal(TRctReceteIscilik(Table).Birim);
  edtfiyat.Text := FormatedVariantVal(TRctReceteIscilik(Table).Fiyat);
end;

procedure TfrmRctReceteIscilik.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TRctReceteIscilik(Table).GiderKodu.Value := edtgider_kodu.Text;
      TRctReceteIscilik(Table).GiderAdi.Value := lblgider_adi.Caption;
      TRctReceteIscilik(Table).Miktar.Value := StrToFloatDef(edtMiktar.Text, 0);
      TRctReceteIscilik(Table).Birim.Value := lblmiktar_birim.Caption;
      TRctReceteIscilik(Table).Fiyat.Value := StrToFloatDef(edtfiyat.Text, 0);

      if (FormMode = ifmUpdate) then
      begin
        TRctRecete(TfrmRctReceteDetaylar(ParentForm).Table).UpdateDetay(Table);
        TfrmRctReceteDetaylar(ParentForm).UpdateDetay(Table, Grid);
      end
      else if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
      begin
        TRctRecete(TfrmRctReceteDetaylar(ParentForm).Table).AddDetay( TRctReceteIscilik(TRctReceteIscilik(Table).Clone) );
        TfrmRctReceteDetaylar(ParentForm).AddDetay(Table, Grid);
      end;
      Close;
    end;
  end
  else
    inherited;
end;

end.
