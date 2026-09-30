unit ufrmAccRegion;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccRegion.Service, AccRegion;

type
  TfrmAccRegion = class(TfrmInputSimpleDB<TAccRegion, TAccRegionService>)
    pnlContent: TPanel;
    lblName: TLabel;
    edtName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccRegion.BtnAcceptClick(Sender: TObject);
begin
  Table.Name := edtName.Text;
  inherited;
end;

procedure TfrmAccRegion.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtName.thsInputDataType := itString;
  edtName.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmAccRegion.FormShow(Sender: TObject);
begin
  inherited;
  if edtName.CanFocus then
    edtName.SetFocus;
end;

procedure TfrmAccRegion.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccRegion.TitleSingular, 'Account Region');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TAccRegion.ColName, 'Region Name');
end;

procedure TfrmAccRegion.RefreshData;
begin
  inherited;
  edtName.Text := Table.Name;
end;

end.
