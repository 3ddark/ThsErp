unit ufrmSysGridSort;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysGridSort.Service, SysGridSort, LocalizationManager;

type
  TfrmSysGridSort = class(TfrmInputSimpleDB<TSysGridSort, TSysGridSortService>)
    pnlContent: TPanel;
    lblTableName: TLabel;
    lblSortContent: TLabel;
    edtTableName: TEdit;
    edtSortContent: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysGridSort.BtnAcceptClick(Sender: TObject);
begin
  Table.TableName := edtTableName.Text;
  Table.SortContent := edtSortContent.Text;
  inherited;
end;

procedure TfrmSysGridSort.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysGridSort.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtTableName.SetFocus;
end;

procedure TfrmSysGridSort.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_grid_sort.title_singular', 'Grid Sıralaması');
end;

procedure TfrmSysGridSort.InitializeInputCase;
begin
  inherited;
  edtTableName.thsInputDataType := itString;
  edtTableName.MaxLength := 32;
  edtSortContent.thsInputDataType := itString;
end;

procedure TfrmSysGridSort.RefreshData;
begin
  inherited;
  edtTableName.Text := Table.TableName;
  edtSortContent.Text := Table.SortContent;
end;

end.
