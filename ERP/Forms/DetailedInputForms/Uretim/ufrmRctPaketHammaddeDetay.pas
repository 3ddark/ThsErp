unit ufrmRctPaketHammaddeDetay;

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
  TfrmRctPaketHammaddeDetay = class(TfrmBaseDetaylarDetay)
    lblfire_orani: TLabel;
    lblmiktar: TLabel;
    lblrecete: TLabel;
    lblstok_kodu: TLabel;
    lblmiktar_birim: TLabel;
    lblrecete_adi: TLabel;
    edtstok_kodu: TEdit;
    edtmiktar: TEdit;
    edtfire_orani: TEdit;
    cbbrecete: TComboBox;
    lblstok_aciklama: TLabel;
    procedure cbbreceteChange(Sender: TObject);
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

procedure TfrmRctPaketHammaddeDetay.cbbreceteChange(Sender: TObject);
begin
  if (cbbrecete.ItemIndex > -1) and Assigned(cbbrecete.Items.Objects[cbbrecete.ItemIndex]) then
    lblrecete.Caption := TUrtRecete(cbbrecete.Items.Objects[cbbrecete.ItemIndex]).ReceteAdi.Value;
end;

procedure TfrmRctPaketHammaddeDetay.FormCreate(Sender: TObject);
begin
  inherited;

  edtmiktar.Text := '1';
  edtfire_orani.Text := '0';
  lblmiktar.Caption := '';
  lblstok_aciklama.Caption := '';
  lblrecete_adi.Caption := '';
end;

procedure TfrmRctPaketHammaddeDetay.FormShow(Sender: TObject);
begin
  edtstok_kodu.OnHelperProcess := HelperProcess;
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

procedure TfrmRctPaketHammaddeDetay.HelperProcess(Sender: TObject);
var
  LFrmStokKarti: TfrmStkKartlar;
  LRecete: TUrtRecete;
  n1: Integer;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtstok_kodu.Name then
      begin
        LFrmStokKarti := TfrmStkKartlar.Create(edtstok_kodu, Self, TStkKart.Create(Table.Database), fomNormal, True);
        LRecete := TUrtRecete.Create(GDataBase);
        try
          LFrmStokKarti.ShowModal;

          if LFrmStokKarti.DataAktar then
          begin
            edtstok_kodu.Text := TStkKart(LFrmStokKarti.Table).StokKodu.Value;
            lblstok_aciklama.Caption := TStkKart(LFrmStokKarti.Table).StokAdi.Value;
            lblmiktar_birim.Caption := TStkKart(LFrmStokKarti.Table).OlcuBirimi.Value;
            TUrtReceteHammadde(Table).Fiyat.Value := TStkKart(LFrmStokKarti.Table).AlisFiyat.Value;

            LRecete.SelectToList(' AND ' + LRecete.ReceteKodu.FieldName + '=' + QuotedStr(edtstok_kodu.Text), False, False);
            if LRecete.List.Count > 0 then
            begin
              cbbrecete.Clear;
              for n1 := 0 to LRecete.List.Count-1 do
                cbbrecete.Items.AddObject(TUrtRecete(LRecete.List[n1]).ReceteKodu.Value, TUrtRecete(TUrtRecete(LRecete.List[n1]).Clone));

              cbbrecete.ItemIndex := 0;
            end;
          end;
        finally
          LFrmStokKarti.Free;
          LRecete.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmRctPaketHammaddeDetay.RefreshData();
begin
  edtstok_kodu.Text := TUrtReceteHammadde(Table).StokKodu.AsString;
  lblstok_aciklama.Caption := TUrtReceteHammadde(Table).StokAdi.AsString;
  edtmiktar.Text := TUrtReceteHammadde(Table).Miktar.AsString;
  lblmiktar_birim.Caption := TUrtReceteHammadde(Table).OlcuBirimi.AsString;
  edtfire_orani.Text := TUrtReceteHammadde(Table).FireOrani.AsString;
  cbbreceteChange(cbbrecete);
end;

procedure TfrmRctPaketHammaddeDetay.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TUrtReceteHammadde(Table).StokKodu.Value := edtstok_kodu.Text;
      TUrtReceteHammadde(Table).StokAdi.Value := lblstok_aciklama.Caption;
      TUrtReceteHammadde(Table).Miktar.Value := StrToFloatDef(edtMiktar.Text, 0);
      TUrtReceteHammadde(Table).OlcuBirimi.Value := lblmiktar_birim.Caption;
      TUrtReceteHammadde(Table).FireOrani.Value := StrToFloatDef(edtfire_orani.Text, 0);
      if cbbrecete.ItemIndex > -1 then
        if Assigned(cbbrecete.Items.Objects[cbbrecete.ItemIndex]) then
          TUrtReceteHammadde(Table).ReceteID.Value := TUrtRecete(cbbrecete.Items.Objects[cbbrecete.ItemIndex]).Id.Value;

      if (FormMode = ifmUpdate) then
      begin
        TUrtRecete(TfrmRctReceteDetaylar(ParentForm).Table).UpdateDetay(Table);
        TfrmRctReceteDetaylar(ParentForm).UpdateDetay(Table, Grid);
      end
      else if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
      begin
        TUrtRecete(TfrmRctReceteDetaylar(ParentForm).Table).AddDetay( TUrtReceteHammadde(TUrtReceteHammadde(Table).Clone) );
        TfrmRctReceteDetaylar(ParentForm).AddDetay(Table, Grid);
      end;
      Close;
    end;
  end
  else
    inherited;
end;

end.
