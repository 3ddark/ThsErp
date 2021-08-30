unit ufrmSysTables;

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
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Stan.Async,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.DatS,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid, System.Actions, Vcl.ActnList;

type
  TfrmSysTables = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Constants,
  Ths.Erp.Database.Table;

{$R *.dfm}

function TfrmSysTables.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

end.
