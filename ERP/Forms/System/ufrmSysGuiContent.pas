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
    lblkod: TLabel;
    edtkod: TEdit;
    lbldeger: TLabel;
    edtdeger: TEdit;
    lblicerik_tipi: TLabel;
    edticerik_tipi: TEdit;
    lbltablo_adi: TLabel;
    cbbtablo_adi: TComboBox;
    lblform_adi: TLabel;
    edtform_adi: TEdit;
    lblis_fabrika: TLabel;
    chkis_fabrika: TCheckBox;
  private

    FSysViewTable: TList<TSysViewTable>;
    FSysViewTableSvc: TSysViewTableService;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
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

  edtkod.CharCase := ecNormal;
  edtdeger.CharCase := ecNormal;
  edticerik_tipi.CharCase := ecNormal;
  cbbtablo_adi.CharCase := ecNormal;
  edtform_adi.CharCase := ecNormal;

  FSysViewTableSvc := TSysViewTableService.Create;
  FSysViewTable := FSysViewTableSvc.Find(nil, False);
  for n1 := 0 to FSysViewTable.Count-1 do
    cbbtablo_adi.AddItem(FSysViewTable.Items[n1].TableName, FSysViewTable.Items[n1]);
end;

procedure TfrmSysGuiContent.FormDestroy(Sender: TObject);
begin
  FSysViewTable.Free;
  inherited;
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
    lblicerik_tipi.Visible := False;
    edticerik_tipi.Visible := False;
    lbltablo_adi.Visible := False;
    cbbtablo_adi.Visible := False;
    lblis_fabrika.Visible := False;
    chkis_fabrika.Visible := False;
    lblform_adi.Visible := False;
    edtform_adi.Visible := False;
    Height := 200;

    if edtdeger.Visible then
      edtdeger.SetFocus;
  end
  else if FormViewMode = ivmNormal then
  begin
    lblicerik_tipi.Visible := True;
    edticerik_tipi.Visible := True;
    lbltablo_adi.Visible := True;
    cbbtablo_adi.Visible := True;
    lblis_fabrika.Visible := True;
    chkis_fabrika.Visible := True;
    lblform_adi.Visible := True;
    edtform_adi.Visible := True;
    Height := 290;
  end;

  if cbbtablo_adi.Items.IndexOf(Table.TableName) = -1 then
    cbbtablo_adi.Items.Add(Table.TableName);
  if Table.TableName <> '' then
    cbbtablo_adi.ItemIndex := cbbtablo_adi.Items.IndexOf(Table.TableName);
end;

procedure TfrmSysGuiContent.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      Table.Code := edtkod.Text;
      Table.ContentType := edticerik_tipi.Text;
      Table.TableName := cbbtablo_adi.Text;
      Table.Content := edtdeger.Text;
      Table.IsFactory := chkis_fabrika.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
