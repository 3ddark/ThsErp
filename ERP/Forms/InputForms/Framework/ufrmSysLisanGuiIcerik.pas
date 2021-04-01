unit ufrmSysLisanGuiIcerik;

interface

{$I ThsERP.inc}

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
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysLisan,
  Ths.Erp.Database.Table.View.SysViewTables;

type
  TfrmSysLisanGuiIcerik = class(TfrmBaseInputDB)
    cbblisan: TComboBox;
    lbllisan: TLabel;
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
    lblis_fabrika_ayari: TLabel;
    chkis_fabrika_ayari: TCheckBox;
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
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysLisanGuiIcerik;

{$R *.dfm}

procedure TfrmSysLisanGuiIcerik.FormCreate(Sender: TObject);
begin
  inherited;

  cbblisan.CharCase := ecNormal;
  edtkod.CharCase := ecNormal;
  edtdeger.CharCase := ecNormal;
  edticerik_tipi.CharCase := ecNormal;
  cbbtablo_adi.CharCase := ecNormal;
  edtform_adi.CharCase := ecNormal;

  FSysLang := TSysLisan.Create(Table.Database);
  FSysViewTables := TSysViewTables.Create(Table.Database);

  fillComboBoxData(cbblisan, FSysLang, [FSysLang.Lisan.FieldName], '');
  fillComboBoxData(cbbtablo_adi, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
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
    lblicerik_tipi.Visible := False;
    edticerik_tipi.Visible := False;
    lbltablo_adi.Visible := False;
    cbbtablo_adi.Visible := False;
    lblis_fabrika_ayari.Visible := False;
    chkis_fabrika_ayari.Visible := False;
    lblform_adi.Visible := False;
    edtform_adi.Visible := False;
    Height := 200;

    if edtdeger.Visible then
      edtdeger.SetFocus;
  end
  else
  if FormViewMode = ivmNormal then
  begin
    lblicerik_tipi.Visible := True;
    edticerik_tipi.Visible := True;
    lbltablo_adi.Visible := True;
    cbbtablo_adi.Visible := True;
    lblis_fabrika_ayari.Visible := True;
    chkis_fabrika_ayari.Visible := True;
    lblform_adi.Visible := True;
    edtform_adi.Visible := True;
    Height := 290;
  end;

  if cbbtablo_adi.Items.IndexOf( TSysLisanGuiIcerik(Table).TabloAdi.Value ) = -1 then
    cbbtablo_adi.Items.Add( TSysLisanGuiIcerik(Table).TabloAdi.Value );
  if TSysLisanGuiIcerik(Table).TabloAdi.Value <> '' then
    cbbtablo_adi.ItemIndex := cbbtablo_adi.Items.IndexOf( TSysLisanGuiIcerik(Table).TabloAdi.Value );

  if TSysLisanGuiIcerik(Table).Lisan.Value <> '' then
    cbblisan.ItemIndex := cbblisan.Items.IndexOf( TSysLisanGuiIcerik(Table).Lisan.Value );
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
      TSysLisanGuiIcerik(Table).Lisan.Value := cbblisan.Text;
      TSysLisanGuiIcerik(Table).Kod.Value := edtkod.Text;
      TSysLisanGuiIcerik(Table).IcerikTipi.Value := edticerik_tipi.Text;
      TSysLisanGuiIcerik(Table).TabloAdi.Value := cbbtablo_adi.Text;
      TSysLisanGuiIcerik(Table).Deger.Value := edtdeger.Text;
      TSysLisanGuiIcerik(Table).IsFabrikaAyari.Value := chkis_fabrika_ayari.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
