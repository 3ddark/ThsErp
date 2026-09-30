unit ufrmAccBanks;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccBank.Service, AccBank, ufrmAccBank;

type
  TfrmAccBanks = class(TfrmGrid<TAccBank, TAccBankService>)
  private
    FmniBranches: TMenuItem;
    procedure mniBranchesClick(Sender: TObject);
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
  ufrmAccBankBranches, AccBankBranch, AccBankBranch.Service;                    // TfrmAccBankBranches

function TfrmAccBanks.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccBank.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccBank.Create(Self, Service, TAccBank.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccBank.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccBanks.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniBranches := AddMenu(TLocalizationManager.Translate(TLangKeys.TAccBank.MenuBranches, 'Branches'), 'mniBranches', mniBranchesClick);
end;

procedure TfrmAccBanks.mniBranchesClick(Sender: TObject);
var
  LFrm: TfrmAccBankBranches;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmAccBankBranches.Create(Self, TAccBankBranchService.Create, TAccBankBranch.Create);
  LFrm.SetFixedBank(Table.Id, Table.BankName);
  LFrm.Show;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccBanks.SetSelectedItem;

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
end;

procedure TfrmAccBanks.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmAccBanks.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccBanks.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.TitlePlural, 'Banks');
  if Assigned(FmniBranches) then
    FmniBranches.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.MenuBranches, 'Branches');
  SetColumnTitle('bank_name', TLocalizationManager.Translate(TLangKeys.TAccBank.ColBankName, 'Bank Name'));
  SetColumnTitle('swift_code', TLocalizationManager.Translate(TLangKeys.TAccBank.ColSwiftCode, 'Swift Code'));
end;

end.
