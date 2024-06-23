unit ufrmSysUlkeler;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.Actions, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Vcl.ActnList, Data.DB,
  ufrmBase, ufrmBaseDBGrid, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf;

type
  TfrmSysUlkeler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table, ufrmSysUlke, Ths.Database.Table.SysUlkeler;

{$R *.dfm}

function TfrmSysUlkeler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysUlke.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysUlke.Create(Self, Self, TSysUlke.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUlke.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysUlkeler.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
  setDisplayFormatInteger(TSysUlke(Table).ISOYear.FieldName, '', grd.DataSource.DataSet);
end;

end.
