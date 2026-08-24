unit ufrmAccBankBranch;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,
  AccBankBranch.Service, AccBankBranch, ufrmAccBanks, AccBank.Service, AccBank,
  ufrmSysCities, SysCity.Service, SysCity, LocalizationManager;

type
  TfrmAccBankBranch = class(TfrmInputSimpleDB<TAccBankBranch, TAccBankBranchService>)
    pnlContent: TPanel;
    lblsube_kodu: TLabel;
    edtsube_kodu: TEdit;
    lblsube_adi: TLabel;
    edtsube_adi: TEdit;
    lblbanka: TLabel;
    edtbanka_adi: TEdit;
    lblsehir: TLabel;
    edtsehir_adi: TEdit;
  published
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

procedure TfrmAccBankBranch.BtnAcceptClick(Sender: TObject);
begin
  Table.Code := StrToIntDef(edtsube_kodu.Text, 0);
  Table.Name := edtsube_adi.Text;
  inherited;
end;

procedure TfrmAccBankBranch.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtbanka_adi.OnHelperProcess := HelperProcess;
  edtsehir_adi.OnHelperProcess := HelperProcess;
end;

procedure TfrmAccBankBranch.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtsube_kodu.SetFocus;
end;

procedure TfrmAccBankBranch.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('acc_bank_branch.title_singular', 'Banka Şubesi');
  lblsube_kodu.Caption := TLocalizationManager.Translate('acc_bank_branch.lbl_code', 'Şube Kodu');
  lblsube_adi.Caption := TLocalizationManager.Translate('acc_bank_branch.lbl_name', 'Şube Adı');
  lblbanka.Caption := TLocalizationManager.Translate('acc_bank_branch.lbl_bank', 'Banka');
  lblsehir.Caption := TLocalizationManager.Translate('acc_bank_branch.lbl_city', 'Şehir');
end;

procedure TfrmAccBankBranch.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmBanks: TfrmAccBanks;
  LFrmCities: TfrmSysCities;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtbanka_adi.Name then
    begin
      LFrmBanks := TfrmAccBanks.Create(LEdit, TAccBankService.Create, TAccBank.Create);
      try
        LFrmBanks.IsHelper := True;
        LFrmBanks.ShowModal;
        if LFrmBanks.DataTransfer then
        begin
          if LFrmBanks.CleanAndClose then
          begin
            Table.BankId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.BankId := LFrmBanks.Table.Id;
            LEdit.Text := LFrmBanks.Table.Name;
          end;
        end;
      finally
        LFrmBanks.Free;
      end;
    end
    else if LEdit.Name = edtsehir_adi.Name then
    begin
      LFrmCities := TfrmSysCities.Create(LEdit, TSysCityService.Create, TSysCity.Create);
      try
        LFrmCities.IsHelper := True;
        LFrmCities.ShowModal;
        if LFrmCities.DataTransfer then
        begin
          if LFrmCities.CleanAndClose then
          begin
            Table.CityId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.CityId := LFrmCities.Table.Id;
            LEdit.Text := LFrmCities.Table.CityName;
          end;
        end;
      finally
        LFrmCities.Free;
      end;
    end;
  end;
end;

procedure TfrmAccBankBranch.RefreshData;
var
  LBankService: TAccBankService;
  LCityService: TSysCityService;
  LBank: TAccBank;
  LCity: TSysCity;
begin
  inherited;
  edtsube_kodu.Text := IntToStr(Table.Code);
  edtsube_adi.Text := Table.Name;

  if Table.BankId > 0 then
  begin
    LBankService := TAccBankService.Create;
    try
      LBank := LBankService.FindById(Table.BankId, False);
      if Assigned(LBank) then
      begin
        edtbanka_adi.Text := LBank.Name;
        LBank.Free;
      end;
    finally
      LBankService.Free;
    end;
  end
  else
    edtbanka_adi.Text := '';

  if Table.CityId > 0 then
  begin
    LCityService := TSysCityService.Create;
    try
      LCity := LCityService.FindById(Table.CityId, False);
      if Assigned(LCity) then
      begin
        edtsehir_adi.Text := LCity.CityName;
        LCity.Free;
      end;
    finally
      LCityService.Free;
    end;
  end
  else
    edtsehir_adi.Text := '';
end;

end.
