unit ufrmPrsPersoneller;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB, ufrmBase,
  ufrmBaseDBGrid, System.Actions, Vcl.ActnList, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmPrsPersoneller = class(TfrmBaseDBGrid)
    procedure FormShow(Sender: TObject); override;
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  ufrmPrsPersonel,
  Ths.Database.Table.PrsPersoneller,
  Ths.Constants;

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

procedure TfrmPrsPersoneller.FormShow(Sender: TObject);
begin
  inherited;
  mniprint.Visible := True;
end;

end.
