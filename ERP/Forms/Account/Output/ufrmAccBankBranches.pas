unit ufrmAccBankBranches;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccBankBranch.Service, AccBankBranch, ufrmAccBankBranch;

type
  TfrmAccBankBranches = class(TfrmGrid<TAccBankBranch, TAccBankBranchService>)
  private
    FFixedBankId: Int64;
    FFixedBankName: string;
  public
    procedure SetFixedBank(ABankId: Int64; const ABankName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccBankBranches.SetFixedBank(ABankId: Int64; const ABankName: string);
begin
  FFixedBankId := ABankId;
  FFixedBankName := ABankName;
  AddFixedFilter('acc_bank_id', ABankId);
end;

function TfrmAccBankBranches.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TAccBankBranch;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccBankBranch.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TAccBankBranch.Create;
    if FFixedBankId > 0 then
    begin
      LNew.AccBankId := FFixedBankId;
      LNew.BankName := FFixedBankName;
    end;
    Result := TfrmAccBankBranch.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccBankBranch.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccBankBranches.SetSelectedItem;

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
  Table.BankName := FieldText('bank_name');
  Table.CityName := FieldText('city_name');
end;

procedure TfrmAccBankBranches.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_bank_id', 0);
  SetColumnProperty('sys_city_id', 0);
end;

procedure TfrmAccBankBranches.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccBankBranches.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccBankBranch.TitlePlural, 'Bank Branches');
  if FFixedBankName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedBankName;
  SetColumnTitle('bank_name', TLocalizationManager.Translate(TLangKeys.TAccBankBranch.ColBank, 'Bank'));
  SetColumnTitle('branch_code', TLocalizationManager.Translate(TLangKeys.TAccBankBranch.ColBranchCode, 'Branch Code'));
  SetColumnTitle('branch_name', TLocalizationManager.Translate(TLangKeys.TAccBankBranch.ColBranchName, 'Branch Name'));
  SetColumnTitle('city_name', TLocalizationManager.Translate(TLangKeys.TAccBankBranch.ColCity, 'City'));
end;

end.
