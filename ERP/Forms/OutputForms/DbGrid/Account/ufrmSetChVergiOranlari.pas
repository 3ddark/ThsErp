﻿unit ufrmSetChVergiOranlari;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB, ufrmBase, ufrmBaseDBGrid,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmSetChVergiOranlari = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  public
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table, ufrmSetChVergiOrani, Ths.Database.Table.SetChVergiOranlari;

{$R *.dfm}

function TfrmSetChVergiOranlari.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetChVergiOrani.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetChVergiOrani.Create(Application, Self, TSetChVergiOrani.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetChVergiOrani.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSetChVergiOranlari.FormShow(Sender: TObject);
begin
  inherited;
  if grd.DataSource.DataSet.RecordCount > 0 then
    setDisplayFormatInteger(TSetChVergiOrani(Table).VergiOrani.FieldName, '0.00%', grd.DataSource.DataSet);
end;

end.

