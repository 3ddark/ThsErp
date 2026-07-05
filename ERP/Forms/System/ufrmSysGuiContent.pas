unit ufrmSysGuiContent;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, System.Generics.Collections,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  ufrmBase, ufrmInputSimpleDB, SharedFormTypes, SysGuiContent, SysGuiContent.Service,
  SysViewTable, SysViewTable.Service;

type
  TfrmSysGuiContent = class(TfrmInputSimpleDB<TSysGuiContent, TSysGuiContentService>)
    lblCode: TLabel;
    edtCode: TEdit;
    lblContent: TLabel;
    edtContent: TEdit;
    lblContentType: TLabel;
    edtContentType: TEdit;
    lblTableName: TLabel;
    cbbTableName: TComboBox;
    lblFormName: TLabel;
    edtFormName: TEdit;
    lblIsFactory: TLabel;
    chkIsFactory: TCheckBox;
  private
    FSysViewTable: TList<TSysViewTable>;
    FSysViewTableSvc: TSysViewTableService;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure InitializeInputCase; override;
    procedure RefreshData(); override;
  end;

implementation

uses
  Ths.Globals;

{$R *.dfm}

procedure TfrmSysGuiContent.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;

  edtCode.CharCase := ecNormal;
  edtContent.CharCase := ecNormal;
  edtContentType.CharCase := ecNormal;
  cbbTableName.CharCase := ecNormal;
  edtFormName.CharCase := ecNormal;

  FSysViewTableSvc := TSysViewTableService.Create;
  FSysViewTable := FSysViewTableSvc.Find(nil, False);
  for n1 := 0 to FSysViewTable.Count-1 do
    cbbTableName.AddItem(FSysViewTable.Items[n1].TableName, FSysViewTable.Items[n1]);
end;

procedure TfrmSysGuiContent.FormDestroy(Sender: TObject);
begin
  FSysViewTable.Free;
  inherited;
end;

procedure TfrmSysGuiContent.InitializeInputCase;
begin
  inherited;
  edtCode.thsInputDataType := itString;
  edtContent.thsInputDataType := itString;
  edtContentType.thsInputDataType := itString;
  edtFormName.thsInputDataType := itString;
end;

procedure TfrmSysGuiContent.FormShow(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysGuiContent.RefreshData();
begin
  inherited;

  if FormViewMode = ivmSort then
  begin
    lblContentType.Visible := False;
    edtContentType.Visible := False;
    lblTableName.Visible := False;
    cbbTableName.Visible := False;
    lblIsFactory.Visible := False;
    chkIsFactory.Visible := False;
    lblFormName.Visible := False;
    edtFormName.Visible := False;
    Height := 200;

    if edtContent.Visible then
      edtContent.SetFocus;
  end
  else if FormViewMode = ivmNormal then
  begin
    lblContentType.Visible := True;
    edtContentType.Visible := True;
    lblTableName.Visible := True;
    cbbTableName.Visible := True;
    lblIsFactory.Visible := True;
    chkIsFactory.Visible := True;
    lblFormName.Visible := True;
    edtFormName.Visible := True;
    Height := 290;
  end;

  if cbbTableName.Items.IndexOf(Table.TableName) = -1 then
    cbbTableName.Items.Add(Table.TableName);
  if Table.TableName <> '' then
    cbbTableName.ItemIndex := cbbTableName.Items.IndexOf(Table.TableName);
end;

procedure TfrmSysGuiContent.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      Table.Code := edtCode.Text;
      Table.ContentType := edtContentType.Text;
      Table.TableName := cbbTableName.Text;
      Table.Content := edtContent.Text;
      Table.IsFactory := chkIsFactory.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
