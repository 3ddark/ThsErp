unit ufrmSetBbkCalismaDurumlari;

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
  TfrmSetBbkCalismaDurumlari = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  ufrmSetBbkCalismaDurumu,
  Ths.Erp.Database.Table.SetBbkCalismaDurumu;

{$R *.dfm}

function TfrmSetBbkCalismaDurumlari.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetBbkCalismaDurumu.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetBbkCalismaDurumu.Create(Application, Self, TSetBbkCalismaDurumu.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetBbkCalismaDurumu.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
