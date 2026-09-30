unit ufrmAccGroup;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccGroup.Service, AccGroup;

type
  TfrmAccGroup = class(TfrmInputSimpleDB<TAccGroup, TAccGroupService>)
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

procedure TfrmAccGroup.BtnAcceptClick(Sender: TObject);
begin
  Table.Name := edtName.Text;
  inherited;
end;

procedure TfrmAccGroup.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtName.thsInputDataType := itString;
  edtName.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmAccGroup.FormShow(Sender: TObject);
begin
  inherited;
  if edtName.CanFocus then
    edtName.SetFocus;
end;

procedure TfrmAccGroup.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccGroup.TitleSingular, 'Account Group');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TAccGroup.ColName, 'Group Name');
end;

procedure TfrmAccGroup.RefreshData;
begin
  inherited;
  edtName.Text := Table.Name;
end;

end.
