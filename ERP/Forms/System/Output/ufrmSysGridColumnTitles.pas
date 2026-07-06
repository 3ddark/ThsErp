unit ufrmSysGridColumnTitles;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysGridColumnTitle.Service, SysGridColumnTitle, ufrmSysGridColumnTitle;

type
  TfrmSysGridColumnTitles = class(TfrmGrid<TSysGridColumnTitle, TSysGridColumnTitleService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysGridColumnTitles.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGridColumnTitle.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridColumnTitle.Create(Self, Service, TSysGridColumnTitle.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridColumnTitle.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridColumnTitles.DefineFooterColumns;
begin
  inherited;
//
end;

procedure TfrmSysGridColumnTitles.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Grid Column Titles';
end;

end.
