unit ufrmSysGridKolon;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.View.SysViewTables,
  Ths.Erp.Database.Table.SysGridKolon;

type
  TfrmSysGridKolon = class(TfrmBaseInputDB)
    lbltablo_adi: TLabel;
    lblkolon_adi: TLabel;
    lblgenislik: TLabel;
    lblsira_no: TLabel;
    lblis_gorunsun: TLabel;
    lblis_gorunsun_helper_form: TLabel;
    lblmaks_renk: TLabel;
    lblmaks_deger: TLabel;
    lblmin_renk: TLabel;
    lblmin_deger: TLabel;
    imgExample: TImage;
    lblrenk_bar: TLabel;
    lblrenk_bar_arka: TLabel;
    lblrenk_bar_yazi: TLabel;
    lblmaks_deger_yuzde: TLabel;
    lblozet_tipi: TLabel;
    lbldata_format: TLabel;
    lblozet_format: TLabel;
    cbbtablo_adi: TComboBox;
    cbbkolon_adi: TComboBox;
    edtsira_no: TEdit;
    edtgenislik: TEdit;
    edtdata_format: TEdit;
    chkis_gorunsun: TCheckBox;
    chkis_gorunsun_helper_form: TCheckBox;
    edtmin_deger: TEdit;
    edtmin_renk: TEdit;
    edtmaks_deger: TEdit;
    edtmaks_renk: TEdit;
    edtmaks_deger_yuzde: TEdit;
    edtrenk_bar: TEdit;
    edtrenk_bar_arka: TEdit;
    edtrenk_bar_yazi: TEdit;
    cbbozet_tipi: TComboBox;
    edtozet_format: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure cbbtablo_adiChange(Sender: TObject);
    procedure edtmaks_renkDblClick(Sender: TObject);
    procedure edtrenk_barDblClick(Sender: TObject);
    procedure edtrenk_bar_arkaDblClick(Sender: TObject);
    procedure edtrenk_bar_yaziDblClick(Sender: TObject);
    procedure edtcolor_bar_text_activeDblClick(Sender: TObject);
    procedure edtmin_renkDblClick(Sender: TObject);
  private
    FSysViewTables: TSysViewTables;

    procedure FillColNameForColWidth(pComboBox: TComboBox; pTableName: string);
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
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

{$R *.dfm}

procedure TfrmSysGridKolon.FillColNameForColWidth(pComboBox: TComboBox; pTableName: string);
begin
  pComboBox.Clear;

  with GDataBase.NewQuery do
  try
    Close;
    SQL.Text := 'SELECT distinct v.column_name, ordinal_position FROM sys_view_columns v ' +
                'LEFT JOIN sys_grid_kolon a ON a.tablo_adi=v.table_name and a.kolon_adi = v.column_name ' +
                'WHERE v.table_name=' + QuotedStr(pTableName) + ' and a.kolon_adi is null ' +
                'GROUP BY v.column_name, ordinal_position ' +
                'ORDER BY ordinal_position ASC ';
    Open;
    while NOT EOF do
    begin
      pComboBox.Items.Add( Fields.Fields[0].AsString );
      Next;
    end;
    EmptyDataSet;
    Close;
  finally
    Free;
  end;
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
  if  (TryStrToInt(edtrenk_bar.Text, vVal))
  and (TryStrToInt(edtrenk_bar_arka.Text, vVal))
  and (TryStrToInt(edtrenk_bar_yazi.Text, vVal))
  //and (TryStrToInt(edtrecolor_bar_text_active.Text, vVal))
  then
  begin
    with imgExample do
    begin
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Width := 1;

      Canvas.Pen.Color := StringToColor(edtrenk_bar_arka.Text);
      Canvas.Brush.Color := StringToColor(edtrenk_bar_arka.Text);
      x1 := 0;  x2 := Width;  y1 := 0;  y2 := Height;
      Canvas.Rectangle( x1, y1, x2, y2 );

      Canvas.Pen.Color := StringToColor(edtrenk_bar.Text);
      Canvas.Brush.Color := StringToColor(edtrenk_bar.Text);
      x1 := 1;  x2 := trunc(Width*0.40);  y1 := 1;  y2 := Height;
      Canvas.Rectangle( x1, y1, x2, y2 );

      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := StringToColor( edtrenk_bar_yazi.Text );
      //Canvas.Brush.Color := StringToColor(edtcolor_bar_text.Text);
      rect.Left := (imgExample.Width - Canvas.TextWidth(vTemp)) div 2;
      rect.Right := rect.Left + Canvas.TextWidth(vTemp);
      rect.Top := (imgExample.Height - Canvas.TextHeight(vTemp)) div 2;
      rect.Bottom := rect.Top + Canvas.TextHeight(vTemp);
      Canvas.TextRect(rect, vTemp);

      Repaint;
    end;
  end;
end;

procedure TfrmSysGridKolon.edtrenk_barDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtrenk_bar.Text, 0)), edtrenk_bar);
end;

procedure TfrmSysGridKolon.edtrenk_bar_arkaDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtrenk_bar_arka.Text, 0)), edtrenk_bar_arka);
end;

procedure TfrmSysGridKolon.edtrenk_bar_yaziDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtrenk_bar_yazi.Text, 0)), edtrenk_bar_yazi);
end;

procedure TfrmSysGridKolon.edtcolor_bar_text_activeDblClick(Sender: TObject);
begin
  //SetColor(GetDialogColor(StrToIntDef(edtcolor_bar_text_active.Text, 0)), edtcolor_bar_text_active);
