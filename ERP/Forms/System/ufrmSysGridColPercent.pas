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
    lblColorBar: TLabel;
    lblColorBarBack: TLabel;
    lblColorBarText: TLabel;
    lblColorBarTextActive: TLabel;
    lblColumnName: TLabel;
    lblMaxValue: TLabel;
    lblTableName: TLabel;
    cbbTableName: TComboBox;
    cbbColumnName: TComboBox;
    edtMaxValue: TEdit;
    edtColorBar: TEdit;
    edtColorBarBack: TEdit;
    edtColorBarText: TEdit;
    edtColorBarTextActive: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure cbbTableNameChange(Sender: TObject);
    procedure edtColorBarDblClick(Sender: TObject);
    procedure edtColorBarBackDblClick(Sender: TObject);
    procedure edtColorBarTextDblClick(Sender: TObject);
    procedure edtColorBarTextActiveDblClick(Sender: TObject);
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

procedure TfrmSysGridColPercent.cbbTableNameChange(Sender: TObject);
begin
  fillComboBoxData(cbbColumnName, FSysViewColumns, [FSysViewColumns.ColumnName.FieldName], ' AND ' + FSysViewColumns.TableName1.FieldName + '=' + QuotedStr(cbbTableName.Text) + ' ORDER BY ' + FSysViewColumns.OrdinalPosition.FieldName + ' ASC ');
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
  if  (TryStrToInt(edtColorBar.Text, vVal))
  and (TryStrToInt(edtColorBarBack.Text, vVal))
  and (TryStrToInt(edtColorBarText.Text, vVal))
  and (TryStrToInt(edtColorBarTextActive.Text, vVal))
  then
  begin
    with imgExample do
    begin
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Width := 1;

      Canvas.Pen.Color := StringToColor(edtColorBarBack.Text);
      Canvas.Brush.Color := StringToColor(edtColorBarBack.Text);
      x1 := 0;  x2 := Width;  y1 := 0;  y2 := Height;
      Canvas.Rectangle( x1, y1, x2, y2 );

      Canvas.Pen.Color := StringToColor(edtColorBar.Text);
      Canvas.Brush.Color := StringToColor(edtColorBar.Text);
      x1 := 1;  x2 := trunc(Width*0.40);  y1 := 1;  y2 := Height;
      Canvas.Rectangle( x1, y1, x2, y2 );

      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := StringToColor( edtColorBarText.Text );
      rect.Left := (imgExample.Width - Canvas.TextWidth(vTemp)) div 2;
      rect.Right := rect.Left + Canvas.TextWidth(vTemp);
      rect.Top := (imgExample.Height - Canvas.TextHeight(vTemp)) div 2;
      rect.Bottom := rect.Top + Canvas.TextHeight(vTemp);
      Canvas.TextRect(rect, vTemp);

      Repaint;
    end;
  end;
end;

procedure TfrmSysGridColPercent.edtColorBarDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtColorBar.Text, 0)), edtColorBar);
end;

procedure TfrmSysGridColPercent.edtColorBarBackDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtColorBarBack.Text, 0)), edtColorBarBack);
end;

procedure TfrmSysGridColPercent.edtColorBarTextDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtColorBarText.Text, 0)), edtColorBarText);
end;

procedure TfrmSysGridColPercent.edtColorBarTextActiveDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtColorBarTextActive.Text, 0)), edtColorBarTextActive);
end;

procedure TfrmSysGridColPercent.FormCreate(Sender: TObject);
begin
  inherited;

  cbbTableName.CharCase := ecNormal;
  cbbColumnName.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(Table.Database);
  FSysViewColumns := TSysViewColumns.Create(Table.Database);

  fillComboBoxData(cbbTableName, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
  cbbTableNameChange(cbbTableName);
end;

procedure TfrmSysGridColPercent.FormShow(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysGridColPercent.RefreshData();
begin
  inherited;
  cbbTableNameChange(cbbTableName);
  cbbColumnName.ItemIndex := cbbColumnName.Items.IndexOf(FormatedVariantVal(TSysGridColPercent(Table).ColumnName));

  SetColor(StrToIntDef(edtColorBar.Text, 0), edtColorBar);
  SetColor(StrToIntDef(edtColorBarBack.Text, 0), edtColorBarBack);
  SetColor(StrToIntDef(edtColorBarText.Text, 0), edtColorBarText);
  SetColor(StrToIntDef(edtColorBarTextActive.Text, 0), edtColorBarTextActive);

  DrawBar;
end;

procedure TfrmSysGridColPercent.Repaint;
begin
  inherited;
  edtColorBar.ReadOnly := True;
  edtColorBarBack.ReadOnly := True;
  edtColorBarText.ReadOnly := True;
  edtColorBarTextActive.ReadOnly := True;
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
      if cbbTableName.Items.IndexOf(cbbTableName.Text) = -1 then
        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adi giremezsiniz!', '#1', LngMsgError, LngSystem) );

      if cbbColumnName.Items.IndexOf(cbbColumnName.Text) = -1 then
        raise Exception.Create(TranslateText('Listede olmayan bir Kolon Adi giremezsiniz!', '#1', LngMsgError, LngSystem) );

      btnAcceptAuto;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
