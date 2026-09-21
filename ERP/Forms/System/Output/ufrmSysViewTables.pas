unit ufrmSysViewTables;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Comp.Client,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysViewTable.Service, SysViewTable;

type
  TfrmSysViewTables = class(TfrmGrid<TSysViewTable, TSysViewTableService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
    procedure SetSelectedItem; override;
  end;

implementation

{$R *.dfm}

function TfrmSysViewTables.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

procedure TfrmSysViewTables.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',           50, TLocalizationManager.Translate(TLangKeys.TSysViewTable.ColId, 'Id'));
  SetColumnProperty('table_name',  250, TLocalizationManager.Translate(TLangKeys.TSysViewTable.ColTableName, 'Table Name'));
  SetColumnProperty('table_type',  100, TLocalizationManager.Translate(TLangKeys.TSysViewTable.ColTableType, 'Type'));
end;

procedure TfrmSysViewTables.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysViewTables.FormShow(Sender: TObject);
begin
  if Assigned(Qry) and not Qry.Active then
  begin
    if Pos('table_type', Qry.SQL.Text) = 0 then
      Qry.SQL.Text := Qry.SQL.Text + ' AND table_type = ''VIEW'' ';
  end;
  inherited;
  if Assigned(BtnAdd) then
    BtnAdd.Visible := False;
  ApplyLocalization;
end;

procedure TfrmSysViewTables.SetSelectedItem;
begin
  inherited;
  Table.TableName := Grd.DataSource.DataSet.FieldByName('table_name').AsString;
  Table.TableType := Grd.DataSource.DataSet.FieldByName('table_type').AsString;
end;

procedure TfrmSysViewTables.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysViewTable.TitlePlural, 'System View Tables');
  SetColumnTitle('id',         TLocalizationManager.Translate(TLangKeys.TSysViewTable.ColId, 'Id'));
  SetColumnTitle('table_name', TLocalizationManager.Translate(TLangKeys.TSysViewTable.ColTableName, 'Table Name'));
  SetColumnTitle('table_type', TLocalizationManager.Translate(TLangKeys.TSysViewTable.ColTableType, 'Type'));
end;

end.
