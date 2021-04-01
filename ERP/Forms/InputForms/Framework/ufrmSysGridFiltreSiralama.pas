unit ufrmSysGridFiltreSiralama;

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
  Ths.Erp.Database.Table.View.SysViewTables;

type
  TfrmSysGridFiltreSiralama = class(TfrmBaseInputDB)
    lbltablo_adi: TLabel;
    cbbtablo_adi: TComboBox;
    lbldeger: TLabel;
    edtdeger: TEdit;
    lblis_siralama: TLabel;
    chkis_siralama: TCheckBox;
  private
    FSysViewTables: TSysViewTables;
  public
    destructor Destroy; override;
    procedure Repaint; override;
  protected
  published
    procedure FormShow(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysGridFiltreSiralama;

{$R *.dfm}

destructor TfrmSysGridFiltreSiralama.Destroy;
begin
  if Assigned(FSysViewTables) then
    FSysViewTables.Free;
  inherited;
end;

procedure TfrmSysGridFiltreSiralama.FormCreate(Sender: TObject);
begin
  inherited;

  cbbtablo_adi.CharCase := ecNormal;
  edtdeger.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(Table.Database);
  fillComboBoxData(cbbtablo_adi, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
end;

procedure TfrmSysGridFiltreSiralama.FormShow(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmSysGridFiltreSiralama.RefreshData();
begin
  cbbtablo_adi.ItemIndex := cbbtablo_adi.Items.IndexOf(TSysGridFiltreSiralama(Table).TabloAdi.Value);
  edtdeger.Text := TSysGridFiltreSiralama(Table).Deger.Value;
  chkis_siralama.Checked := TSysGridFiltreSiralama(Table).IsSiralama.Value;
end;

procedure TfrmSysGridFiltreSiralama.Repaint;
begin
  cbbtablo_adi.CharCase := ecNormal;
  edtdeger.CharCase := ecNormal;
  inherited;
end;

procedure TfrmSysGridFiltreSiralama.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if cbbtablo_adi.Items.IndexOf(cbbtablo_adi.Text) = -1 then
        raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adý giremezsiniz!', '#1', LngMsgError, LngSystem) );

      btnAcceptAuto;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
