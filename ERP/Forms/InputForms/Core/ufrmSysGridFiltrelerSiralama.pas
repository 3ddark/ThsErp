unit ufrmSysGridFiltrelerSiralama;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.View.SysViewTables;

type
  TfrmSysGridFilterSort = class(TfrmBaseInputDB)
    lbltablo_adi: TLabel;
    cbbtablo_adi: TComboBox;
    lblicerik: TLabel;
    edticerik: TEdit;
    lblis_siralama: TLabel;
    chkis_siralama: TCheckBox;
  private
    FSysViewTables: TSysViewTables;
  public
    destructor Destroy; override;
    procedure Repaint; override;
  published
    procedure FormShow(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses Ths.Globals, Ths.Database.Table.SysGridFiltrelerSiralamalar;

{$R *.dfm}

destructor TfrmSysGridFilterSort.Destroy;
begin
  if Assigned(FSysViewTables) then
    FSysViewTables.Free;
  inherited;
end;

procedure TfrmSysGridFilterSort.FormCreate(Sender: TObject);
begin
  inherited;

  cbbtablo_adi.CharCase := ecNormal;
  edticerik.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(Table.Database);
  fillComboBoxData(cbbtablo_adi, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
end;

procedure TfrmSysGridFilterSort.FormShow(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysGridFilterSort.RefreshData();
begin
  cbbtablo_adi.ItemIndex := cbbtablo_adi.Items.IndexOf(TSysGridFiltreSiralama(Table).TabloAdi.AsString);
  edticerik.Text := TSysGridFiltreSiralama(Table).Icerik.AsString;
  chkis_siralama.Checked := TSysGridFiltreSiralama(Table).IsSiralama.AsBoolean;
end;

procedure TfrmSysGridFilterSort.Repaint;
begin
  cbbtablo_adi.CharCase := ecNormal;
  edticerik.CharCase := ecNormal;
  inherited;
end;

procedure TfrmSysGridFilterSort.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if cbbtablo_adi.Items.IndexOf(cbbtablo_adi.Text) = -1 then
        raise Exception.Create('Listede olmayan bir Tablo Adı giremezsiniz!' + AddLBs + cbbtablo_adi.Text);

      TSysGridFiltreSiralama(Table).TabloAdi.Value := cbbtablo_adi.Text;
      TSysGridFiltreSiralama(Table).Icerik.Value := edticerik.Text;
      TSysGridFiltreSiralama(Table).IsSiralama.Value := chkis_siralama.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
