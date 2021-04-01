unit ufrmStkStokKartlari;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Dialogs,
  Data.DB,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.Actions, Vcl.ActnList;

type
  TfrmStkStokKartlari = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table,
  ufrmStkStokKarti,
  Ths.Erp.Database.Table.StkStokKarti;

{$R *.dfm}

function TfrmStkStokKartlari.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmStkStokKarti.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmStkStokKarti.Create(Application, Self, TStkStokKarti.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmStkStokKarti.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmStkStokKartlari.FormShow(Sender: TObject);
var
  LFmt: string;
  LHane: Integer;
begin
  inherited;
  LHane := GSysOndalikHane.StokMiktar.Value;
  LFmt := '#' + FormatSettings.DecimalSeparator + StringOfChar('#', LHane) + '0' + FormatSettings.ThousandSeparator + StringOfChar('0', LHane);

  setDisplayFormatFloat(TStkStokKarti(Table).AlisFiyat.FieldName, LFmt, grd.DataSource.DataSet);
  setDisplayFormatFloat(TStkStokKarti(Table).SatisFiyat.FieldName, LFmt, grd.DataSource.DataSet);
  setDisplayFormatFloat(TStkStokKarti(Table).IhracFiyat.FieldName, LFmt, grd.DataSource.DataSet);
  setDisplayFormatFloat(TStkStokKarti(Table).OrtalamaMaliyet.FieldName, LFmt, grd.DataSource.DataSet);
  setDisplayFormatFloat(TStkStokKarti(Table).EnAzStokSeviyesi.FieldName, LFmt, grd.DataSource.DataSet);
end;

end.
