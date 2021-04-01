unit ufrmRctReceteYanUrun;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
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
  TfrmRctReceteYanUrun = class(TfrmBaseDetaylarDetay)
    lblmiktar: TLabel;
    lblstok_kodu: TLabel;
    lblmiktar_birim: TLabel;
    edtstok_kodu: TEdit;
    edtmiktar: TEdit;
    lblstok_aciklama: TLabel;
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

procedure TfrmRctReceteYanUrun.FormCreate(Sender: TObject);
begin
  inherited;

  edtmiktar.Text := '1';
  lblmiktar.Caption := '';
  lblstok_aciklama.Caption := '';
end;

procedure TfrmRctReceteYanUrun.FormShow(Sender: TObject);
begin
  edtstok_kodu.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmRctReceteYanUrun.HelperProcess(Sender: TObject);
var
  LFrmStokKarti: TfrmStkStokKartlari;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtstok_kodu.Name then
      begin
        LFrmStokKarti := TfrmStkStokKartlari.Create(edtstok_kodu, Self, TStkStokKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmStokKarti.ShowModal;

          if LFrmStokKarti.DataAktar then
          begin
            edtstok_kodu.Text := TStkStokKarti(LFrmStokKarti.Table).StokKodu.Value;
            lblstok_aciklama.Caption := TStkStokKarti(LFrmStokKarti.Table).StokAdi.Value;
            lblmiktar_birim.Caption := TStkStokKarti(LFrmStokKarti.Table).OlcuBirimi.Value;
            TRctReceteYanUrun(Table).Fiyat.Value := TStkStokKarti(LFrmStokKarti.Table).AlisFiyat.Value;
          end;
        finally
          LFrmStokKarti.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmRctReceteYanUrun.RefreshData();
begin
  edtstok_kodu.Text := FormatedVariantVal(TRctReceteYanUrun(Table).StokKodu);
  lblstok_aciklama.Caption := FormatedVariantVal(TRctReceteYanUrun(Table).StokAdi);
  edtmiktar.Text := FormatedVariantVal(TRctReceteYanUrun(Table).Miktar);
  lblmiktar_birim.Caption := FormatedVariantVal(TRctReceteYanUrun(Table).OlcuBirimi);
end;

procedure TfrmRctReceteYanUrun.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TRctReceteYanUrun(Table).StokKodu.Value := edtstok_kodu.Text;
      TRctReceteYanUrun(Table).StokAdi.Value := lblstok_aciklama.Caption;
      TRctReceteYanUrun(Table).Miktar.Value := StrToFloatDef(edtMiktar.Text, 0);
      TRctReceteYanUrun(Table).OlcuBirimi.Value := lblmiktar_birim.Caption;

      if (FormMode = ifmUpdate) then
      begin
        TRctRecete(TfrmRctReceteDetaylar(ParentForm).Table).UpdateDetay(Table);
        TfrmRctReceteDetaylar(ParentForm).UpdateDetay(Table, Grid);
      end
      else if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
      begin
        TRctRecete(TfrmRctReceteDetaylar(ParentForm).Table).AddDetay( TRctReceteYanUrun(TRctReceteYanUrun(Table).Clone) );
        TfrmRctReceteDetaylar(ParentForm).AddDetay(Table, Grid);
      end;
      Close;
    end;
  end
  else
    inherited;
end;

end.
