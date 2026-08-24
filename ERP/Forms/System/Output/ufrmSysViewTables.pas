unit ufrmSysViewTables;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysViewTable.Service, SysViewTable, LocalizationManager;


type
  TfrmSysViewTables = class(TfrmGrid<TSysViewTable, TSysViewTableService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
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
  SetColumnProperty('id',           50, TLocalizationManager.Translate('sys_view_tables.col_id', 'Id'));
  SetColumnProperty('table_name',  200, TLocalizationManager.Translate('sys_view_tables.col_table_name', 'Table Name'));
  SetColumnProperty('table_type',   80, TLocalizationManager.Translate('sys_view_tables.col_table_type', 'Type'));
end;

procedure TfrmSysViewTables.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysViewTables.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysViewTables.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_view_tables.title_plural', 'System View Tables');
end;

end.