end;

procedure TfrmSysGridKolon.edtmaks_renkDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtmaks_renk.Text, 0)), edtmaks_renk);
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

  cbbozet_tipi.Items.Add('0 YOK');
  cbbozet_tipi.Items.Add('1 TOPLAM MÝKTAR');
  cbbozet_tipi.Items.Add('2 EN KÜÇÜK');
  cbbozet_tipi.Items.Add('3 EN BÜYÜK');
  cbbozet_tipi.Items.Add('4 TOPLAM SAYI');
  cbbozet_tipi.Items.Add('5 ORTALAMA MÝKTAR');
  cbbozet_tipi.ItemIndex := 0;
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
  edtgenislik.Text := TSysGridKolon(Table).Genislik.AsString;
  edtdata_format.Text := TSysGridKolon(Table).DataFormat.AsString;
  chkis_gorunsun.Checked := TSysGridKolon(Table).IsGorunsun.AsBoolean;
  chkis_gorunsun_helper_form.Checked := TSysGridKolon(Table).IsGorunsunHelperForm.AsBoolean;

  edtmin_deger.Text := TSysGridKolon(Table).MinDeger.AsString;
  SetColor(StrToIntDef(edtmin_renk.Text, 0), edtmin_renk);
  edtmaks_deger.Text := TSysGridKolon(Table).MaksDeger.AsString;
  SetColor(StrToIntDef(edtmaks_renk.Text, 0), edtmaks_renk);
  edtmaks_deger_yuzde.Text := TSysGridKolon(Table).MaksDegerYuzde.AsString;



  SetColor(StrToIntDef(edtrenk_bar.Text, 0), edtrenk_bar);
  SetColor(StrToIntDef(edtrenk_bar_arka.Text, 0), edtrenk_bar_arka);
  SetColor(StrToIntDef(edtrenk_bar_yazi.Text, 0), edtrenk_bar_yazi);
  //SetColor(StrToIntDef(edtcolor_bar_text_active.Text, 0), edtcolor_bar_text_active);
  DrawBar;

  cbbozet_tipi.ItemIndex := TSysGridKolon(Table).OzetTipi.Value;
  edtozet_format.Text := VarToStr(TSysGridKolon(Table).OzetFormat.Value);
end;

procedure TfrmSysGridKolon.Repaint;
begin
  inherited;
  edtmin_renk.ReadOnly := True;
  edtmaks_renk.ReadOnly := True;

  edtrenk_bar.ReadOnly := True;
  edtrenk_bar_arka.ReadOnly := True;
  edtrenk_bar_yazi.ReadOnly := True;
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
    if StrToInt(edtsira_no.Text) > TSysGridKolon(Table).GetMaxSequenceNo(cbbtablo_adi.Text)+1 then
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
        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adý giremezsiniz!', '#1', LngMsgError, LngSystem) );

      if (FormMode = ifmUpdate) then
      begin
        if TSysGridKolon(Table).SiraNo.Value = StrToInt(edtsira_no.Text) then
          TSysGridKolon(Table).SiraDurum := ssNone
        else if TSysGridKolon(Table).SiraNo.Value > StrToInt(edtsira_no.Text) then
          TSysGridKolon(Table).SiraDurum := ssAzalma
        else if TSysGridKolon(Table).SiraNo.Value < StrToInt(edtsira_no.Text) then
          TSysGridKolon(Table).SiraDurum := ssArtis;

        TSysGridKolon(Table).EskiDeger := TSysGridKolon(Table).SiraNo.Value;
      end;

      TSysGridKolon(Table).TabloAdi.Value := cbbtablo_adi.Text;
      TSysGridKolon(Table).KolonAdi.Value := cbbkolon_adi.Text;
      TSysGridKolon(Table).SiraNo.Value := edtsira_no.Text;
      TSysGridKolon(Table).Genislik.Value := edtgenislik.Text;
      TSysGridKolon(Table).DataFormat.Value := edtdata_format.Text;
      TSysGridKolon(Table).IsGorunsun.Value := chkis_gorunsun.Checked;
      TSysGridKolon(Table).IsGorunsunHelperForm.Value := chkis_gorunsun_helper_form.Checked;

      TSysGridKolon(Table).MinDeger.Value := StrToFloatDef(edtmin_deger.Text, 0);
      TSysGridKolon(Table).MinRenk.Value := StrToIntDef(edtmin_renk.Text, 0);
      TSysGridKolon(Table).MaksDeger.Value := StrToFloatDef(edtmaks_deger.Text, 0);
      TSysGridKolon(Table).MaksRenk.Value := StrToIntDef(edtmaks_renk.Text, 0);
      TSysGridKolon(Table).MaksDegerYuzde.Value := StrToFloatDef(edtmaks_deger_yuzde.Text, 0);
      TSysGridKolon(Table).RenkBar.Value := StrToIntDef(edtrenk_bar.Text, 0);
      TSysGridKolon(Table).RenkBarArka.Value := StrToIntDef(edtrenk_bar_arka.Text, 0);
      TSysGridKolon(Table).RenkBarYazi.Value := StrToIntDef(edtrenk_bar_yazi.Text, 0);
      TSysGridKolon(Table).OzetTipi.Value := cbbozet_tipi.ItemIndex;
      TSysGridKolon(Table).OzetFormat.Value := edtozet_format.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
