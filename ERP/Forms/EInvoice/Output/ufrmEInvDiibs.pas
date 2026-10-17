unit ufrmEInvDiibs;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvDiib.Service, EInvDiib, ufrmEInvDiib;

type
  TfrmEInvDiibs = class(TfrmGrid<TEInvDiib, TEInvDiibService>)
  private
    FmniLines: TMenuItem;
    procedure mniLinesClick(Sender: TObject);
    procedure HolderTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup,
  ufrmEInvDiibLines, EInvDiibLine, EInvDiibLine.Service;

procedure TfrmEInvDiibs.HolderTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEInvLookup.Text(elkDiibHolder, Sender.AsInteger);
end;
procedure TfrmEInvDiibs.mniLinesClick(Sender: TObject);
var
  LFrm: TfrmEInvDiibLines;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmEInvDiibLines.Create(Self, TEInvDiibLineService.Create, TEInvDiibLine.Create);
  LFrm.SetFixedDiib(Table.Id, Table.DocumentNo);
  LFrm.Show;
end;

procedure TfrmEInvDiibs.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniLines := AddMenu(TLocalizationManager.Translate(TLangKeys.TEInvDiib.MenuLines, 'DIIB Lines'), 'mniLines', mniLinesClick);
end;

function TfrmEInvDiibs.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvDiib.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvDiib.Create(Self, Service, TEInvDiib.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvDiib.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvDiibs.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
end;

procedure TfrmEInvDiibs.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('holder_type');
  if Assigned(LField) then
    LField.OnGetText := HolderTypeGetText;
end;

procedure TfrmEInvDiibs.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvDiibs.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.TitlePlural, 'DIIB Certificates');
  SetColumnTitle('document_no', TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColDocumentNo, 'DIIB No'));
  SetColumnTitle('holder_type', TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColHolderType, 'Certificate Holder'));
  SetColumnTitle('issue_date', TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColIssueDate, 'Issue Date'));
  SetColumnTitle('valid_until', TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColValidUntil, 'Valid Until'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColDescription, 'Description'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColIsActive, 'Active'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColAccountCode, 'Account Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColAccountName, 'Customer / Exporter'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColLineCount, 'Line Count'));
  if Assigned(FmniLines) then
    FmniLines.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.MenuLines, 'DIIB Lines');
end;

end.
