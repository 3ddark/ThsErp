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
    lbltable_name: TLabel;
    lblcolumn_name: TLabel;
    lblcol_width: TLabel;
    lblseq_no: TLabel;
    lblis_show: TLabel;
    lblis_show_helper: TLabel;
    lblmax_color: TLabel;
    lblmax_value: TLabel;
    lblmin_color: TLabel;
    lblmin_value: TLabel;
    imgexample_bar: TImage;
    lblcolor_bar: TLabel;
    lblcolor_bar_back: TLabel;
    lblcolor_bar_text: TLabel;
    lblmax_value_percent: TLabel;
    lbldata_format: TLabel;
    cbbtable_name: TComboBox;
    cbbcolumn_name: TComboBox;
    edtseq_no: TEdit;
    edtcol_width: TEdit;
    edtdata_format: TEdit;
    chkis_show: TCheckBox;
    chkis_show_helper: TCheckBox;
    edtmin_value: TEdit;
    edtmin_color: TEdit;
    edtmax_value: TEdit;
    edtmax_color: TEdit;
    edtmax_value_percent: TEdit;
    edtcolor_bar: TEdit;
    edtcolor_bar_back: TEdit;
    edtcolor_bar_text: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure cbbtable_nameChange(Sender: TObject);
    procedure edtmax_colorDblClick(Sender: TObject);
    procedure edtcolor_barDblClick(Sender: TObject);
    procedure edtcolor_bar_backDblClick(Sender: TObject);
    procedure edtcolor_bar_textDblClick(Sender: TObject);
    procedure edtmin_colorDblClick(Sender: TObject);
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
  Ths.Globals,
  Ths.Constants;

{$R *.dfm}

procedure TfrmSysGridKolon.FillColNameForColWidth(AComboBox: TComboBox; ATableName: string);
begin
  AComboBox.Clear;
  AComboBox.Items.Text := TSysGridKolon(Table).GetDistinctColumnNames(ATableName).Text;
end;

procedure TfrmSysGridKolon.cbbtable_nameChange(Sender: TObject);
begin
  FillColNameForColWidth(TComboBox(cbbcolumn_name), ReplaceRealColOrTableNameTo(cbbtable_name.Text));
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
  if  (TryStrToInt(edtcolor_bar.Text, vVal))
  and (TryStrToInt(edtcolor_bar_back.Text, vVal))
  and (TryStrToInt(edtcolor_bar_text.Text, vVal))
  //and (TryStrToInt(edtrecolor_bar_text_active.Text, vVal))
  then
  begin
    with imgexample_bar do
    begin
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Width := 1;

      Canvas.Pen.Color := StringToColor(edtcolor_bar_back.Text);
      Canvas.Brush.Color := StringToColor(edtcolor_bar_back.Text);
      x1 := 0;  x2 := Width;  y1 := 0;  y2 := Height;
      Canvas.Rectangle( x1, y1, x2, y2 );

      Canvas.Pen.Color := StringToColor(edtcolor_bar.Text);
      Canvas.Brush.Color := StringToColor(edtcolor_bar.Text);
      x1 := 1;  x2 := trunc(Width*0.40);  y1 := 1;  y2 := Height;
      Canvas.Rectangle( x1, y1, x2, y2 );

      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := StringToColor( edtcolor_bar_text.Text );
      rect.Left := (imgexample_bar.Width - Canvas.TextWidth(vTemp)) div 2;
      rect.Right := rect.Left + Canvas.TextWidth(vTemp);
      rect.Top := (imgexample_bar.Height - Canvas.TextHeight(vTemp)) div 2;
      rect.Bottom := rect.Top + Canvas.TextHeight(vTemp);
      Canvas.TextRect(rect, vTemp);

      Repaint;
    end;
  end;
end;

procedure TfrmSysGridKolon.edtcolor_barDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtcolor_bar.Text, 0)), edtcolor_bar);
end;

procedure TfrmSysGridKolon.edtcolor_bar_backDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtcolor_bar_back.Text, 0)), edtcolor_bar_back);
end;

procedure TfrmSysGridKolon.edtcolor_bar_textDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtcolor_bar_text.Text, 0)), edtcolor_bar_text);
end;

procedure TfrmSysGridKolon.edtmax_colorDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtmax_color.Text, 0)), edtmax_color);
end;

procedure TfrmSysGridKolon.edtmin_colorDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtmin_color.Text, 0)), edtmin_color);
end;

