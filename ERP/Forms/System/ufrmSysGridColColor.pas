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
    lblColumnName: TLabel;
    lblMaxColor: TLabel;
    lblMaxValue: TLabel;
    lblMinColor: TLabel;
    lblMinValue: TLabel;
    lblTableName: TLabel;
    cbbTableName: TComboBox;
    cbbColumnName: TComboBox;
    edtMinValue: TEdit;
    edtMinColor: TEdit;
    edtMaxValue: TEdit;
    edtMaxColor: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure cbbTableNameChange(Sender: TObject);
    procedure edtMinColorDblClick(Sender: TObject);
    procedure edtMaxColorDblClick(Sender: TObject);
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

procedure TfrmSysGridColColor.cbbTableNameChange(Sender: TObject);
var
  n1: Integer;
begin
  FSysViewColumns.SelectToList(' AND ' + FSysViewColumns.TableName + '.' + FSysViewColumns.TableName1.FieldName + '=' + QuotedStr(cbbTableName.Text), False, False);
  cbbColumnName.Clear;
  for n1 := 0 to FSysViewColumns.List.Count-1 do
    cbbColumnName.Items.Add(TSysViewColumns(FSysViewColumns.List[n1]).ColumnName.Value);
end;

destructor TfrmSysGridColColor.Destroy;
begin
  FreeAndNil(FSysViewTables);
  FreeAndNil(FSysViewColumns);
  inherited;
end;

procedure TfrmSysGridColColor.edtMaxColorDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtMaxColor.Text, 0)), edtMaxColor);
end;

procedure TfrmSysGridColColor.edtMinColorDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtMinColor.Text, 0)), edtMinColor);
end;

procedure TfrmSysGridColColor.FormCreate(Sender: TObject);
begin
  inherited;

  cbbTableName.CharCase := ecNormal;
  cbbColumnName.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(Table.Database);
  FSysViewColumns := TSysViewColumns.Create(Table.Database);

  fillComboBoxData(cbbTableName, FSysViewTables, [FSysViewTables.TableName1.FieldName], '', True);
  cbbTableNameChange(cbbTableName);
end;

procedure TfrmSysGridColColor.FormShow(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysGridColColor.RefreshData();
begin
  inherited;
  cbbTableNameChange(cbbTableName);
  cbbColumnName.ItemIndex := cbbColumnName.Items.IndexOf(FormatedVariantVal(TSysGridColColor(Table).ColumnName));

  SetColor(StrToIntDef(edtMinColor.Text, 0), edtMinColor);
  SetColor(StrToIntDef(edtMaxColor.Text, 0), edtMaxColor);
end;

procedure TfrmSysGridColColor.Repaint;
begin
  inherited;
  edtMinColor.ReadOnly := True;
  edtMaxColor.ReadOnly := True;
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
