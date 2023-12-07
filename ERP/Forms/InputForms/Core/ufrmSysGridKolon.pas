unit ufrmSysGridKolon;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB, Ths.Database.Table,
  Ths.Database.Table.View.SysViewTables, Ths.Database.Table.SysGridKolonlar;

type
  TfrmSysGridKolon = class(TfrmBaseInputDB)
    lbltablo_adi: TLabel;
    lblkolon_adi: TLabel;
    lblkolon_genislik: TLabel;
    lblsira_no: TLabel;
    lblis_gorunur: TLabel;
    lblis_helper_gorunur: TLabel;
    lblmax_renk: TLabel;
    lblmax_deger: TLabel;
    lblmin_renk: TLabel;
    lblmin_deger: TLabel;
    imgexample_bar: TImage;
    lblbar_rengi: TLabel;
    lblbar_arka_rengi: TLabel;
    lblbar_yazi_rengi: TLabel;
    lblmaks_deger_yuzdesi: TLabel;
    lblveri_formati: TLabel;
    cbbtablo_adi: TComboBox;
    cbbkolon_adi: TComboBox;
    edtsira_no: TEdit;
    edtkolon_genislik: TEdit;
    edtveri_formati: TEdit;
    chkis_gorunur: TCheckBox;
    chkis_helper_gorunur: TCheckBox;
    edtmin_deger: TEdit;
    edtmin_renk: TEdit;
    edtmax_deger: TEdit;
    edtmax_renk: TEdit;
    edtmaks_deger_yuzdesi: TEdit;
    edtbar_rengi: TEdit;
    edtbar_arka_rengi: TEdit;
    edtbar_yazi_rengi: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData(); override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure cbbtablo_adiChange(Sender: TObject);
    procedure edtmax_renkDblClick(Sender: TObject);
    procedure edtbar_rengiDblClick(Sender: TObject);
    procedure edtbar_arka_rengiDblClick(Sender: TObject);
    procedure edtbar_yazi_rengiDblClick(Sender: TObject);
    procedure edtmin_renkDblClick(Sender: TObject);
  private
    FSysViewTables: TSysViewTables;

    procedure FillColNameForColWidth(AComboBox: TComboBox; ATableName: string);
    procedure SetColor(color: TColor; editColor: TEdit);
    procedure DrawBar;
  public
    destructor Destroy; override;
    procedure Repaint; override;
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  published
  end;

implementation

uses
  Ths.Globals, Ths.Constants;

{$R *.dfm}

procedure TfrmSysGridKolon.FillColNameForColWidth(AComboBox: TComboBox; ATableName: string);
begin
  AComboBox.Clear;
  AComboBox.Items.Text := TSysGridKolon(Table).GetDistinctColumnNames(ATableName).Text;
end;

procedure TfrmSysGridKolon.cbbtablo_adiChange(Sender: TObject);
begin
  FillColNameForColWidth(TComboBox(cbbkolon_adi), ReplaceRealColOrTableNameTo(cbbtablo_adi.Text));
end;

destructor TfrmSysGridKolon.Destroy;
begin
  if Assigned(FSysViewTables) then
    FSysViewTables.Free;
  inherited;
end;

procedure TfrmSysGridKolon.DrawBar;
var
  x1, x2, y1, y2, vVal: Integer;
  rect: TRect;
  vTemp: string;
begin
  vTemp := 'Example %40';
  if (TryStrToInt(edtbar_rengi.Text, vVal)) and (TryStrToInt(edtbar_arka_rengi.Text, vVal)) and (TryStrToInt(edtbar_yazi_rengi.Text, vVal))
  //and (TryStrToInt(edtrecolor_bar_text_active.Text, vVal))
    then
  begin
    with imgexample_bar do
    begin
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Width := 1;

      Canvas.Pen.Color := StringToColor(edtbar_arka_rengi.Text);
      Canvas.Brush.Color := StringToColor(edtbar_arka_rengi.Text);
      x1 := 0;
      x2 := Width;
      y1 := 0;
      y2 := Height;
      Canvas.Rectangle(x1, y1, x2, y2);

      Canvas.Pen.Color := StringToColor(edtbar_rengi.Text);
      Canvas.Brush.Color := StringToColor(edtbar_rengi.Text);
      x1 := 1;
      x2 := trunc(Width * 0.40);
      y1 := 1;
      y2 := Height;
      Canvas.Rectangle(x1, y1, x2, y2);

      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := StringToColor(edtbar_yazi_rengi.Text);
      rect.Left := (imgexample_bar.Width - Canvas.TextWidth(vTemp)) div 2;
      rect.Right := rect.Left + Canvas.TextWidth(vTemp);
      rect.Top := (imgexample_bar.Height - Canvas.TextHeight(vTemp)) div 2;
      rect.Bottom := rect.Top + Canvas.TextHeight(vTemp);
      Canvas.TextRect(rect, vTemp);

      Repaint;
    end;
  end;
