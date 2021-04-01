unit ufrmSysMultiLangDataTableList;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , System.StrUtils
  , System.Math
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.ComCtrls
  , Vcl.AppEvnts
  , Vcl.Menus
  , Vcl.Samples.Spin

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.Memo
  , Ths.Erp.Helper.ComboBox

  , ufrmBase
  , ufrmBaseInputDB

  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.SysMultiLangDataTableList
  ;

type
  TfrmSysMultiLangDataTableList = class(TfrmBaseInputDB)
    edttable_name: TEdit;
    lbltable_name: TLabel;
  published
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  end;

implementation

uses
    Ths.Erp.Globals
  ;

{$R *.dfm}

procedure TfrmSysMultiLangDataTableList.FormCreate(Sender: TObject);
begin
  inherited;
  edttable_name.CharCase := ecNormal;
end;

procedure TfrmSysMultiLangDataTableList.RefreshData();
begin
  //control içeriðini table class ile doldur
  edttable_name.Text := FormatedVariantVal(TSysMultiLangDataTableList(Table).TableName1.DataType, TSysMultiLangDataTableList(Table).TableName1.Value);
end;

procedure TfrmSysMultiLangDataTableList.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysMultiLangDataTableList(Table).TableName1.Value := edttable_name.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
