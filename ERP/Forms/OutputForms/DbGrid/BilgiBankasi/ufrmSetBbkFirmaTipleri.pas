unit ufrmSetBbkFirmaTipleri;

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
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, System.Actions,
  Vcl.ActnList, FireDAC.Comp.DataSet;

type
  TfrmSetBbkFirmaTipleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  ufrmSetBbkFirmaTipi,
  Ths.Erp.Database.Table.SetBbkFirmaTipi;

{$R *.dfm}

function TfrmSetBbkFirmaTipleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetBbkFirmaTipi.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetBbkFirmaTipi.Create(Application, Self, TSetBbkFirmaTipi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetBbkFirmaTipi.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
