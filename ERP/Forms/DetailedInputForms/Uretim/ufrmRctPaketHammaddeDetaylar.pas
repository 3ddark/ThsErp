unit ufrmRctPaketHammaddeDetaylar;

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
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,
  Ths.Helper.StringGrid,
  ufrmBase,
  ufrmBaseDetaylar,
  Ths.Database.Table,
  Ths.Database.Table.UrtPaketHammaddeler;

const
  PH_MAL_KODU = 1;
  PH_MAL_ADI = 2;
  PH_MIKTAR = 3;
  PH_BIRIM = 4;
  PH_FIYAT = 5;
  PH_FIRE_ORANI = 6;

type
  TfrmRctPaketHammaddeDetaylar = class(TfrmBaseDetaylar)
    lblpaket_adi: TLabel;
    edtpaket_adi: TEdit;
  public
    procedure RefreshData; override;
    function CreateDetailInputForm1(pFormMode: TInputFormMode; AGrid: TStringGrid): TForm; override;
    procedure GridReset(); override;
    procedure GridFill(); override;
    procedure Repaint; override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  ufrmRctPaketHammaddeDetay;

{$R *.dfm}

procedure TfrmRctPaketHammaddeDetaylar.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TUrtPaketHammadde(Table).PaketAdi.Value := edtpaket_adi.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

function TfrmRctPaketHammaddeDetaylar.CreateDetailInputForm1(pFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := inherited;
  if (pFormMode = ifmNewRecord) or (pFormMode = ifmCopyNewRecord) then
    Result := TfrmRctPaketHammaddeDetay.Create(Application, AGrid, Self, TUrtPaketHammaddeDetay.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmRewiev) or (pFormMode = ifmUpdate) then
  begin
    if Assigned(AGrid.Objects[COLUMN_GRID_OBJECT, AGrid.Row]) then
      Result := TfrmRctPaketHammaddeDetay.Create(Application, AGrid, Self, TUrtPaketHammaddeDetay(AGrid.Objects[COLUMN_GRID_OBJECT, strngrd1.Row]), pFormMode);
  end;
end;

procedure TfrmRctPaketHammaddeDetaylar.GridFill();
var
  n1: Integer;
  LFirstHam: Boolean;
begin
  strngrd1.Perform(WM_SETREDRAW, 0, 0);
  try
    GridReset();

    strngrd1.RowCount := strngrd1.FixedRows;
    strngrd1.ColStyleDouble(PH_MIKTAR);
    strngrd1.ColStyleMoney(PH_FIYAT);

    LFirstHam := False;
    for n1 := 0 to TUrtPaketHammadde(Table).ListDetay.Count-1 do
    begin
      if LFirstHam then
        strngrd1.Row := strngrd1.Row + 1;
      LFirstHam := True;

      strngrd1.Objects[COLUMN_GRID_OBJECT, strngrd1.Row] := TUrtPaketHammaddeDetay(TUrtPaketHammadde(Table).ListDetay[n1]);

      strngrd1.Cells[PH_MAL_KODU, strngrd1.Row] := TUrtPaketHammaddeDetay(TUrtPaketHammadde(Table).ListDetay[n1]).StokKodu.Value;
      strngrd1.Cells[PH_MAL_ADI, strngrd1.Row] := TUrtPaketHammaddeDetay(TUrtPaketHammadde(Table).ListDetay[n1]).StokAdi.Value;
      strngrd1.Cells[PH_MIKTAR, strngrd1.Row] := TUrtPaketHammaddeDetay(TUrtPaketHammadde(Table).ListDetay[n1]).Miktar.Value;
      strngrd1.Cells[PH_BIRIM, strngrd1.Row] := TUrtPaketHammaddeDetay(TUrtPaketHammadde(Table).ListDetay[n1]).OlcuBirimi.Value;
      strngrd1.Cells[PH_FIRE_ORANI, strngrd1.Row] := TUrtPaketHammaddeDetay(TUrtPaketHammadde(Table).ListDetay[n1]).FireOrani.Value;
      strngrd1.Cells[PH_FIYAT, strngrd1.Row] := TUrtPaketHammaddeDetay(TUrtPaketHammadde(Table).ListDetay[n1]).Fiyat.Value;
    end;

  finally
    strngrd1.Perform(WM_SETREDRAW, 1, 0);
    strngrd1.Invalidate;

    strngrd1.Row := 1;
    strngrd1.Col := 1;
  end;
end;

procedure TfrmRctPaketHammaddeDetaylar.FormCreate(Sender: TObject);
begin
  inherited;

  ts1.Caption := 'Hammadde';
end;

procedure TfrmRctPaketHammaddeDetaylar.FormShow(Sender: TObject);
begin
  inherited;

  splHeader.Visible := False;
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin

  end
  else
    btnHeaderShowHide.Click;
end;

procedure TfrmRctPaketHammaddeDetaylar.GridReset();
begin
  inherited;

  strngrd1.RowCount := 2;
  strngrd1.ColCount := 7;
  strngrd1.Rows[0].Text := '';
  strngrd1.Rows[1].Text := '';

  GridColWidth(strngrd1, 120, PH_MAL_KODU);
  GridColWidth(strngrd1, 300, PH_MAL_ADI);
  GridColWidth(strngrd1, 60, PH_MIKTAR);
  GridColWidth(strngrd1, 60, PH_BIRIM);
  GridColWidth(strngrd1, 90, PH_FIYAT);
  GridColWidth(strngrd1, 60, PH_FIRE_ORANI);

  strngrd1.Cells[PH_MAL_KODU, 0] := 'STOK KODU';
  strngrd1.Cells[PH_MAL_ADI, 0] := 'AÇIKLAMA';
  strngrd1.Cells[PH_MIKTAR, 0] := 'MİKTAR';
  strngrd1.Cells[PH_BIRIM, 0] := 'BİRİM';
  strngrd1.Cells[PH_FIYAT, 0] := 'FİYAT';
  strngrd1.Cells[PH_FIRE_ORANI, 0] := 'FİRE';
end;

procedure TfrmRctPaketHammaddeDetaylar.RefreshData;
begin
  inherited;

  edtpaket_adi.Text := TUrtPaketHammadde(Table).PaketAdi.Value;

  GridFill();
end;

procedure TfrmRctPaketHammaddeDetaylar.Repaint;
begin
  inherited;
end;

end.
