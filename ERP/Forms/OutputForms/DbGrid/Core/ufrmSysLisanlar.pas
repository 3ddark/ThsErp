unit ufrmSysLisanlar;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB, ufrmBase, ufrmBaseDBGrid, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmSysLisanlar = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Constants,
  ufrmSysLisan,
  Ths.Database.Table.SysLisanlar;

{$R *.dfm}

function TfrmSysLisanlar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysLisan.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysLisan.Create(Self, Self, TSysLisan.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysLisan.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysLisanlar.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
end;

end.
