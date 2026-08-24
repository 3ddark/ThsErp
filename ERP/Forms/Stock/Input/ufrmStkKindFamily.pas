unit ufrmStkKindFamily;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkKindFamily.Service, StkKindFamily, LocalizationManager;

type
  TfrmStkKindFamily = class(TfrmInputSimpleDB<TStkKindFamily, TStkKindFamilyService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblaile: TLabel;
    edtfamily: TEdit;
    lbldescription: TLabel;
    lblactive: TLabel;
    mmodescription: TMemo;
    chkactive: TCheckBox;
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

procedure TfrmStkKindFamily.BtnAcceptClick(Sender: TObject);
begin
  Table.Family := edtfamily.Text;
  Table.Description := mmodescription.Lines.Text;
  Table.Active := chkactive.Checked;
  inherited;
end;

procedure TfrmStkKindFamily.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkKindFamily.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtfamily.SetFocus;
end;

procedure TfrmStkKindFamily.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_kind_family.title_singular', 'Stok Cins Ailesi');
  lblaile.Caption := TLocalizationManager.Translate('stk_kind_family.lbl_family', 'Cins Ailesi');
  lbldescription.Caption := TLocalizationManager.Translate('stk_kind_family.lbl_description', 'Açıklama');
  lblactive.Caption := TLocalizationManager.Translate('stk_kind_family.lbl_active', 'Aktif');
end;

procedure TfrmStkKindFamily.InitializeInputCase;
begin
  inherited;
  mmodescription.CharCase := TEditCharCase.ecNormal;
end;

procedure TfrmStkKindFamily.RefreshData;
begin
  inherited;
  edtfamily.Text := Table.Family;
  mmodescription.Lines.Text := Table.Description;
  chkactive.Checked := Table.Active;
end;

end.
