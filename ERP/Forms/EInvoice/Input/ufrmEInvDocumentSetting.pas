unit ufrmEInvDocumentSetting;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvDocumentSetting.Service, EInvDocumentSetting;

type
  TfrmEInvDocumentSetting = class(TfrmInputSimpleDB<TEInvDocumentSetting, TEInvDocumentSettingService>)
    pnlContent: TPanel;
    lblSeriesScope: TLabel;
    cbbSeriesScope: TComboBox;
    lblEinvSeriesId: TLabel;
    edtEinvSeriesId: TEdit;
    lblSysApiServiceId: TLabel;
    edtSysApiServiceId: TEdit;
    lblSenderAlias: TLabel;
    edtSenderAlias: TEdit;
    lblReceiverAlias: TLabel;
    edtReceiverAlias: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    procedure cbbSeriesScopeChange(Sender: TObject);
    procedure ApplyAliasState;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup,
  EInvSeries, EInvSeries.Service, ufrmEInvSeriesList,
  SysApiService, SysApiService.Service, ufrmSysApiServices;

procedure TfrmEInvDocumentSetting.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.SeriesScope := cbbSeriesScope.ItemIndex + 1;
  Table.SenderAlias := edtSenderAlias.Text;
  Table.ReceiverAlias := edtReceiverAlias.Text;
  inherited;
end;

procedure TfrmEInvDocumentSetting.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  TEInvLookup.FillItems(cbbSeriesScope.Items, elkSeriesScope);
  edtEinvSeriesId.OnHelperProcess := HelperProcess;
  edtSysApiServiceId.OnHelperProcess := HelperProcess;
  edtSenderAlias.thsInputDataType := itString;
  edtReceiverAlias.thsInputDataType := itString;
  cbbSeriesScope.OnChange := cbbSeriesScopeChange;
end;

procedure TfrmEInvDocumentSetting.FormShow(Sender: TObject);
begin
  inherited;
  if cbbSeriesScope.CanFocus then
    cbbSeriesScope.SetFocus;
end;

procedure TfrmEInvDocumentSetting.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.TitleSingular, 'e-Document Setting');
  lblSeriesScope.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColSeriesScope, 'Document Type');
  LIndex := cbbSeriesScope.ItemIndex;
  TEInvLookup.FillItems(cbbSeriesScope.Items, elkSeriesScope);
  cbbSeriesScope.ItemIndex := LIndex;
  lblEinvSeriesId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColEinvSeriesId, 'Series');
  lblSysApiServiceId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColSysApiServiceId, 'API Service');
  lblSenderAlias.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColSenderAlias, 'Sender Alias (GB)');
  lblReceiverAlias.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDocumentSetting.ColReceiverAlias, 'Receiver Alias (PK)');
end;

procedure TfrmEInvDocumentSetting.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmEinvSeriesId: TfrmEInvSeriesList;
  LFrmSysApiServiceId: TfrmSysApiServices;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtEinvSeriesId.Name then
  begin
    LFrmEinvSeriesId := TfrmEInvSeriesList.Create(LEdit, TEInvSeriesService.Create, TEInvSeries.Create);
    try
      LFrmEinvSeriesId.IsHelper := True;
      // yalnız seçili belge türünün aktif serileri
      LFrmEinvSeriesId.AddFixedFilter('is_active', True);
      if cbbSeriesScope.ItemIndex >= 0 then
        LFrmEinvSeriesId.AddFixedFilter('series_scope', cbbSeriesScope.ItemIndex + 1);
      LFrmEinvSeriesId.ShowModal;
      if LFrmEinvSeriesId.DataTransfer then
        if LFrmEinvSeriesId.CleanAndClose then
        begin
          Table.EinvSeriesId := 0;
          Table.SeriesCode := '';
          Table.SeriesName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EinvSeriesId := LFrmEinvSeriesId.Table.Id;
          Table.SeriesCode := LFrmEinvSeriesId.Table.Code;
          Table.SeriesName := LFrmEinvSeriesId.Table.Name;
          LEdit.Text := Table.SeriesCode;
        end;
    finally
      LFrmEinvSeriesId.Free;
    end;
  end
  else if LEdit.Name = edtSysApiServiceId.Name then
  begin
    LFrmSysApiServiceId := TfrmSysApiServices.Create(LEdit, TSysApiServiceService.Create, TSysApiService.Create);
    try
      LFrmSysApiServiceId.IsHelper := True;
      LFrmSysApiServiceId.AddFixedFilter('is_active', True);
      LFrmSysApiServiceId.ShowModal;
      if LFrmSysApiServiceId.DataTransfer then
        if LFrmSysApiServiceId.CleanAndClose then
        begin
          Table.SysApiServiceId := 0;
          Table.ServiceKind := '';
          Table.ProviderCode := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SysApiServiceId := LFrmSysApiServiceId.Table.Id;
          Table.ServiceKind := LFrmSysApiServiceId.Table.ServiceKind;
          Table.ProviderCode := LFrmSysApiServiceId.Table.ProviderCode;
          LEdit.Text := Table.ServiceKind;
        end;
    finally
      LFrmSysApiServiceId.Free;
    end;
  end;
end;

procedure TfrmEInvDocumentSetting.RefreshData;
begin
  inherited;
  cbbSeriesScope.ItemIndex := Table.SeriesScope - 1;
  edtEinvSeriesId.Text := Table.SeriesCode;
  edtSysApiServiceId.Text := Table.ServiceKind;
  edtSenderAlias.Text := Table.SenderAlias;
  edtReceiverAlias.Text := Table.ReceiverAlias;
  ApplyAliasState;
end;

procedure TfrmEInvDocumentSetting.cbbSeriesScopeChange(Sender: TObject);
begin
  ApplyAliasState;
end;

// e-Arşivde etiket yok (servis kayıtta boşaltır)
procedure TfrmEInvDocumentSetting.ApplyAliasState;
var
  LEnabled: Boolean;
begin
  LEnabled := cbbSeriesScope.ItemIndex + 1 <> EINV_SERIES_ARCHIVE;
  lblSenderAlias.Enabled := LEnabled;
  edtSenderAlias.Enabled := LEnabled;
  lblReceiverAlias.Enabled := LEnabled;
  edtReceiverAlias.Enabled := LEnabled;
end;

end.
