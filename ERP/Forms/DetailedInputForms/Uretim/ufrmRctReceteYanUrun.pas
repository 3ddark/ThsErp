unit ufrmRctReceteYanUrun;

interface

{$I Ths.inc}

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

  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,

  ufrmBase,
  ufrmBaseDetaylarDetay,
  Ths.Database.Table.UrtReceteler;

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
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.StkKartlar,
  ufrmStkKartlar,
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
  LFrmStokKarti: TfrmStkKartlar;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtstok_kodu.Name then
      begin
        LFrmStokKarti := TfrmStkKartlar.Create(edtstok_kodu, Self, TStkKart.Create(Table.Database), fomNormal, True);
        try
          LFrmStokKarti.ShowModal;

          if LFrmStokKarti.DataAktar then
          begin
            edtstok_kodu.Text := TStkKart(LFrmStokKarti.Table).StokKodu.AsString;
            lblstok_aciklama.Caption := TStkKart(LFrmStokKarti.Table).StokAdi.AsString;
            lblmiktar_birim.Caption := TStkKart(LFrmStokKarti.Table).OlcuBirimi.AsString;
            TUrtReceteYanUrun(Table).Fiyat.Value := TStkKart(LFrmStokKarti.Table).AlisFiyat.AsFloat;
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
  edtstok_kodu.Text := TUrtReceteYanUrun(Table).StokKodu.AsString;
  lblstok_aciklama.Caption := TUrtReceteYanUrun(Table).StokAdi.AsString;
  edtmiktar.Text := TUrtReceteYanUrun(Table).Miktar.AsString;
  lblmiktar_birim.Caption := TUrtReceteYanUrun(Table).OlcuBirimi.AsString;
end;

procedure TfrmRctReceteYanUrun.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TUrtReceteYanUrun(Table).StokKodu.Value := edtstok_kodu.Text;
      TUrtReceteYanUrun(Table).StokAdi.Value := lblstok_aciklama.Caption;
      TUrtReceteYanUrun(Table).Miktar.Value := StrToFloatDef(edtMiktar.Text, 0);
      TUrtReceteYanUrun(Table).OlcuBirimi.Value := lblmiktar_birim.Caption;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
