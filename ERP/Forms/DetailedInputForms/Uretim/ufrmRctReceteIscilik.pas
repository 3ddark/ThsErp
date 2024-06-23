unit ufrmRctReceteIscilik;

interface

{$I Ths.inc}

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

  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,

  ufrmBase,
  ufrmBaseDetaylarDetay,
  Ths.Database.Table.UrtReceteler;

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
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.UrtIscilikler,
  ufrmUrtIscilikler,
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
  LFrmIsc: TfrmUrtIscilikler;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtgider_kodu.Name then
      begin
        LFrmIsc := TfrmUrtIscilikler.Create(edtgider_kodu, Self, TUrtIscilik.Create(Table.Database), fomNormal, True);
        try
          LFrmIsc.ShowModal;

          if LFrmIsc.DataAktar then
          begin
            edtgider_kodu.Text := TUrtIscilik(LFrmIsc.Table).GiderKodu.AsString;
            lblgider_adi.Caption := TUrtIscilik(LFrmIsc.Table).GiderAdi.AsString;
            lblmiktar_birim.Caption := TUrtIscilik(LFrmIsc.Table).Birim.AsString;
            edtfiyat.Text := TUrtIscilik(LFrmIsc.Table).Fiyat.AsString;
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
  edtgider_kodu.Text := TUrtReceteIscilik(Table).GiderKodu.AsString;
  lblgider_adi.Caption := TUrtReceteIscilik(Table).GiderAdi.AsString;
  edtmiktar.Text := TUrtReceteIscilik(Table).Miktar.AsString;
  lblmiktar_birim.Caption := TUrtReceteIscilik(Table).Birim.AsString;
  edtfiyat.Text := TUrtReceteIscilik(Table).Fiyat.AsString;
end;

procedure TfrmRctReceteIscilik.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TUrtReceteIscilik(Table).GiderKodu.Value := edtgider_kodu.Text;
      TUrtReceteIscilik(Table).GiderAdi.Value := lblgider_adi.Caption;
      TUrtReceteIscilik(Table).Miktar.Value := StrToFloatDef(edtMiktar.Text, 0);
      TUrtReceteIscilik(Table).Birim.Value := lblmiktar_birim.Caption;
      TUrtReceteIscilik(Table).Fiyat.Value := StrToFloatDef(edtfiyat.Text, 0);

      inherited;
    end;
  end
  else
    inherited;
end;

end.
