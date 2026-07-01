unit ufrmSysGridColSummary;

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

  , Ths.Erp.Database.Table
  , Ths.Erp.Database.Table.View.SysViewTables
  ;

type
  TfrmSysGridColSummary = class(TfrmBaseInputDB)
    lbltable_name: TLabel;
    cbbtable_name: TComboBox;
    lblcolumn_name: TLabel;
    cbbcolumn_name: TComboBox;
    lblsummary_type: TLabel;
    cbbsummary_type: TComboBox;
    lblformat: TLabel;
    edtformat: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure cbbtable_nameChange(Sender: TObject);
  private
    FSysViewTables: TSysViewTables;

    procedure FillColNameForColSummary(pComboBox: TComboBox; pTableName: string);
  public
    destructor Destroy; override;
  protected
  published
  end;

implementation

uses
    Ths.Erp.Database.Table.SysGridColSummary
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Constants
  , Ths.Erp.Globals
  ;

{$R *.dfm}

procedure TfrmSysGridColSummary.FillColNameForColSummary(pComboBox: TComboBox; pTableName: string);
begin
  pComboBox.Clear;

  with GDataBase.NewQuery do
  try
    Close;
    SQL.Text := 'SELECT distinct v.column_name, ordinal_position FROM sys_view_columns v ' +
                'LEFT JOIN sys_grid_col_summary a ON a.table_name=v.table_name and a.column_name = v.column_name ' +
                'WHERE v.table_name=' + QuotedStr(pTableName) + ' and a.column_name is null ' +
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

procedure TfrmSysGridColSummary.cbbtable_nameChange(Sender: TObject);
begin
  FillColNameForColSummary(TComboBox(cbbcolumn_name), ReplaceRealColOrTableNameTo(cbbtable_name.Text));
end;

destructor TfrmSysGridColSummary.Destroy;
begin
  FSysViewTables.Free;

  inherited;
end;

procedure TfrmSysGridColSummary.FormCreate(Sender: TObject);
begin
  inherited;

  //standart dýþý olan küçük harf kullanýlacak bilgileri özellikle belirt. diðerleri büyük harf olarak çalýþýr.
  cbbtable_name.CharCase := ecNormal;
  cbbcolumn_name.CharCase := ecNormal;


  FSysViewTables := TSysViewTables.Create(GDatabase);

  fillComboBoxData(cbbtable_name, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
  cbbtable_nameChange(cbbtable_name);

  cbbsummary_type.Items.Add('0 NONE');
  cbbsummary_type.Items.Add('1 SUM');
  cbbsummary_type.Items.Add('2 MIN');
  cbbsummary_type.Items.Add('3 MAX');
  cbbsummary_type.Items.Add('4 COUNT');
  cbbsummary_type.Items.Add('5 AVG');
end;

procedure TfrmSysGridColSummary.RefreshData();
begin
  cbbtable_name.ItemIndex := cbbtable_name.Items.IndexOf(TSysGridColSummary(Table).TableName1.Value);
  cbbtable_nameChange(cbbtable_name);

  if cbbcolumn_name.Items.IndexOf(TSysGridColSummary(Table).ColumnName.Value) = -1 then
    cbbcolumn_name.Items.Add(TSysGridColSummary(Table).ColumnName.Value);
  cbbcolumn_name.ItemIndex := cbbcolumn_name.Items.IndexOf(TSysGridColSummary(Table).ColumnName.Value);
  cbbsummary_type.ItemIndex := TSysGridColSummary(Table).SumaryType.Value;
  edtformat.Text := TSysGridColSummary(Table).Format.Value;
end;

procedure TfrmSysGridColSummary.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if cbbtable_name.Items.IndexOf(cbbtable_name.Text) = -1 then
        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adý giremezsiniz!', '#1', LngMsgError, LngSystem) );
//      if cbbcolumn_name.Items.IndexOf(cbbcolumn_name.Text) = -1 then
//        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adý giremezsiniz!', '#1', LngMsgError, LngSystem) );
      if cbbsummary_type.ItemIndex = -1 then
        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adý giremezsiniz!', '#1', LngMsgError, LngSystem) );

      TSysGridColSummary(Table).TableName1.Value := cbbtable_name.Text;
      TSysGridColSummary(Table).ColumnName.Value := cbbcolumn_name.Text;
      TSysGridColSummary(Table).SumaryType.Value := cbbsummary_type.ItemIndex;
      TSysGridColSummary(Table).Format.Value := edtformat.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