end;

procedure TfrmSysGridKolon.edtbar_rengiDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtbar_rengi.Text, 0)), edtbar_rengi);
end;

procedure TfrmSysGridKolon.edtbar_arka_rengiDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtbar_arka_rengi.Text, 0)), edtbar_arka_rengi);
end;

procedure TfrmSysGridKolon.edtbar_yazi_rengiDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtbar_yazi_rengi.Text, 0)), edtbar_yazi_rengi);
end;

procedure TfrmSysGridKolon.edtmax_renkDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtmax_renk.Text, 0)), edtmax_renk);
end;

procedure TfrmSysGridKolon.edtmin_renkDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtmin_renk.Text, 0)), edtmin_renk);
end;

procedure TfrmSysGridKolon.FormCreate(Sender: TObject);
begin
  inherited;

  cbbtablo_adi.CharCase := ecNormal;
  cbbkolon_adi.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(Table.Database);

  fillComboBoxData(cbbtablo_adi, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
  cbbtablo_adiChange(cbbtablo_adi);
end;

procedure TfrmSysGridKolon.RefreshData();
begin
  //control içeriðini table class ile doldur
  cbbtablo_adi.ItemIndex := cbbtablo_adi.Items.IndexOf(TSysGridKolon(Table).TabloAdi.AsString);
  cbbtablo_adiChange(cbbtablo_adi);
  if cbbkolon_adi.Items.IndexOf(TSysGridKolon(Table).KolonAdi.AsString) = -1 then
    cbbkolon_adi.Items.Add(TSysGridKolon(Table).KolonAdi.AsString);
  cbbkolon_adi.ItemIndex := cbbkolon_adi.Items.IndexOf(TSysGridKolon(Table).KolonAdi.AsString);
  edtsira_no.Text := TSysGridKolon(Table).SiraNo.AsString;
  edtkolon_genislik.Text := TSysGridKolon(Table).KolonGenislik.AsString;
  edtveri_formati.Text := TSysGridKolon(Table).VeriFormati.AsString;
  chkis_gorunur.Checked := TSysGridKolon(Table).IsGorunur.AsBoolean;
  chkis_helper_gorunur.Checked := TSysGridKolon(Table).IsHelperGorunur.AsBoolean;

  edtmin_deger.Text := TSysGridKolon(Table).MinDeger.AsString;
  SetColor(StrToIntDef(edtmin_renk.Text, 0), edtmin_renk);
  edtmax_deger.Text := TSysGridKolon(Table).MaxDeger.AsString;
  SetColor(StrToIntDef(edtmax_renk.Text, 0), edtmax_renk);
  edtmaks_deger_yuzdesi.Text := TSysGridKolon(Table).MaxDegerYuzdesi.AsString;

  SetColor(StrToIntDef(edtbar_rengi.Text, 0), edtbar_rengi);
  SetColor(StrToIntDef(edtbar_arka_rengi.Text, 0), edtbar_arka_rengi);
  SetColor(StrToIntDef(edtbar_yazi_rengi.Text, 0), edtbar_yazi_rengi);
  DrawBar;
end;

procedure TfrmSysGridKolon.Repaint;
begin
  inherited;
  edtmin_renk.ReadOnly := True;
  edtmax_renk.ReadOnly := True;

  edtbar_rengi.ReadOnly := True;
  edtbar_arka_rengi.ReadOnly := True;
  edtbar_yazi_rengi.ReadOnly := True;
  //edtcolor_bar_text_active.ReadOnly := True;
end;

procedure TfrmSysGridKolon.SetColor(color: TColor; editColor: TEdit);
begin
  editColor.Text := IntToStr(color);
  editColor.Color := color;
  editColor.thsColorActive := color;
  editColor.thsColorRequiredInput := color;
  editColor.Repaint;
  //draw gerekiyorsa drawa gidecek
  DrawBar;
end;

function TfrmSysGridKolon.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput();

  //arada rakam atlyacak þekilde giriþ yapýlmýþsa rakamý otomatik olarak düzelt.
  //maks sequence no dan sonraki rakam gelmek zorunda.
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    if StrToInt(edtsira_no.Text) > TSysGridKolon(Table).GetMaxSequenceNo(cbbtablo_adi.Text) + 1 then
      edtsira_no.Text := IntToStr(TSysGridKolon(Table).GetMaxSequenceNo(cbbtablo_adi.Text) + 1)
  end
  else if (FormMode = ifmUpdate) then
  begin
    if StrToInt(edtsira_no.Text) > TSysGridKolon(Table).GetMaxSequenceNo(TSysGridKolon(Table).TabloAdi.Value) then
      edtsira_no.Text := IntToStr(TSysGridKolon(Table).GetMaxSequenceNo(TSysGridKolon(Table).TabloAdi.Value));
  end;
end;

procedure TfrmSysGridKolon.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if cbbtablo_adi.Items.IndexOf(cbbtablo_adi.Text) = -1 then
        raise Exception.Create('Listede olmayan bir Tablo Adý giremezsiniz!' + AddLBs() + cbbtablo_adi.Text);

      if (FormMode = ifmUpdate) then
      begin
        if TSysGridKolon(Table).SiraNo.Value = StrToInt(edtsira_no.Text) then
          TSysGridKolon(Table).FSeqStatus := ssNone
        else if TSysGridKolon(Table).SiraNo.Value > StrToInt(edtsira_no.Text) then
          TSysGridKolon(Table).FSeqStatus := ssAzalma
        else if TSysGridKolon(Table).SiraNo.Value < StrToInt(edtsira_no.Text) then
          TSysGridKolon(Table).FSeqStatus := ssArtis;

        TSysGridKolon(Table).FOldValue := TSysGridKolon(Table).SiraNo.Value;
      end;

      TSysGridKolon(Table).TabloAdi.Value := cbbtablo_adi.Text;
      TSysGridKolon(Table).KolonAdi.Value := cbbkolon_adi.Text;
      TSysGridKolon(Table).SiraNo.Value := edtsira_no.Text;
      TSysGridKolon(Table).KolonGenislik.Value := edtkolon_genislik.Text;
      TSysGridKolon(Table).VeriFormati.Value := edtveri_formati.Text;
      TSysGridKolon(Table).IsGorunur.Value := chkis_gorunur.Checked;
      TSysGridKolon(Table).IsHelperGorunur.Value := chkis_helper_gorunur.Checked;

      TSysGridKolon(Table).MinDeger.Value := StrToFloatDef(edtmin_deger.Text, 0);
      TSysGridKolon(Table).MinRenk.Value := StrToIntDef(edtmin_renk.Text, 0);
      TSysGridKolon(Table).MaxDeger.Value := StrToFloatDef(edtmax_deger.Text, 0);
      TSysGridKolon(Table).MaxRenk.Value := StrToIntDef(edtmax_renk.Text, 0);
      TSysGridKolon(Table).MaxDegerYuzdesi.Value := StrToFloatDef(edtmaks_deger_yuzdesi.Text, 0);
      TSysGridKolon(Table).BarRengi.Value := StrToIntDef(edtbar_rengi.Text, 0);
      TSysGridKolon(Table).BarArkaRengi.Value := StrToIntDef(edtbar_arka_rengi.Text, 0);
      TSysGridKolon(Table).BarYaziRengi.Value := StrToIntDef(edtbar_yazi_rengi.Text, 0);

      inherited;
    end;
  end
  else
    inherited;
end;

end.

