unit ufrmPrsPersoneller;

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
  TfrmPrsPersoneller = class(TfrmBaseDBGrid)
    procedure mniPrintClick(Sender: TObject);
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  ufrmPrsPersonel,
  Ths.Erp.Database.Table.PrsPersonel,
  Ths.Erp.Constants;

{$R *.dfm}

function TfrmPrsPersoneller.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmPrsPersonel.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmPrsPersonel.Create(Self, Self, TPrsPersonel.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmPrsPersonel.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmPrsPersoneller.mniPrintClick(Sender: TObject);
var
  vComp: TComponent;
  n1: Integer;
begin
  inherited;
  frxdbdtstBase.DataSource := Table.QueryOfDS.DataSource;
  frxdbdtstBase.DataSet := Table.QueryOfDS;

  frxrprtBase.EnabledDataSets.Add(frxdbdtstBase);

  for n1 := 0 to grd.Columns.Count-1 do
  begin
    vComp := frxrprtBase.FindComponent(PRX_MEMO + grd.Columns.Items[n1].FieldName);
    if Assigned(vComp) then
      TfrxMemoView(vComp).DataField := grd.Columns.Items[n1].FieldName;
  end;

  frxrprtBase.ShowReport();
end;

end.

