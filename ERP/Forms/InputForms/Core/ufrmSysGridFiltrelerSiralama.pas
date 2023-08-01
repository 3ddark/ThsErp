unit ufrmSysGridFiltrelerSiralama;

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
  Ths.Database.Table.View.SysViewTables;

type
  TfrmSysGridFilterSort = class(TfrmBaseInputDB)
    lbltable_name: TLabel;
    cbbtable_name: TComboBox;
    lblcontent: TLabel;
    edtcontent: TEdit;
    lblis_sort: TLabel;
    chkis_sort: TCheckBox;
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
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SysGridFiltrelerSiralamalar;

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

  cbbtable_name.CharCase := ecNormal;
  edtcontent.CharCase := ecNormal;

  FSysViewTables := TSysViewTables.Create(Table.Database);
  fillComboBoxData(cbbtable_name, FSysViewTables, [FSysViewTables.TableName1.FieldName], '');
end;

procedure TfrmSysGridFilterSort.FormShow(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmSysGridFilterSort.RefreshData();
begin
  cbbtable_name.ItemIndex := cbbtable_name.Items.IndexOf(TSysGridFiltreSiralama(Table).TabloAdi.AsString);
  edtcontent.Text := TSysGridFiltreSiralama(Table).Icerik.AsString;
  chkis_sort.Checked := TSysGridFiltreSiralama(Table).IsSiralama.AsBoolean;
end;

procedure TfrmSysGridFilterSort.Repaint;
begin
  cbbtable_name.CharCase := ecNormal;
  edtcontent.CharCase := ecNormal;
  inherited;
end;

procedure TfrmSysGridFilterSort.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if cbbtable_name.Items.IndexOf(cbbtable_name.Text) = -1 then
        raise Exception.Create('Listede olmayan bir Tablo Adý giremezsiniz!' + AddLBs + cbbtable_name.Text );

      TSysGridFiltreSiralama(Table).TabloAdi.Value := cbbtable_name.Text;
      TSysGridFiltreSiralama(Table).Icerik.Value := edtcontent.Text;
      TSysGridFiltreSiralama(Table).IsSiralama.Value := chkis_sort.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
