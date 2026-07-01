unit ufrmStkInventory;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB, ufrmBase, ufrmBaseDBGrid,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmStkInventory = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals, Ths.Constants, Ths.Database.Table, ufrmStkKart,
  Ths.Database.Table.StkInventory;

{$R *.dfm}

function TfrmStkInventory.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmStkKart.Create(Application, Self, Table.Clone, pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmStkKart.Create(Application, Self, TStkInventory.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmStkKart.Create(Application, Self, Table.Clone, pFormMode);
end;

procedure TfrmStkInventory.FormShow(Sender: TObject);
var
  LFmt: string;
  LHane: Integer;
begin
  inherited;
  LHane := GSysOndalikHane.StokMiktar.Value;
  LFmt := '#' + FormatSettings.DecimalSeparator + StringOfChar('#', LHane) + '0' + FormatSettings.ThousandSeparator + StringOfChar('0', LHane);

  setDisplayFormatFloat(TStkInventory(Table).AlisFiyat.FieldName, LFmt, grd.DataSource.DataSet);
  setDisplayFormatFloat(TStkInventory(Table).SatisFiyat.FieldName, LFmt, grd.DataSource.DataSet);
  setDisplayFormatFloat(TStkInventory(Table).IhracFiyat.FieldName, LFmt, grd.DataSource.DataSet);
  setDisplayFormatFloat(TStkInventory(Table).OrtalamaMaliyet.FieldName, LFmt, grd.DataSource.DataSet);
  setDisplayFormatFloat(TStkInventory(Table).EnAzStokSeviyesi.FieldName, LFmt, grd.DataSource.DataSet);
end;

end.

