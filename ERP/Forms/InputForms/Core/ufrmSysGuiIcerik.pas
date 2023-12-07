unit ufrmSysGuiIcerik;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB, Ths.Database.Table,
  Ths.Database.Table.View.SysViewTables;

type
  TfrmSysGuiIcerik = class(TfrmBaseInputDB)
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
    FSysViewTables: TSysViewTables;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure RefreshData(); override;
  end;

implementation

uses
  Ths.Database.Table.SysGuiIcerikler, Ths.Globals;

{$R *.dfm}

procedure TfrmSysGuiIcerik.FormCreate(Sender: TObject);
begin
  inherited;

  edtkod.CharCase := ecNormal;
  edtdeger.CharCase := ecNormal;
  edticerik_tipi.CharCase := ecNormal;
  cbbtablo_adi.CharCase := ecNormal;
  edtform_adi.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(GDatabase);

  fillComboBoxData(cbbtablo_adi, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
end;

procedure TfrmSysGuiIcerik.FormDestroy(Sender: TObject);
begin
  FSysViewTables.Free;
  inherited;
end;

procedure TfrmSysGuiIcerik.FormShow(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysGuiIcerik.RefreshData();
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

  if cbbtablo_adi.Items.IndexOf(TSysGuiIcerik(Table).TabloAdi.Value) = -1 then
    cbbtablo_adi.Items.Add(TSysGuiIcerik(Table).TabloAdi.Value);
  if TSysGuiIcerik(Table).TabloAdi.Value <> '' then
    cbbtablo_adi.ItemIndex := cbbtablo_adi.Items.IndexOf(TSysGuiIcerik(Table).TabloAdi.Value);
end;

procedure TfrmSysGuiIcerik.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysGuiIcerik(Table).Kod.Value := edtkod.Text;
      TSysGuiIcerik(Table).IcerikTipi.Value := edticerik_tipi.Text;
      TSysGuiIcerik(Table).TabloAdi.Value := cbbtablo_adi.Text;
      TSysGuiIcerik(Table).Deger.Value := edtdeger.Text;
      TSysGuiIcerik(Table).IsFabrika.Value := chkis_fabrika.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
