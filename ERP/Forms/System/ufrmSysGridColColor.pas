unit ufrmSysGridColColor;

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

  , Ths.Erp.Database.Table.View.SysViewTables
  , Ths.Erp.Database.Table.View.SysViewColumns
  ;

type
  TfrmSysGridColColor = class(TfrmBaseInputDB)
    lblcolumn_name: TLabel;
    lblmax_color: TLabel;
    lblmax_value: TLabel;
    lblmin_color: TLabel;
    lblmin_value: TLabel;
    lbltable_name: TLabel;
    cbbtable_name: TComboBox;
    cbbcolumn_name: TComboBox;
    edtmin_value: TEdit;
    edtmin_color: TEdit;
    edtmax_value: TEdit;
    edtmax_color: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure cbbtable_nameChange(Sender: TObject);
    procedure edtmin_colorDblClick(Sender: TObject);
    procedure edtmax_colorDblClick(Sender: TObject);
  private
    FSysViewColumns: TSysViewColumns;
    FSysViewTables: TSysViewTables;
    procedure SetColor(color: TColor; editColor: TEdit);
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
  , Ths.Erp.Database.Table.SysGridColColor
  ;

{$R *.dfm}

procedure TfrmSysGridColColor.cbbtable_nameChange(Sender: TObject);
var
  n1: Integer;
begin
  FSysViewColumns.SelectToList(' AND ' + FSysViewColumns.TableName + '.' + FSysViewColumns.TableName1.FieldName + '=' + QuotedStr(cbbtable_name.Text), False, False);
  cbbcolumn_name.Clear;
  for n1 := 0 to FSysViewColumns.List.Count-1 do
    cbbcolumn_name.Items.Add(TSysViewColumns(FSysViewColumns.List[n1]).ColumnName.Value);
end;

destructor TfrmSysGridColColor.Destroy;
begin
  FreeAndNil(FSysViewTables);
  FreeAndNil(FSysViewColumns);
  inherited;
end;

procedure TfrmSysGridColColor.edtmax_colorDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtmax_color.Text, 0)), edtmax_color);
end;

procedure TfrmSysGridColColor.edtmin_colorDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtmin_color.Text, 0)), edtmin_color);
end;

procedure TfrmSysGridColColor.FormCreate(Sender: TObject);
begin
  inherited;

  cbbtable_name.CharCase := ecNormal;
  cbbcolumn_name.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(Table.Database);
  FSysViewColumns := TSysViewColumns.Create(Table.Database);

  fillComboBoxData(cbbtable_name, FSysViewTables, [FSysViewTables.TableName1.FieldName], '', True);
  cbbtable_nameChange(cbbtable_name);
end;

procedure TfrmSysGridColColor.FormShow(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysGridColColor.RefreshData();
begin
  inherited;
  cbbtable_nameChange(cbbtable_name);
  cbbcolumn_name.ItemIndex := cbbcolumn_name.Items.IndexOf(FormatedVariantVal(TSysGridColColor(Table).ColumnName));

  SetColor(StrToIntDef(edtmin_color.Text, 0), edtmin_color);
  SetColor(StrToIntDef(edtmax_color.Text, 0), edtmax_color);
end;

procedure TfrmSysGridColColor.Repaint;
begin
  inherited;
  edtmin_color.ReadOnly := True;
  edtmax_color.ReadOnly := True;
end;

procedure TfrmSysGridColColor.SetColor(color: TColor; editColor: TEdit);
begin
  editColor.Text := IntToStr(color);
  editColor.Color := color;
  editColor.thsColorActive := color;
  editColor.thsColorRequiredInput := color;
  editColor.Repaint;
end;

procedure TfrmSysGridColColor.btnAcceptClick(Sender: TObject);
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
