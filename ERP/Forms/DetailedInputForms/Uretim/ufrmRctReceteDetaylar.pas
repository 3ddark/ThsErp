﻿unit ufrmRctReceteDetaylar;

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
  System.Actions,
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
  Vcl.Grids,
  Vcl.ActnList,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  Ths.Helper.StringGrid,
  ufrmBase,
  ufrmBaseDetaylar,
  Ths.Database.Table,
  Ths.Database.Table.UrtReceteler;

const
  RH_MAL_KODU = 1;
  RH_MAL_ADI = 2;
  RH_MIKTAR = 3;
  RH_BIRIM = 4;
  RH_FIYAT = 5;
  RH_FIRE_ORANI = 6;

  RI_GIDER_KODU = 1;
  RI_GIDER_ADI = 2;
  RI_MIKTAR = 3;
  RI_BIRIM = 4;
  RI_FIYAT = 5;

  RY_MAL_KODU = 1;
  RY_MAL_ADI = 2;
  RY_MIKTAR = 3;
  RY_BIRIM = 4;
  RY_FIYAT = 5;
  RY_FIRE_ORANI = 6;

type
  TfrmRctReceteDetaylar = class(TfrmBaseDetaylar)
    lblurun_kodu: TLabel;
    lblurun_adi: TLabel;
    lblornek_uretm_miktari: TLabel;
    lblaciklama: TLabel;
    edtrecete_kodu: TEdit;
    edtrecete_adi: TEdit;
    edtornek_uretm_miktari: TEdit;
    edtaciklama: TEdit;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure cbbpara_birimiChange(Sender: TObject);
    procedure pgcContentChange(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState); override;
  private
    procedure FillLabels();
  public
    procedure RefreshData; override;
    function CreateDetailInputForm1(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm; override;
    function CreateDetailInputForm2(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm; override;
    function CreateDetailInputForm3(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm; override;
    procedure GridReset(); override;
    procedure GridFill(); override;
    procedure Repaint; override;
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure HelperProcess(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  ufrmRctReceteHammadde,
  ufrmRctReceteIscilik,
  ufrmRctReceteYanUrun,
  ufrmStkKartlar,
  Ths.Database.Table.StkKartlar;

{$R *.dfm}

procedure TfrmRctReceteDetaylar.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TUrtRecete(Table).UrunKodu.Value := edtrecete_kodu.Text;
      TUrtRecete(Table).UrunAdi.Value := edtrecete_adi.Text;
      TUrtRecete(Table).OrnekMiktari.Value := edtornek_uretm_miktari.Text;
      TUrtRecete(Table).Aciklama.Value := edtaciklama.Text;

      inherited;
    end;
  end
  else
  begin
    inherited;
    if pgcContent.ActivePage.Name = ts1.Name then
      strngrd1.SetFocus
    else if pgcContent.ActivePage.Name = ts2.Name then
      strngrd2.SetFocus
    else if pgcContent.ActivePage.Name = ts3.Name then
      strngrd3.SetFocus;
  end;
end;

procedure TfrmRctReceteDetaylar.cbbpara_birimiChange(Sender: TObject);
begin
  GridFill();
end;

function TfrmRctReceteDetaylar.CreateDetailInputForm1(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := inherited;
  if (AFormMode = ifmNewRecord) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmRctReceteHammadde.Create(Application, AGrid, Self, TUrtReceteHammadde.Create(Table.Database), AFormMode)
  else if (AFormMode = ifmRewiev) or (AFormMode = ifmUpdate) then
  begin
    if Assigned(AGrid.Objects[COLUMN_GRID_OBJECT, AGrid.Row]) then
      Result := TfrmRctReceteHammadde.Create(Application, AGrid, Self, TUrtReceteHammadde(AGrid.Objects[COLUMN_GRID_OBJECT, strngrd1.Row]), AFormMode);
  end;
end;

function TfrmRctReceteDetaylar.CreateDetailInputForm2(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := inherited;
  if (AFormMode = ifmNewRecord) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmRctReceteIscilik.Create(Application, AGrid, Self, TUrtReceteIscilik.Create(Table.Database), AFormMode)
  else if (AFormMode = ifmRewiev) or (AFormMode = ifmUpdate) then
  begin
    if Assigned(AGrid.Objects[COLUMN_GRID_OBJECT, AGrid.Row]) then
      Result := TfrmRctReceteIscilik.Create(Application, AGrid, Self, TUrtReceteIscilik(AGrid.Objects[COLUMN_GRID_OBJECT, strngrd2.Row]), AFormMode);
  end;
end;

function TfrmRctReceteDetaylar.CreateDetailInputForm3(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := inherited;
  if (AFormMode = ifmNewRecord) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmRctReceteYanUrun.Create(Application, AGrid, Self, TUrtReceteYanUrun.Create(Table.Database), AFormMode)
  else if (AFormMode = ifmRewiev) or (AFormMode = ifmUpdate) then
  begin
    if Assigned(AGrid.Objects[COLUMN_GRID_OBJECT, AGrid.Row]) then
      Result := TfrmRctReceteYanUrun.Create(Application, AGrid, Self, TUrtReceteYanUrun(AGrid.Objects[COLUMN_GRID_OBJECT, strngrd2.Row]), AFormMode);
  end;
end;

procedure TfrmRctReceteDetaylar.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  //
end;

procedure TfrmRctReceteDetaylar.GridFill();
var
  n1: Integer;
  LFirstHam: Boolean;
  LFirstIsc: Boolean;
  LFirstYan: Boolean;
begin
  strngrd1.Perform(WM_SETREDRAW, 0, 0);
  strngrd2.Perform(WM_SETREDRAW, 0, 0);
  strngrd3.Perform(WM_SETREDRAW, 0, 0);
  try
    GridReset();


    if TUrtRecete(Table).ReceteMaliyet.HammaddeCount > 0 then
      strngrd1.RowCount := TUrtRecete(Table).ReceteMaliyet.HammaddeCount + strngrd1.FixedRows;
    strngrd1.ColStyleDouble(RH_MIKTAR);
    strngrd1.ColStyleMoney(RH_FIYAT);

    if TUrtRecete(Table).ReceteMaliyet.IscilikCount > 0 then
      strngrd2.RowCount := TUrtRecete(Table).ReceteMaliyet.IscilikCount + strngrd2.FixedRows;
    strngrd2.ColStyleDouble(RI_MIKTAR);
    strngrd2.ColStyleMoney(RI_FIYAT);

    if TUrtRecete(Table).ReceteMaliyet.YanUrunCount > 0 then
      strngrd3.RowCount := TUrtRecete(Table).ReceteMaliyet.YanUrunCount + strngrd3.FixedRows;
    strngrd3.ColStyleDouble(RY_MIKTAR);
    strngrd3.ColStyleMoney(RY_FIYAT);

    LFirstHam := False;
    LFirstIsc := False;
    LFirstYan := False;
    for n1 := 0 to TUrtRecete(Table).ListDetay.Count-1 do
    begin
      if TObject(TUrtRecete(Table).ListDetay[n1]).ClassType = TUrtReceteHammadde then
      begin
        if LFirstHam then
          strngrd1.Row := strngrd1.Row + 1;
        LFirstHam := True;

        strngrd1.Objects[COLUMN_GRID_OBJECT, strngrd1.Row] := TUrtReceteHammadde(TUrtRecete(Table).ListDetay[n1]);

        strngrd1.Cells[RH_MAL_KODU, strngrd1.Row] := TUrtReceteHammadde(TUrtRecete(Table).ListDetay[n1]).StokKodu.AsString;
        strngrd1.Cells[RH_MAL_ADI, strngrd1.Row] := TUrtReceteHammadde(TUrtRecete(Table).ListDetay[n1]).StokAdi.AsString;
        strngrd1.Cells[RH_MIKTAR, strngrd1.Row] := TUrtReceteHammadde(TUrtRecete(Table).ListDetay[n1]).Miktar.AsString;
        strngrd1.Cells[RH_BIRIM, strngrd1.Row] := TUrtReceteHammadde(TUrtRecete(Table).ListDetay[n1]).OlcuBirimi.AsString;
        strngrd1.Cells[RH_FIRE_ORANI, strngrd1.Row] := TUrtReceteHammadde(TUrtRecete(Table).ListDetay[n1]).FireOrani.AsString;
        strngrd1.Cells[RH_FIYAT, strngrd1.Row] := TUrtReceteHammadde(TUrtRecete(Table).ListDetay[n1]).Fiyat.AsString;
      end
      else if TObject(TUrtRecete(Table).ListDetay[n1]).ClassType = TUrtReceteIscilik then
      begin
        if LFirstIsc then
          strngrd2.Row := strngrd2.Row + 1;
        LFirstIsc := True;

        strngrd2.Objects[COLUMN_GRID_OBJECT, strngrd2.Row] := TUrtReceteIscilik(TUrtRecete(Table).ListDetay[n1]);

        strngrd2.Cells[RI_GIDER_KODU, strngrd2.Row] := TUrtReceteIscilik(TUrtRecete(Table).ListDetay[n1]).IscilikKodu.AsString;
        //strngrd2.Cells[RI_GIDER_ADI, strngrd2.Row] := TUrtReceteIscilik(TUrtRecete(Table).ListDetay[n1]).GiderAdi.AsString;
        strngrd2.Cells[RI_MIKTAR, strngrd2.Row] := TUrtReceteIscilik(TUrtRecete(Table).ListDetay[n1]).Miktar.AsString;
        strngrd2.Cells[RI_BIRIM, strngrd2.Row] := TUrtReceteIscilik(TUrtRecete(Table).ListDetay[n1]).Birim.AsString;
        strngrd2.Cells[RI_FIYAT, strngrd2.Row] := TUrtReceteIscilik(TUrtRecete(Table).ListDetay[n1]).Fiyat.AsString;
      end
      else if TObject(TUrtRecete(Table).ListDetay[n1]).ClassType = TUrtReceteYanUrun then
      begin
        if LFirstYan then
          strngrd3.Row := strngrd3.Row + 1;
        LFirstYan := True;

        strngrd3.Objects[COLUMN_GRID_OBJECT, strngrd3.Row] := TUrtReceteYanUrun(TUrtRecete(Table).ListDetay[n1]);

        strngrd3.Cells[RY_MAL_KODU, strngrd3.Row] := TUrtReceteYanUrun(TUrtRecete(Table).ListDetay[n1]).UrunKodu.AsString;
        strngrd3.Cells[RY_MAL_ADI, strngrd3.Row] := TUrtReceteYanUrun(TUrtRecete(Table).ListDetay[n1]).StokAdi.AsString;
        strngrd3.Cells[RY_MIKTAR, strngrd3.Row] := TUrtReceteYanUrun(TUrtRecete(Table).ListDetay[n1]).Miktar.AsString;
        strngrd3.Cells[RY_BIRIM, strngrd3.Row] := TUrtReceteYanUrun(TUrtRecete(Table).ListDetay[n1]).OlcuBirimi.AsString;
        strngrd3.Cells[RY_FIYAT, strngrd3.Row] := TUrtReceteYanUrun(TUrtRecete(Table).ListDetay[n1]).Fiyat.AsString;
        strngrd3.Cells[RY_FIRE_ORANI, strngrd3.Row] := '';
      end
    end;

    FillLabels;
  finally
    strngrd1.Perform(WM_SETREDRAW, 1, 0);
    strngrd1.Invalidate;
    strngrd2.Perform(WM_SETREDRAW, 1, 0);
    strngrd2.Invalidate;
    strngrd3.Perform(WM_SETREDRAW, 1, 0);
    strngrd3.Invalidate;

    strngrd1.Row := 1;
    strngrd1.Col := 1;
    strngrd2.Row := 1;
    strngrd2.Col := 1;
    strngrd3.Row := 1;
    strngrd3.Col := 1;
  end;
end;

procedure TfrmRctReceteDetaylar.FillLabels;
var
  LFmt: TFormatSettings;
begin
  LFmt := FormatSettings;
  lblValToplamTutar.Caption := FloatToStrF(TUrtRecete(Table).ReceteMaliyet.MaliyetHam, ffCurrency, 10, GSysOndalikHane.Fiyat.Value, LFmt);
  lblValToplamIskontoTutar.Caption := FloatToStrF(TUrtRecete(Table).ReceteMaliyet.MaliyetIsc, ffCurrency, 10, GSysOndalikHane.Fiyat.Value, LFmt);
  lblValAraToplam.Caption := FloatToStrF(TUrtRecete(Table).ReceteMaliyet.MaliyetYan, ffCurrency, 10, GSysOndalikHane.Fiyat.Value, LFmt);
  lblValToplamKDVTutar.Caption := FloatToStrF(TUrtRecete(Table).ReceteMaliyet.MaliyetHam + TUrtRecete(Table).ReceteMaliyet.MaliyetIsc - TUrtRecete(Table).ReceteMaliyet.MaliyetYan, ffCurrency, 10, GSysOndalikHane.Fiyat.Value, LFmt);
end;

procedure TfrmRctReceteDetaylar.FormCreate(Sender: TObject);
begin
  inherited;

  ts2.TabVisible := True;
  ts3.TabVisible := True;
  ts1.Caption := 'Hammadde';
  ts2.Caption := 'İşçilik';
  ts3.Caption := 'Yan Ürün';

  edtrecete_kodu.OnHelperProcess := HelperProcess;
end;

procedure TfrmRctReceteDetaylar.FormDestroy(Sender: TObject);
begin
  //
  inherited;
end;

procedure TfrmRctReceteDetaylar.FormShow(Sender: TObject);
begin
  inherited;

  splHeader.Visible := False;
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    edtornek_uretm_miktari.Text := '1';
  end
  else
    btnHeaderShowHide.Click;

  grpGenelToplam.Visible := True;

  lblToplamTutar.Visible := True;
  lblToplamIskontoTutar.Visible := True;
  lblAraToplam.Visible := True;
  lblToplamKDVTutar.Visible := True;
  lblValToplamTutar.Visible := True;
  lblValToplamIskontoTutar.Visible := True;
  lblValAraToplam.Visible := True;
  lblValToplamKDVTutar.Visible := True;

  lblToplamTutar.Caption := 'Hammadde Tutar';
  lblToplamIskontoTutar.Caption := 'İşçilik Tutar';
  lblAraToplam.Caption := 'Yan Ürün Tutar';
  lblToplamKDVTutar.Caption := 'Toplam Maliyet';

  if (FormMode = ifmNewRecord) then
    FillLabels;
end;

procedure TfrmRctReceteDetaylar.GridReset();
begin
  inherited;

  strngrd1.RowCount := 2;
  strngrd1.ColCount := 7;
  strngrd1.Rows[0].Text := '';
  strngrd1.Rows[1].Text := '';

  GridColWidth(strngrd1, 120, RH_MAL_KODU);
  GridColWidth(strngrd1, 300, RH_MAL_ADI);
  GridColWidth(strngrd1, 60, RH_MIKTAR);
  GridColWidth(strngrd1, 60, RH_BIRIM);
  GridColWidth(strngrd1, 90, RH_FIYAT);
  GridColWidth(strngrd1, 60, RH_FIRE_ORANI);

  strngrd1.Cells[RH_MAL_KODU, 0] := 'STOK KODU';
  strngrd1.Cells[RH_MAL_ADI, 0] := 'AÇIKLAMA';
  strngrd1.Cells[RH_MIKTAR, 0] := 'MİKTAR';
  strngrd1.Cells[RH_BIRIM, 0] := 'BİRİM';
  strngrd1.Cells[RH_FIYAT, 0] := 'FİYAT';
  strngrd1.Cells[RH_FIRE_ORANI, 0] := 'FİRE';



  strngrd2.RowCount := 2;
  strngrd2.ColCount := 6;
  strngrd2.Rows[0].Text := '';
  strngrd2.Rows[1].Text := '';

  GridColWidth(strngrd2, 100, RI_GIDER_KODU);
  GridColWidth(strngrd2, 300, RI_GIDER_ADI);
  GridColWidth(strngrd2, 50, RI_MIKTAR);
  GridColWidth(strngrd2, 40, RI_BIRIM);
  GridColWidth(strngrd2, 70, RI_FIYAT);

  strngrd2.Cells[RI_GIDER_KODU, 0] := 'GİDER KODU';
  strngrd2.Cells[RI_GIDER_ADI, 0] := 'AÇIKLAMA';
  strngrd2.Cells[RI_MIKTAR, 0] := 'MİKTAR';
  strngrd2.Cells[RI_BIRIM, 0] := 'BİRİM';
  strngrd2.Cells[RI_FIYAT, 0] := 'FİYAT';



  strngrd3.RowCount := 2;
  strngrd3.ColCount := 7;
  strngrd3.Rows[0].Text := '';
  strngrd3.Rows[1].Text := '';

  GridColWidth(strngrd3, 120, RY_MAL_KODU);
  GridColWidth(strngrd3, 300, RY_MAL_ADI);
  GridColWidth(strngrd3, 60, RY_MIKTAR);
  GridColWidth(strngrd3, 60, RY_BIRIM);
  GridColWidth(strngrd3, 90, RY_FIYAT);
  GridColWidth(strngrd3, 60, RY_FIRE_ORANI);

  strngrd3.Cells[RY_MAL_KODU, 0] := 'STOK KODU';
  strngrd3.Cells[RY_MAL_ADI, 0] := 'AÇIKLAMA';
  strngrd3.Cells[RY_MIKTAR, 0] := 'MİKTAR';
  strngrd3.Cells[RY_BIRIM, 0] := 'BİRİM';
  strngrd3.Cells[RY_FIYAT, 0] := 'FİYAT';
  strngrd3.Cells[RY_FIRE_ORANI, 0] := 'FİRE';
end;

procedure TfrmRctReceteDetaylar.RefreshData;
begin
  edtrecete_kodu.Text := TUrtRecete(Table).UrunKodu.Value;
  edtrecete_adi.Text := TUrtRecete(Table).UrunAdi.Value;
  edtornek_uretm_miktari.Text := TUrtRecete(Table).OrnekMiktari.Value;
  edtaciklama.Text := TUrtRecete(Table).Aciklama.Value;

  GridFill();
end;

procedure TfrmRctReceteDetaylar.Repaint;
begin
  inherited;
  edtrecete_kodu.ReadOnly := True;
end;

procedure TfrmRctReceteDetaylar.HelperProcess(Sender: TObject);
var
  LFrmStokKarti: TfrmStkKartlar;
  LStokKarti: TStkKart;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtrecete_kodu.Name then
      begin
        LStokKarti := TStkKart.Create(Table.Database);
        LFrmStokKarti := TfrmStkKartlar.Create(TEdit(Sender), Self, LStokKarti, fomNormal, True);
        LFrmStokKarti.QryFiltreVarsayilanKullanici := ' AND (' + LStokKarti.UrunTipi.FieldName + '=' + Ord(TStkUrunTipi.sutMamul).ToString + ' OR ' +
                                                                 LStokKarti.UrunTipi.FieldName + '=' + Ord(TStkUrunTipi.sutYariMamul).ToString + ')';
        try
          LFrmStokKarti.ShowModal;

          TEdit(Sender).Text := TStkKart(LFrmStokKarti.Table).StokKodu.Value;
          edtrecete_adi.Text := TStkKart(LFrmStokKarti.Table).StokAdi.Value;
        finally
          LFrmStokKarti.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmRctReceteDetaylar.pgcContentChange(Sender: TObject);
begin
  inherited;
  if pgcContent.ActivePage.Name = ts1.Name then
  begin
    grpGenelToplam.Parent := pnl1;
    strngrd2.DrawFixedRowNumbers;
  end
  else if pgcContent.ActivePage.Name = ts2.Name then
  begin
    grpGenelToplam.Parent := pnl2;
    strngrd2.DrawFixedRowNumbers;
  end
  else if pgcContent.ActivePage.Name = ts3.Name then
  begin
    grpGenelToplam.Parent := pnl3;
    strngrd3.DrawFixedRowNumbers;
  end
end;

end.
