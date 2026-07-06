unit ufrmSysGridColumnTitle;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysGridColumnTitle.Service, SysGridColumnTitle;

type
  TfrmSysGridColumnTitle = class(TfrmInputSimpleDB<TSysGridColumnTitle, TSysGridColumnTitleService>)
    pnlContent: TPanel;
    lblTableName: TLabel;
    edtTableName: TEdit;
    lblColumnName: TLabel;
    edtColumnName: TEdit;
    lblLngCode: TLabel;
    edtLngCode: TEdit;
    lblColumnLabel: TLabel;
    edtColumnLabel: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysGridColumnTitle.BtnAcceptClick(Sender: TObject);
begin
  Table.TableName := edtTableName.Text;
  Table.ColumnName := edtColumnName.Text;
  Table.LngCode := edtLngCode.Text;
  Table.ColumnLabel := edtColumnLabel.Text;
  inherited;
end;

procedure TfrmSysGridColumnTitle.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysGridColumnTitle.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Grid Column Title';

  edtTableName.SetFocus;
end;

procedure TfrmSysGridColumnTitle.InitializeInputCase;
begin
  inherited;
  edtTableName.thsInputDataType := itString;
  edtTableName.MaxLength := 64;
  edtColumnName.thsInputDataType := itString;
  edtColumnName.MaxLength := 64;
  edtLngCode.thsInputDataType := itString;
  edtLngCode.MaxLength := 2;
  edtColumnLabel.thsInputDataType := itString;
  edtColumnLabel.MaxLength := 64;
end;

procedure TfrmSysGridColumnTitle.RefreshData;
begin
  inherited;
  edtTableName.Text := Table.TableName;
  edtColumnName.Text := Table.ColumnName;
  edtLngCode.Text := Table.LngCode;
  edtColumnLabel.Text := Table.ColumnLabel;
end;

end.
