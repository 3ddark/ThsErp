unit ufrmSysLisanGuiIcerik;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Database.Table,
  Ths.Database.Table.SysLisanlar,
  Ths.Database.Table.View.SysViewTables;

type
  TfrmSysLisanGuiIcerik = class(TfrmBaseInputDB)
    cbblang: TComboBox;
    lbllang: TLabel;
    lblcode: TLabel;
    edtcode: TEdit;
    lblvalue: TLabel;
    edtvalue: TEdit;
    lblcontent_type: TLabel;
    edtcontent_type: TEdit;
    lbltable_name: TLabel;
    cbbtable_name: TComboBox;
    lblform_name: TLabel;
    edtform_name: TEdit;
    lblis_factory: TLabel;
    chkis_factory: TCheckBox;
  private
    FSysLang: TSysLisan;
    FSysViewTables: TSysViewTables;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormShow(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure RefreshData();override;
    procedure Repaint; override;
  end;

implementation

uses
  Ths.Database.Table.SysLisanGuiIcerikler, Ths.Globals;

{$R *.dfm}

procedure TfrmSysLisanGuiIcerik.FormCreate(Sender: TObject);
begin
  inherited;

  cbblang.CharCase := ecNormal;
  edtcode.CharCase := ecNormal;
  edtvalue.CharCase := ecNormal;
  edtcontent_type.CharCase := ecNormal;
  cbbtable_name.CharCase := ecNormal;
  edtform_name.CharCase := ecNormal;

  FSysLang := TSysLisan.Create(GDatabase);
  FSysViewTables := TSysViewTables.Create(GDatabase);

  fillComboBoxData(cbblang, FSysLang, [FSysLang.Lisan.FieldName], '');
  fillComboBoxData(cbbtable_name, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
end;

procedure TfrmSysLisanGuiIcerik.FormDestroy(Sender: TObject);
begin
  FSysLang.Free;
  FSysViewTables.Free;
  inherited;
end;

procedure TfrmSysLisanGuiIcerik.FormShow(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysLisanGuiIcerik.RefreshData();
begin
  inherited;

  if FormViewMode = ivmSort then
  begin
    lblcontent_type.Visible := False;
    edtcontent_type.Visible := False;
    lbltable_name.Visible := False;
    cbbtable_name.Visible := False;
    lblis_factory.Visible := False;
    chkis_factory.Visible := False;
    lblform_name.Visible := False;
    edtform_name.Visible := False;
    Height := 200;

    if edtvalue.Visible then
      edtvalue.SetFocus;
  end
  else
  if FormViewMode = ivmNormal then
  begin
    lblcontent_type.Visible := True;
    edtcontent_type.Visible := True;
    lbltable_name.Visible := True;
    cbbtable_name.Visible := True;
    lblis_factory.Visible := True;
    chkis_factory.Visible := True;
    lblform_name.Visible := True;
    edtform_name.Visible := True;
    Height := 290;
  end;

  if cbbtable_name.Items.IndexOf( TSysLisanGuiIcerik(Table).TabloAdi.Value ) = -1 then
    cbbtable_name.Items.Add( TSysLisanGuiIcerik(Table).TabloAdi.Value );
  if TSysLisanGuiIcerik(Table).TabloAdi.Value <> '' then
    cbbtable_name.ItemIndex := cbbtable_name.Items.IndexOf( TSysLisanGuiIcerik(Table).TabloAdi.Value );

  if TSysLisanGuiIcerik(Table).Lisan.Value <> '' then
    cbblang.ItemIndex := cbblang.Items.IndexOf( TSysLisanGuiIcerik(Table).Lisan.Value );
end;

procedure TfrmSysLisanGuiIcerik.Repaint;
begin
  inherited;
end;

procedure TfrmSysLisanGuiIcerik.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysLisanGuiIcerik(Table).Lisan.Value := cbblang.Text;
      TSysLisanGuiIcerik(Table).Kod.Value := edtcode.Text;
      TSysLisanGuiIcerik(Table).IcerikTipi.Value := edtcontent_type.Text;
      TSysLisanGuiIcerik(Table).TabloAdi.Value := cbbtable_name.Text;
      TSysLisanGuiIcerik(Table).Deger.Value := edtvalue.Text;
      TSysLisanGuiIcerik(Table).IsFabrika.Value := chkis_factory.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
