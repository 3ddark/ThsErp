unit ufrmSysGridFilter;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysGridFilter.Service, SysGridFilter;

type
  TfrmSysGridFilter = class(TfrmInputSimpleDB<TSysGridFilter, TSysGridFilterService>)
    pnlContent: TPanel;
    lblTableName: TLabel;
    lblFilterContent: TLabel;
    edtTableName: TEdit;
    edtFilterContent: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysGridFilter.BtnAcceptClick(Sender: TObject);
begin
  Table.TableName := edtTableName.Text;
  Table.FilterContent := edtFilterContent.Text;
  inherited;
end;

procedure TfrmSysGridFilter.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysGridFilter.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Grid Filter';

  edtTableName.SetFocus;
end;

procedure TfrmSysGridFilter.InitializeInputCase;
begin
  inherited;
  edtTableName.thsInputDataType := itString;
  edtTableName.MaxLength := 32;
  edtFilterContent.thsInputDataType := itString;
end;

procedure TfrmSysGridFilter.RefreshData;
begin
  inherited;
  edtTableName.Text := Table.TableName;
  edtFilterContent.Text := Table.FilterContent;
end;

end.
