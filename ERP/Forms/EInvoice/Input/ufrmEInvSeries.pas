unit ufrmEInvSeries;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvSeries.Service, EInvSeries;

type
  TfrmEInvSeries = class(TfrmInputSimpleDB<TEInvSeries, TEInvSeriesService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblSeriesScope: TLabel;
    cbbSeriesScope: TComboBox;
    lblIsDefault: TLabel;
    chkIsDefault: TCheckBox;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup;

procedure TfrmEInvSeries.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.SeriesScope := cbbSeriesScope.ItemIndex + 1;
  Table.IsDefault := chkIsDefault.Checked;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvSeries.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  TEInvLookup.FillItems(cbbSeriesScope.Items, elkSeriesScope);
end;

procedure TfrmEInvSeries.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmEInvSeries.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvSeries.TitleSingular, 'e-Document Series');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColCode, 'Series Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColName, 'Name');
  lblSeriesScope.Caption := TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColSeriesScope, 'Used For');
  LIndex := cbbSeriesScope.ItemIndex;
  TEInvLookup.FillItems(cbbSeriesScope.Items, elkSeriesScope);
  cbbSeriesScope.ItemIndex := LIndex;
  lblIsDefault.Caption := TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColIsDefault, 'Default Series');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColIsActive, 'Active');
end;

procedure TfrmEInvSeries.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  cbbSeriesScope.ItemIndex := Table.SeriesScope - 1;
  chkIsDefault.Checked := Table.IsDefault;
  chkIsActive.Checked := Table.IsActive;
end;

end.
