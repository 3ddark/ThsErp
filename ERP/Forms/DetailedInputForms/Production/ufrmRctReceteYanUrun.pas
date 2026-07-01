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
  Ths.Database.Table.PrdBom;

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
  Ths.Database.Table.StkInventory,
  ufrmStkInventory,
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
  LFrmStokKarti: TfrmStkInventory;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtstok_kodu.Name then
      begin
        LFrmStokKarti := TfrmStkInventory.Create(edtstok_kodu, Self, TStkInventory.Create(Table.Database), fomNormal, True);
        try
          LFrmStokKarti.ShowModal;

          if LFrmStokKarti.DataAktar then
          begin
            edtstok_kodu.Text := TStkKart(LFrmStokKarti.Table).StokKodu.AsString;
            lblstok_aciklama.Caption := TStkKart(LFrmStokKarti.Table).StokAdi.AsString;
            lblmiktar_birim.Caption := TStkKart(LFrmStokKarti.Table).OlcuBirimi.AsString;
            TUrtBomByProduct(Table).Fiyat.Value := TStkKart(LFrmStokKarti.Table).AlisFiyat.AsFloat;
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
  edtstok_kodu.Text := TUrtBomByProduct(Table).UrunKodu.AsString;
  lblstok_aciklama.Caption := TUrtBomByProduct(Table).StokAdi.AsString;
  edtmiktar.Text := TUrtBomByProduct(Table).Miktar.AsString;
  lblmiktar_birim.Caption := TUrtBomByProduct(Table).OlcuBirimi.AsString;
end;

procedure TfrmRctReceteYanUrun.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TUrtBomByProduct(Table).UrunKodu.Value := edtstok_kodu.Text;
      TUrtBomByProduct(Table).StokAdi.Value := lblstok_aciklama.Caption;
      TUrtBomByProduct(Table).Miktar.Value := StrToFloatDef(edtMiktar.Text, 0);
      TUrtBomByProduct(Table).OlcuBirimi.Value := lblmiktar_birim.Caption;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
