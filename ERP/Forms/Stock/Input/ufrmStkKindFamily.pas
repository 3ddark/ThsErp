unit ufrmStkKindFamily;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  StkKindFamily.Service, StkKindFamily;

type
  TfrmStkKindFamily = class(TfrmInputSimpleDB<TStkKindFamily, TStkKindFamilyService>)
    pnlContent: TPanel;
    lblFamily: TLabel;
    edtFamily: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblActive: TLabel;
    chkActive: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkKindFamily.BtnAcceptClick(Sender: TObject);
begin
  Table.Family := edtFamily.Text;
  Table.Description := edtDescription.Text;
  Table.Active := chkActive.Checked;
  inherited;
end;

procedure TfrmStkKindFamily.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtFamily.thsInputDataType := itString;
  edtFamily.CharCase := TEditCharCase.ecUpperCase;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmStkKindFamily.FormShow(Sender: TObject);
begin
  inherited;
  if edtFamily.CanFocus then
    edtFamily.SetFocus;
end;

procedure TfrmStkKindFamily.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindFamily.TitleSingular, 'Kind Family');
  lblFamily.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindFamily.ColFamily, 'Family');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindFamily.ColDescription, 'Description');
  lblActive.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindFamily.ColActive, 'Active');
end;

procedure TfrmStkKindFamily.RefreshData;
begin
  inherited;
  edtFamily.Text := Table.Family;
  edtDescription.Text := Table.Description;
  chkActive.Checked := Table.Active;
end;

end.
