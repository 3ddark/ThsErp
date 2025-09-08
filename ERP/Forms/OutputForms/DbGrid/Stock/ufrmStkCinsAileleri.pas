unit ufrmStkCinsAileleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB,
  FireDAC.Phys.Intf, FireDAC.Stan.Option, FireDAC.Stan.Intf, FireDAC.Comp.Client,
  ufrmBase, ufrmBaseDBGrid, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.Actions, Vcl.ActnList;

type
  TfrmStkCinsAileleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  ufrmStkCinsAilesi, StkKindFamilyService, StkKindFamily;

{$R *.dfm}

function TfrmStkCinsAileleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmStkCinsAilesi.Create(Application, Self, Table.Clone(), pFormMode)
//  else if (pFormMode = ifmNewRecord) then
//    Result := TfrmStkCinsAilesi.Create(Application, Self, TStkCinsAile.Create, pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmStkCinsAilesi.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.

