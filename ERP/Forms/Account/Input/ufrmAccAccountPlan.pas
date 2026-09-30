unit ufrmAccAccountPlan;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccAccountPlan.Service, AccAccountPlan;

type
  TfrmAccAccountPlan = class(TfrmInputSimpleDB<TAccAccountPlan, TAccAccountPlanService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblLevel: TLabel;
    edtLevel: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccAccountPlan.BtnAcceptClick(Sender: TObject);
begin
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.Level := StrToIntDef(edtLevel.Text, 0);
  inherited;
end;

procedure TfrmAccAccountPlan.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  edtName.CharCase := TEditCharCase.ecUpperCase;
  edtLevel.thsInputDataType := itInteger;
end;

procedure TfrmAccAccountPlan.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmAccAccountPlan.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountPlan.TitleSingular, 'Account Plan');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountPlan.ColCode, 'Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountPlan.ColName, 'Name');
  lblLevel.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountPlan.ColLevel, 'Level');
end;

procedure TfrmAccAccountPlan.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  edtLevel.Text := IntToStr(Table.Level);
end;

end.
