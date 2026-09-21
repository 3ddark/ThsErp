unit ufrmSysGridSort;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysGridSort.Service, SysGridSort,
  SysViewTable.Service, SysViewTable, ufrmSysViewTables;

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
    procedure HelperProcess(Sender: TObject);
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
  edtTableName.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysGridSort.HelperProcess(Sender: TObject);
var
  LFrmViewTables: TfrmSysViewTables;
begin
  if Sender = edtTableName then
  begin
    LFrmViewTables := TfrmSysViewTables.Create(edtTableName, TSysViewTableService.Create, TSysViewTable.Create);
    try
      LFrmViewTables.IsHelper := True;
      LFrmViewTables.ShowModal;
      if LFrmViewTables.DataTransfer then
      begin
        if LFrmViewTables.CleanAndClose then
        begin
          Table.TableName := '';
          edtTableName.Clear;
        end
        else
        begin
          Table.TableName := LFrmViewTables.Table.TableName;
          edtTableName.Text := LFrmViewTables.Table.TableName;
        end;
      end;
    finally
      LFrmViewTables.Free;
    end;
  end;
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
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.TitleSingular, 'Grid Sort');
  lblTableName.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.ColTableName, 'Table Name');
  lblSortContent.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.ColSortContent, 'Sort Content');
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
