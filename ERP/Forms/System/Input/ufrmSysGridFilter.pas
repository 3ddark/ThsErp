unit ufrmSysGridFilter;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB,  SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysGridFilter.Service, SysGridFilter,
  SysViewTable.Service, SysViewTable, ufrmSysViewTables;

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
    procedure HelperProcess(Sender: TObject);
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
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
  edtTableName.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysGridFilter.HelperProcess(Sender: TObject);
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

procedure TfrmSysGridFilter.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtTableName.SetFocus;
end;

procedure TfrmSysGridFilter.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.TitleSingular, 'Grid Filter');
  lblTableName.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColTableName, 'Table Name');
  lblFilterContent.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColFilterContent, 'Filter Content');
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
