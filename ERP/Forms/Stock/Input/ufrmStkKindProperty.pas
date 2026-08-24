unit ufrmStkKindProperty;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkKindProperty.Service, StkKindProperty, LocalizationManager;

type
  TfrmStkKindProperty = class(TfrmInputSimpleDB<TStkKindProperty, TStkKindPropertyService>)
    pgcMain: TPageControl;
    tsGenel: TTabSheet;
    lblkind: TLabel;
    edtkind: TEdit;
    lbldescription: TLabel;
    edtDescription: TEdit;
    lbls1: TLabel;
    edtS1: TEdit;
    lbls2: TLabel;
    edtS2: TEdit;
    lbls3: TLabel;
    edtS3: TEdit;
    lbls4: TLabel;
    edtS4: TEdit;
    lbls5: TLabel;
    edtS5: TEdit;
    lbls6: TLabel;
    edtS6: TEdit;
    lbls7: TLabel;
    edtS7: TEdit;
    lbls8: TLabel;
    edtS8: TEdit;
    lbls9: TLabel;
    edtS9: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure BtnAcceptClick(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkKindProperty.BtnAcceptClick(Sender: TObject);
begin
  Table.Kind := edtkind.Text;
  Table.Desciption := edtDescription.Text;
  Table.S1 := edtS1.Text;
  Table.S2 := edtS2.Text;
  Table.S3 := edtS3.Text;
  Table.S4 := edtS4.Text;
  Table.S5 := edtS5.Text;
  Table.S6 := edtS6.Text;
  Table.S7 := edtS7.Text;
  Table.S8 := edtS8.Text;
  Table.S9 := edtS9.Text;
  inherited;
end;

procedure TfrmStkKindProperty.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkKindProperty.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtkind.SetFocus;
end;

procedure TfrmStkKindProperty.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_kind_property.title_singular', 'Stok Cins Özelliği');
  lblkind.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_kind', 'Cins');
  lbldescription.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_description', 'Açıklama');
  lbls1.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_s1', 'S1');
  lbls2.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_s2', 'S2');
  lbls3.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_s3', 'S3');
  lbls4.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_s4', 'S4');
  lbls5.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_s5', 'S5');
  lbls6.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_s6', 'S6');
  lbls7.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_s7', 'S7');
  lbls8.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_s8', 'S8');
  lbls9.Caption := TLocalizationManager.Translate('stk_kind_property.lbl_s9', 'S9');
end;

procedure TfrmStkKindProperty.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkKindProperty.RefreshData;
begin
  inherited;
  edtkind.Text := Table.Kind;
  edtDescription.Text := Table.Desciption;
  edtS1.Text := Table.S1;
  edtS2.Text := Table.S2;
  edtS3.Text := Table.S3;
  edtS4.Text := Table.S4;
  edtS5.Text := Table.S5;
  edtS6.Text := Table.S6;
  edtS7.Text := Table.S7;
  edtS8.Text := Table.S8;
  edtS9.Text := Table.S9;
end;

end.
