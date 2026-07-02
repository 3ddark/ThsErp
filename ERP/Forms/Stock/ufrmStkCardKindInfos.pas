unit ufrmStkCardKindInfos;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkCardKindInfoService, StkCardKindInfo, ufrmStkCardKindInfo;

type
  TfrmStkCardKindInfos = class(TfrmGrid<TStkCardKindInfo, TStkCardKindInfoService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmStkCardKindInfos.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkCardKindInfo.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkCardKindInfo.Create(Self, Service, TStkCardKindInfo.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkCardKindInfo.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkCardKindInfos.DefineColumnWidths;
begin
  SetColumnProperty('id',              0, 'Id');
  SetColumnProperty('card_id',         80, 'Card Id');
  SetColumnProperty('kind_id',         60, 'Kind Id');
  SetColumnProperty('s1',             70, 'S1');
  SetColumnProperty('s2',             70, 'S2');
  SetColumnProperty('s3',             70, 'S3');
  SetColumnProperty('s4',             70, 'S4');
  SetColumnProperty('s5',             70, 'S5');
  SetColumnProperty('s6',             70, 'S6');
  SetColumnProperty('s7',             70, 'S7');
  SetColumnProperty('s8',             70, 'S8');
  SetColumnProperty('s9',             70, 'S9');
  SetColumnProperty('s10',            70, 'S10');
end;

procedure TfrmStkCardKindInfos.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkCardKindInfos.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Stock Card Kind Infos';
end;

end.