procedure TfrmSysGridKolon.FormCreate(Sender: TObject);
begin
  inherited;

  cbbtable_name.CharCase := ecNormal;
  cbbcolumn_name.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(Table.Database);

  fillComboBoxData(cbbtable_name, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
  cbbtable_nameChange(cbbtable_name);
end;

procedure TfrmSysGridKolon.RefreshData();
begin
  //control içeriðini table class ile doldur
  cbbtable_name.ItemIndex := cbbtable_name.Items.IndexOf(TSysGridKolon(Table).TabloAdi.AsString);
  cbbtable_nameChange(cbbtable_name);
  if cbbcolumn_name.Items.IndexOf(TSysGridKolon(Table).KolonAdi.AsString) = -1 then
    cbbcolumn_name.Items.Add(TSysGridKolon(Table).KolonAdi.AsString);
  cbbcolumn_name.ItemIndex := cbbcolumn_name.Items.IndexOf(TSysGridKolon(Table).KolonAdi.AsString);
  edtseq_no.Text := TSysGridKolon(Table).SiraNo.AsString;
  edtcol_width.Text := TSysGridKolon(Table).KolonGenislik.AsString;
  edtdata_format.Text := TSysGridKolon(Table).VeriFormati.AsString;
  chkis_show.Checked := TSysGridKolon(Table).IsGorunur.AsBoolean;
  chkis_show_helper.Checked := TSysGridKolon(Table).IsHelperGorunur.AsBoolean;

  edtmin_value.Text := TSysGridKolon(Table).MinDeger.AsString;
  SetColor(StrToIntDef(edtmin_color.Text, 0), edtmin_color);
  edtmax_value.Text := TSysGridKolon(Table).MaxDeger.AsString;
  SetColor(StrToIntDef(edtmax_color.Text, 0), edtmax_color);
  edtmax_value_percent.Text := TSysGridKolon(Table).MaxDegerYuzdesi.AsString;



  SetColor(StrToIntDef(edtcolor_bar.Text, 0), edtcolor_bar);
  SetColor(StrToIntDef(edtcolor_bar_back.Text, 0), edtcolor_bar_back);
  SetColor(StrToIntDef(edtcolor_bar_text.Text, 0), edtcolor_bar_text);
  DrawBar;
end;

procedure TfrmSysGridKolon.Repaint;
begin
  inherited;
  edtmin_color.ReadOnly := True;
  edtmax_color.ReadOnly := True;

  edtcolor_bar.ReadOnly := True;
  edtcolor_bar_back.ReadOnly := True;
  edtcolor_bar_text.ReadOnly := True;
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

function TfrmSysGridKolon.ValidateInput(
  panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput();

  //arada rakam atlyacak þekilde giriþ yapýlmýþsa rakamý otomatik olarak düzelt.
  //maks sequence no dan sonraki rakam gelmek zorunda.
  if (FormMode = ifmNewRecord)
  or (FormMode = ifmCopyNewRecord)
  then
  begin
    if StrToInt(edtseq_no.Text) > TSysGridKolon(Table).GetMaxSequenceNo(cbbtable_name.Text)+1 then
      edtseq_no.Text := IntToStr(TSysGridKolon(Table).GetMaxSequenceNo(cbbtable_name.Text) + 1)
  end
  else if (FormMode = ifmUpdate) then
  begin
    if StrToInt(edtseq_no.Text) > TSysGridKolon(Table).GetMaxSequenceNo(TSysGridKolon(Table).TabloAdi.Value) then
      edtseq_no.Text := IntToStr(TSysGridKolon(Table).GetMaxSequenceNo(TSysGridKolon(Table).TabloAdi.Value));
  end;
end;

procedure TfrmSysGridKolon.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if cbbtable_name.Items.IndexOf(cbbtable_name.Text) = -1 then
        raise Exception.Create('Listede olmayan bir Tablo Adý giremezsiniz!' + AddLBs() + cbbtable_name.Text);

      if (FormMode = ifmUpdate) then
      begin
        if TSysGridKolon(Table).SiraNo.Value = StrToInt(edtseq_no.Text) then
          TSysGridKolon(Table).FSeqStatus := ssNone
        else if TSysGridKolon(Table).SiraNo.Value > StrToInt(edtseq_no.Text) then
          TSysGridKolon(Table).FSeqStatus := ssAzalma
        else if TSysGridKolon(Table).SiraNo.Value < StrToInt(edtseq_no.Text) then
          TSysGridKolon(Table).FSeqStatus := ssArtis;

        TSysGridKolon(Table).FOldValue := TSysGridKolon(Table).SiraNo.Value;
      end;

      TSysGridKolon(Table).TabloAdi.Value := cbbtable_name.Text;
      TSysGridKolon(Table).KolonAdi.Value := cbbcolumn_name.Text;
      TSysGridKolon(Table).SiraNo.Value := edtseq_no.Text;
      TSysGridKolon(Table).KolonGenislik.Value := edtcol_width.Text;
      TSysGridKolon(Table).VeriFormati.Value := edtdata_format.Text;
      TSysGridKolon(Table).IsGorunur.Value := chkis_show.Checked;
      TSysGridKolon(Table).IsHelperGorunur.Value := chkis_show_helper.Checked;

      TSysGridKolon(Table).MinDeger.Value := StrToFloatDef(edtmin_value.Text, 0);
      TSysGridKolon(Table).MinRenk.Value := StrToIntDef(edtmin_color.Text, 0);
      TSysGridKolon(Table).MaxDeger.Value := StrToFloatDef(edtmax_value.Text, 0);
      TSysGridKolon(Table).MaxRenk.Value := StrToIntDef(edtmax_color.Text, 0);
      TSysGridKolon(Table).MaxDegerYuzdesi.Value := StrToFloatDef(edtmax_value_percent.Text, 0);
      TSysGridKolon(Table).BarRengi.Value := StrToIntDef(edtcolor_bar.Text, 0);
      TSysGridKolon(Table).BarArkaRengi.Value := StrToIntDef(edtcolor_bar_back.Text, 0);
      TSysGridKolon(Table).BarYaziRengi.Value := StrToIntDef(edtcolor_bar_text.Text, 0);

      inherited;
    end;
  end
  else
    inherited;
end;

end.
