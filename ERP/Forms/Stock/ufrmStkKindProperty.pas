unit ufrmStkKindProperty;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkKindPropertyService, StkKindProperty;

type
  TfrmStkKindProperty = class(TfrmInputSimpleDbX<TStkKindProperty, TStkKindPropertyService>)
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
    lbls10: TLabel;
    edtS10: TEdit;
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

procedure TfrmStkKindProperty.BtnAcceptClick(Sender: TObject);
begin
  Table.Kind.Value := edtkind.Text;
  Table.Desciption.Value := edtDescription.Text;
  Table.S1.Value := edtS1.Text;
  Table.S2.Value := edtS2.Text;
  Table.S3.Value := edtS3.Text;
  Table.S4.Value := edtS4.Text;
  Table.S5.Value := edtS5.Text;
  Table.S6.Value := edtS6.Text;
  Table.S7.Value := edtS7.Text;
  Table.S8.Value := edtS8.Text;
  Table.S9.Value := edtS9.Text;
  Table.S10.Value := edtS10.Text;
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
  Self.Caption := 'Input Stk Kind Property';
  edtkind.SetFocus;
end;

procedure TfrmStkKindProperty.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkKindProperty.RefreshData;
begin
  inherited;
  edtkind.Text := Table.Kind.Value;
  edtDescription.Text := Table.Desciption.Value;
  edtS1.Text := Table.S1.Value;
  edtS2.Text := Table.S2.Value;
  edtS3.Text := Table.S3.Value;
  edtS4.Text := Table.S4.Value;
  edtS5.Text := Table.S5.Value;
  edtS6.Text := Table.S6.Value;
  edtS7.Text := Table.S7.Value;
  edtS8.Text := Table.S8.Value;
  edtS9.Text := Table.S9.Value;
  edtS10.Text := Table.S10.Value;
end;

end.
