unit ufrmSysLanguages;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysLanguage.Service, SysLanguage, ufrmSysLanguage;

type
  TfrmSysLanguages = class(TfrmGrid<TSysLanguage, TSysLanguageService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysLanguages.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysLanguage.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysLanguage.Create(Self, Service, TSysLanguage.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysLanguage.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysLanguages.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',            0, 'Id');
  SetColumnProperty('lng_code',     70, 'Language Code');
  SetColumnProperty('description', 250, 'Description');
end;

procedure TfrmSysLanguages.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('lng_code', atCount, '#,##0 " Lang"');
end;

procedure TfrmSysLanguages.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Languages';
end;

end.
