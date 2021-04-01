unit ufrmSysGridColPercent;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , System.StrUtils
  , System.Math
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.ComCtrls
  , Vcl.AppEvnts
  , Vcl.Menus
  , Vcl.Samples.Spin

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.Memo
  , Ths.Erp.Helper.ComboBox

  , ufrmBase
  , ufrmBaseInputDB

  , Ths.Erp.Database.Table.View.SysViewColumns
  , Ths.Erp.Database.Table.View.SysViewTables
  ;

type
  TfrmSysGridColPercent = class(TfrmBaseInputDB)
    imgExample: TImage;
    lblcolor_bar: TLabel;
    lblcolor_bar_back: TLabel;
    lblcolor_bar_text: TLabel;
    lblcolor_bar_text_active: TLabel;
    lblcolumn_name: TLabel;
    lblmax_value: TLabel;
    lbltable_name: TLabel;
    cbbtable_name: TComboBox;
    cbbcolumn_name: TComboBox;
    edtmax_value: TEdit;
    edtcolor_bar: TEdit;
    edtcolor_bar_back: TEdit;
    edtcolor_bar_text: TEdit;
    edtcolor_bar_text_active: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure cbbtable_nameChange(Sender: TObject);
    procedure edtcolor_barDblClick(Sender: TObject);
    procedure edtcolor_bar_backDblClick(Sender: TObject);
    procedure edtcolor_bar_textDblClick(Sender: TObject);
    procedure edtcolor_bar_text_activeDblClick(Sender: TObject);
  private
    FSysViewTables: TSysViewTables;
    FSysViewColumns: TSysViewColumns;

    procedure SetColor(color: TColor; editColor: TEdit);
    procedure DrawBar;
  public
    destructor Destroy; override;
    procedure Repaint; override;
  protected
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.SysGridColPercent
  ;

{$R *.dfm}

procedure TfrmSysGridColPercent.cbbtable_nameChange(Sender: TObject);
begin
  fillComboBoxData(cbbcolumn_name, FSysViewColumns, [FSysViewColumns.ColumnName.FieldName], ' AND ' + FSysViewColumns.TableName1.FieldName + '=' + QuotedStr(cbbtable_name.Text) + ' ORDER BY ' + FSysViewColumns.OrdinalPosition.FieldName + ' ASC ');
end;

destructor TfrmSysGridColPercent.Destroy;
begin
  FreeAndNil(FSysViewTables);
  FreeAndNil(FSysViewColumns);
  inherited;
end;

procedure TfrmSysGridColPercent.DrawBar;
var
  x1, x2, y1, y2, vVal: Integer;
  rect: TRect;
  vTemp: string;
begin
  vTemp := 'Example %40';
  if  (TryStrToInt(edtcolor_bar.Text, vVal))
  and (TryStrToInt(edtcolor_bar_back.Text, vVal))
  and (TryStrToInt(edtcolor_bar_text.Text, vVal))
  and (TryStrToInt(edtcolor_bar_text_active.Text, vVal))
  then
  begin
    with imgExample do
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

procedure TfrmSysGridColPercent.edtcolor_barDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtcolor_bar.Text, 0)), edtcolor_bar);
end;

procedure TfrmSysGridColPercent.edtcolor_bar_backDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtcolor_bar_back.Text, 0)), edtcolor_bar_back);
end;

procedure TfrmSysGridColPercent.edtcolor_bar_textDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtcolor_bar_text.Text, 0)), edtcolor_bar_text);
end;

procedure TfrmSysGridColPercent.edtcolor_bar_text_activeDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtcolor_bar_text_active.Text, 0)), edtcolor_bar_text_active);
end;

procedure TfrmSysGridColPercent.FormCreate(Sender: TObject);
begin
  inherited;

  cbbtable_name.CharCase := ecNormal;
  cbbcolumn_name.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(Table.Database);
  FSysViewColumns := TSysViewColumns.Create(Table.Database);

  fillComboBoxData(cbbtable_name, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
  cbbtable_nameChange(cbbtable_name);
end;

procedure TfrmSysGridColPercent.FormShow(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysGridColPercent.RefreshData();
begin
  inherited;
  cbbtable_nameChange(cbbtable_name);
  cbbcolumn_name.ItemIndex := cbbcolumn_name.Items.IndexOf(FormatedVariantVal(TSysGridColPercent(Table).ColumnName));

  SetColor(StrToIntDef(edtcolor_bar.Text, 0), edtcolor_bar);
  SetColor(StrToIntDef(edtcolor_bar_back.Text, 0), edtcolor_bar_back);
  SetColor(StrToIntDef(edtcolor_bar_text.Text, 0), edtcolor_bar_text);
  SetColor(StrToIntDef(edtcolor_bar_text_active.Text, 0), edtcolor_bar_text_active);

  DrawBar;
end;

procedure TfrmSysGridColPercent.Repaint;
begin
  inherited;
  edtcolor_bar.ReadOnly := True;
  edtcolor_bar_back.ReadOnly := True;
  edtcolor_bar_text.ReadOnly := True;
  edtcolor_bar_text_active.ReadOnly := True;
end;

procedure TfrmSysGridColPercent.SetColor(color: TColor; editColor: TEdit);
begin
  editColor.Text := IntToStr(color);
  editColor.Color := color;
  editColor.thsColorActive := color;
  editColor.thsColorRequiredInput := color;
  editColor.Repaint;
  DrawBar;
end;

procedure TfrmSysGridColPercent.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if cbbtable_name.Items.IndexOf(cbbtable_name.Text) = -1 then
        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adý giremezsiniz!', '#1', LngMsgError, LngSystem) );

      if cbbcolumn_name.Items.IndexOf(cbbcolumn_name.Text) = -1 then
        raise Exception.Create(TranslateText('Listede olmayan bir Kolon Adý giremezsiniz!', '#1', LngMsgError, LngSystem) );

      btnAcceptAuto;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
