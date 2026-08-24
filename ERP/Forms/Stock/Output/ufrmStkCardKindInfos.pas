unit ufrmStkCardKindInfos;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkCardKindInfo.Service, StkCardKindInfo, ufrmStkCardKindInfo,
  LocalizationManager;

type
  TfrmStkCardKindInfos = class(TfrmGrid<TStkCardKindInfo, TStkCardKindInfoService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
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
  inherited;
  SetColumnProperty('id',          0, TLocalizationManager.Translate('stk_card_kind_info.col_id', 'Id'));
  SetColumnProperty('stk_kart_id', 80, TLocalizationManager.Translate('stk_card_kind_info.col_stk_kart_id', 'Card Id'));
  SetColumnProperty('cins_id',     60, TLocalizationManager.Translate('stk_card_kind_info.col_cins_id', 'Kind Id'));
  SetColumnProperty('deger',      150, TLocalizationManager.Translate('stk_card_kind_info.col_deger', 'Value'));
end;

procedure TfrmStkCardKindInfos.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkCardKindInfos.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkCardKindInfos.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_card_kind_info.title_plural', 'Stock Card Kind Infos');
end;

end.
