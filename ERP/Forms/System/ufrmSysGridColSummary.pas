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
    lblTableName: TLabel;
    cbbTableName: TComboBox;
    lblColumnName: TLabel;
    cbbColumnName: TComboBox;
    lblSummaryType: TLabel;
    cbbSummaryType: TComboBox;
    lblFormat: TLabel;
    edtFormat: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure cbbTableNameChange(Sender: TObject);
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

procedure TfrmSysGridColSummary.cbbTableNameChange(Sender: TObject);
begin
  FillColNameForColSummary(TComboBox(cbbColumnName), ReplaceRealColOrTableNameTo(cbbTableName.Text));
end;

destructor TfrmSysGridColSummary.Destroy;
begin
  FSysViewTables.Free;

  inherited;
end;

procedure TfrmSysGridColSummary.FormCreate(Sender: TObject);
begin
  inherited;

  //standart default olan kucuk harf kullanilacak bilgileri ozellikle belirt. digerleri buyuk harf olarak calisir.
  cbbTableName.CharCase := ecNormal;
  cbbColumnName.CharCase := ecNormal;


  FSysViewTables := TSysViewTables.Create(GDatabase);

  fillComboBoxData(cbbTableName, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
  cbbTableNameChange(cbbTableName);

  cbbSummaryType.Items.Add('0 NONE');
  cbbSummaryType.Items.Add('1 SUM');
  cbbSummaryType.Items.Add('2 MIN');
  cbbSummaryType.Items.Add('3 MAX');
  cbbSummaryType.Items.Add('4 COUNT');
  cbbSummaryType.Items.Add('5 AVG');
end;

procedure TfrmSysGridColSummary.RefreshData();
begin
  cbbTableName.ItemIndex := cbbTableName.Items.IndexOf(TSysGridColSummary(Table).TableName1.Value);
  cbbTableNameChange(cbbTableName);

  if cbbColumnName.Items.IndexOf(TSysGridColSummary(Table).ColumnName.Value) = -1 then
    cbbColumnName.Items.Add(TSysGridColSummary(Table).ColumnName.Value);
  cbbColumnName.ItemIndex := cbbColumnName.Items.IndexOf(TSysGridColSummary(Table).ColumnName.Value);
  cbbSummaryType.ItemIndex := TSysGridColSummary(Table).SumaryType.Value;
  edtFormat.Text := TSysGridColSummary(Table).Format.Value;
end;

procedure TfrmSysGridColSummary.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if cbbTableName.Items.IndexOf(cbbTableName.Text) = -1 then
        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adi giremezsiniz!', '#1', LngMsgError, LngSystem) );
//      if cbbColumnName.Items.IndexOf(cbbColumnName.Text) = -1 then
//        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adi giremezsiniz!', '#1', LngMsgError, LngSystem) );
      if cbbSummaryType.ItemIndex = -1 then
        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adi giremezsiniz!', '#1', LngMsgError, LngSystem) );

      TSysGridColSummary(Table).TableName1.Value := cbbTableName.Text;
      TSysGridColSummary(Table).ColumnName.Value := cbbColumnName.Text;
      TSysGridColSummary(Table).SumaryType.Value := cbbSummaryType.ItemIndex;
      TSysGridColSummary(Table).Format.Value := edtFormat.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
