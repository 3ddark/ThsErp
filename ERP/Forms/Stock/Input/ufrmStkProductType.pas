unit ufrmStkProductType;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkProductType.Service, StkProductType, LocalizationManager;

type
  TfrmStkProductType = class(TfrmInputSimpleDB<TStkProductType, TStkProductTypeService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblProductName: TLabel;
    edtProductName: TEdit;
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

procedure TfrmStkProductType.BtnAcceptClick(Sender: TObject);
begin
  Table.ProductTypeName := edtProductName.Text;
  inherited;
end;

procedure TfrmStkProductType.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkProductType.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtProductName.SetFocus;
end;

procedure TfrmStkProductType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_product_type.title_singular', 'Stok Ürün Tipi');
  lblProductName.Caption := TLocalizationManager.Translate('stk_product_type.lbl_product_type_name', 'Ürün Tipi Adı');
end;

procedure TfrmStkProductType.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkProductType.RefreshData;
begin
  inherited;
  edtProductName.Text := Table.ProductTypeName;
end;

end.
