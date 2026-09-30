unit ufrmAccBankBranch;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccBankBranch.Service, AccBankBranch;

type
  TfrmAccBankBranch = class(TfrmInputSimpleDB<TAccBankBranch, TAccBankBranchService>)
    pnlContent: TPanel;
    lblAccBankId: TLabel;
    edtAccBankId: TEdit;
    lblBranchCode: TLabel;
    edtBranchCode: TEdit;
    lblBranchName: TLabel;
    edtBranchName: TEdit;
    lblSysCityId: TLabel;
    edtSysCityId: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  AccBank, AccBank.Service, ufrmAccBanks,                                       // TfrmAccBanks helper output form
  SysCity, SysCity.Service, ufrmSysCities;                                      // TfrmSysCities helper output form

procedure TfrmAccBankBranch.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.BranchCode := StrToIntDef(edtBranchCode.Text, 0);
  Table.BranchName := edtBranchName.Text;
  inherited;
end;

procedure TfrmAccBankBranch.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtAccBankId.OnHelperProcess := HelperProcess;
  edtSysCityId.OnHelperProcess := HelperProcess;
  edtBranchCode.thsInputDataType := itInteger;
  edtBranchName.thsInputDataType := itString;
  edtBranchName.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmAccBankBranch.FormShow(Sender: TObject);
begin
  inherited;
  if edtBranchCode.CanFocus then
    edtBranchCode.SetFocus;
end;

procedure TfrmAccBankBranch.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccBankBranch.TitleSingular, 'Bank Branch');
  lblAccBankId.Caption := TLocalizationManager.Translate(TLangKeys.TAccBankBranch.ColBank, 'Bank');
  lblBranchCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccBankBranch.ColBranchCode, 'Branch Code');
  lblBranchName.Caption := TLocalizationManager.Translate(TLangKeys.TAccBankBranch.ColBranchName, 'Branch Name');
  lblSysCityId.Caption := TLocalizationManager.Translate(TLangKeys.TAccBankBranch.ColCity, 'City');
end;

procedure TfrmAccBankBranch.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccBankId: TfrmAccBanks;
  LFrmSysCityId: TfrmSysCities;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccBankId.Name then
  begin
    LFrmAccBankId := TfrmAccBanks.Create(LEdit, TAccBankService.Create, TAccBank.Create);
    try
      LFrmAccBankId.IsHelper := True;
      LFrmAccBankId.ShowModal;
      if LFrmAccBankId.DataTransfer then
        if LFrmAccBankId.CleanAndClose then
        begin
          Table.AccBankId := 0;
          Table.BankName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccBankId := LFrmAccBankId.Table.Id;
          Table.BankName := LFrmAccBankId.Table.BankName;
          LEdit.Text := Table.BankName;
        end;
    finally
      LFrmAccBankId.Free;
    end;
  end
  else if LEdit.Name = edtSysCityId.Name then
  begin
    LFrmSysCityId := TfrmSysCities.Create(LEdit, TSysCityService.Create, TSysCity.Create);
    try
      LFrmSysCityId.IsHelper := True;
      LFrmSysCityId.ShowModal;
      if LFrmSysCityId.DataTransfer then
        if LFrmSysCityId.CleanAndClose then
        begin
          Table.SysCityId := 0;
          Table.CityName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SysCityId := LFrmSysCityId.Table.Id;
          Table.CityName := LFrmSysCityId.Table.CityName;
          LEdit.Text := Table.CityName;
        end;
    finally
      LFrmSysCityId.Free;
    end;
  end;
end;

procedure TfrmAccBankBranch.RefreshData;
begin
  inherited;
  edtAccBankId.Text := Table.BankName;
  edtBranchCode.Text := IntToStr(Table.BranchCode);
  edtBranchName.Text := Table.BranchName;
  edtSysCityId.Text := Table.CityName;
end;

end.
