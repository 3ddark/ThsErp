unit ufrmSysOlcuBirimleri;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Types, System.Classes, System.Math, System.UITypes, System.Rtti,
  System.Actions, Vcl.Menus, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.AppEvnts, Vcl.StdCtrls,
  Vcl.Samples.Spin, Vcl.Clipbrd, Vcl.ActnList, Data.DB, Ths.Helper.BaseTypes,
  Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox, udm, ufrmBase,
  ufrmBaseDBGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf;

type
  TfrmSysOlcuBirimleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  ufrmSysOlcuBirimi, Ths.Database.Table.SysOlcuBirimleri;

{$R *.dfm}

function TfrmSysOlcuBirimleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysOlcuBirimi.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysOlcuBirimi.Create(Application, Self, TSysOlcuBirimi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysOlcuBirimi.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysOlcuBirimleri.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
end;

end.

