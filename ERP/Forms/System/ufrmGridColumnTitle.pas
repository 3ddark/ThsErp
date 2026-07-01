unit ufrmGridColumnTitle;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  GridColumnTitle.Service, GridColumnTitle;

type
  TfrmGridColumnTitle = class(TfrmInputSimpleDB<TGridColumnTitle, TGridColumnTitleService>)
    pnlContent: TPanel;
    lbltable_name: TLabel;
    lblcolumn_name: TLabel;
    llblng_code: TLabel;
    lblcolumn_label: TLabel;
    edttable_name: TEdit;
    edtcolumn_name: TEdit;
    edtlng_code: TEdit;
    edtcolumn_label: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmGridColumnTitle.BtnAcceptClick(Sender: TObject);
begin
  Table.TableName := edttable_name.Text;
  Table.ColumnName := edtcolumn_name.Text;
  Table.LngCode := edtlng_code.Text;
  Table.ColumnLabel := edtcolumn_label.Text;
  inherited;
end;

procedure TfrmGridColumnTitle.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmGridColumnTitle.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'Grid Column Title';

  edttable_name.SetFocus;
end;

procedure TfrmGridColumnTitle.InitializeInputCase;
begin
  inherited;
  edttable_name.thsInputDataType := itString;
  edttable_name.MaxLength := 64;
  edtcolumn_name.thsInputDataType := itString;
  edtcolumn_name.MaxLength := 64;
  edtlng_code.thsInputDataType := itString;
  edtlng_code.MaxLength := 2;
  edtcolumn_label.thsInputDataType := itString;
  edtcolumn_label.MaxLength := 64;
end;

procedure TfrmGridColumnTitle.RefreshData;
begin
  inherited;
  edttable_name.Text := Table.TableName;
  edtcolumn_name.Text := Table.ColumnName;
  edtlng_code.Text := Table.LngCode;
  edtcolumn_label.Text := Table.ColumnLabel;
end;

end.
