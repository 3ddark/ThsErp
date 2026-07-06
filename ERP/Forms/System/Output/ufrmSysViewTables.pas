unit ufrmSysViewTables;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysViewTable.Service, SysViewTable;


type
  TfrmSysViewTables = class(TfrmGrid<TSysViewTable, TSysViewTableService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysViewTables.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

procedure TfrmSysViewTables.DefineColumnWidths;
begin
  SetColumnProperty('id',           50, 'Id');
  SetColumnProperty('table_name',  200, 'Table Name');
  SetColumnProperty('table_type',   80, 'Type');
end;

procedure TfrmSysViewTables.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysViewTables.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System View Tables';
end;

end.
