unit ufrmRctReceteler;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.Actions,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Dialogs,
  Vcl.ActnList,
  Data.DB,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid;

type
  TfrmRctReceteler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Table.RctRecete,
  ufrmRctReceteDetaylar;

{$R *.dfm}

function TfrmRctReceteler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmRctReceteDetaylar.Create(Application, Self, TRctRecete(Table.List[0]).Clone, pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmRctReceteDetaylar.Create(Application, Self, TRctRecete.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmRctReceteDetaylar.Create(Application, Self, TRctRecete(Table.List[0]).Clone, pFormMode);
end;

end.
