unit ufrmStkProductType;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkProductTypeService, StkProductType;

type
  TfrmStkProductType = class(TfrmInputSimpleDbX<TStkProductType, TStkProductTypeService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblProductName: TLabel;
    edtProductName: TEdit;
    lbldescription: TLabel;
    edtDescription: TEdit;
    lblactive: TLabel;
    chkActive: TCheckBox;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  published
    procedure BtnAcceptClick(Sender: TObject); override;

  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkProductType.BtnAcceptClick(Sender: TObject);
begin
  Table.ProductTypeName.Value := edtProductName.Text;
  Table.Description.Value := edtDescription.Text;
  Table.Active.Value := chkActive.Checked;
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
  Self.Caption := 'Input Stk Product Type';
  edtProductName.SetFocus;
end;

procedure TfrmStkProductType.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkProductType.RefreshData;
begin
  inherited;
  edtProductName.Text := Table.ProductTypeName.Value;
  edtDescription.Text := Table.Description.Value;
  chkActive.Checked := Table.Active.Value;
end;

end.
