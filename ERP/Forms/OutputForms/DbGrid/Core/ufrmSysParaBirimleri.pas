unit ufrmSysParaBirimleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.DBGrids,
  Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB, System.Actions, Vcl.ActnList,
  ufrmBase, ufrmBaseDBGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf;

type
  TfrmSysParaBirimleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses ufrmSysParaBirimi, Ths.Database.Table.SysParaBirimleri;


{$R *.dfm}

function TfrmSysParaBirimleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysParaBirimi.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysParaBirimi.Create(Self, Self, TSysParaBirimi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysParaBirimi.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysParaBirimleri.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
end;

end.
