unit ufrmSetEinvTasimaUcretleri;

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
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid, System.Actions, Vcl.ActnList;

type
  TfrmSetEinvTasimaUcretleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  ufrmSetEinvTasimaUcreti,
  Ths.Erp.Database.Table.SetEinvTasimaUcreti;

{$R *.dfm}

function TfrmSetEinvTasimaUcretleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetEinvTasimaUcreti.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetEinvTasimaUcreti.Create(Self, Self, TSetEinvTasimaUcreti.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetEinvTasimaUcreti.Create(Self, Self, Table.Clone(), pFormMode);
end;

end.
