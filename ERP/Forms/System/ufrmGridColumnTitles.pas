unit ufrmGridColumnTitles;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, GridColumnTitle.Service, GridColumnTitle, ufrmGridColumnTitle;

type
  TfrmGridColumnTitles = class(TfrmGrid<TGridColumnTitle, TGridColumnTitleService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmGridColumnTitles.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmGridColumnTitle.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmGridColumnTitle.Create(Self, Service, TGridColumnTitle.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmGridColumnTitle.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmGridColumnTitles.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, 'Id');
  SetColumnProperty('table_name',    120, 'Table Name');
  SetColumnProperty('column_name',   100, 'Column Name');
  SetColumnProperty('lng_code',       70, 'Language Code');
  SetColumnProperty('column_label',  150, 'Column Label');
end;

procedure TfrmGridColumnTitles.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmGridColumnTitles.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Grid Column Titles';
end;

end.
