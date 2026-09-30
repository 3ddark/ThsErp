unit ufrmStkProductType;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  StkProductType.Service, StkProductType;

type
  TfrmStkProductType = class(TfrmInputSimpleDB<TStkProductType, TStkProductTypeService>)
    pnlContent: TPanel;
    lblProductTypeName: TLabel;
    edtProductTypeName: TEdit;
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

procedure TfrmStkProductType.BtnAcceptClick(Sender: TObject);
begin
  Table.ProductTypeName := edtProductTypeName.Text;
  Table.Description := edtDescription.Text;
  Table.Active := chkActive.Checked;
  inherited;
end;

procedure TfrmStkProductType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtProductTypeName.thsInputDataType := itString;
  edtProductTypeName.CharCase := TEditCharCase.ecUpperCase;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmStkProductType.FormShow(Sender: TObject);
begin
  inherited;
  if edtProductTypeName.CanFocus then
    edtProductTypeName.SetFocus;
end;

procedure TfrmStkProductType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkProductType.TitleSingular, 'Product Type');
  lblProductTypeName.Caption := TLocalizationManager.Translate(TLangKeys.TStkProductType.ColProductTypeName, 'Product Type');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TStkProductType.ColDescription, 'Description');
  lblActive.Caption := TLocalizationManager.Translate(TLangKeys.TStkProductType.ColActive, 'Active');
end;

procedure TfrmStkProductType.RefreshData;
begin
  inherited;
  edtProductTypeName.Text := Table.ProductTypeName;
  edtDescription.Text := Table.Description;
  chkActive.Checked := Table.Active;
end;

end.
