unit ufrmSysGridColumn;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager, AppContext,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysGridColumn.Service, SysGridColumn;

type
  TfrmSysGridColumn = class(TfrmInputSimpleDB<TSysGridColumn, TSysGridColumnService>)
    pnlContent: TPanel;
    lblTableName: TLabel;
    edtTableName: TEdit;
    lblColumnName: TLabel;
    edtColumnName: TEdit;
    lblColumnOrder: TLabel;
    edtColumnOrder: TEdit;
    lblColumnWidth: TLabel;
    edtColumnWidth: TEdit;
    lblDataFormat: TLabel;
    edtDataFormat: TEdit;
    chkIsShow: TCheckBox;
    chkIsShowHelper: TCheckBox;
    chkIsFetch: TCheckBox;
    lblMinValue: TLabel;
    edtMinValue: TEdit;
    lblMinValueColor: TLabel;
    edtMinValueColor: TEdit;
    lblMaxValue: TLabel;
    edtMaxValue: TEdit;
    lblMaxValueColor: TLabel;
    edtMaxValueColor: TEdit;
    lblMaxValuePercent: TLabel;
    edtMaxValuePercent: TEdit;
    lblBarColor: TLabel;
    edtBarColor: TEdit;
    lblBarBgColor: TLabel;
    edtBarBkColor: TEdit;
    lblBarTextColor: TLabel;
    edtBarTextColor: TEdit;
    lblAggregateType: TLabel;
    cbbAggregateType: TComboBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysGridColumn.BtnAcceptClick(Sender: TObject);
begin
  Table.TableName := edtTableName.Text;
  Table.ColumnName := edtColumnName.Text;
  Table.ColumnOrder := StrToIntDef(edtColumnOrder.Text, 1);
  Table.ColumnWidth := StrToIntDef(edtColumnWidth.Text, 0);
  Table.DataFormat := edtDataFormat.Text;
  Table.IsShow := chkIsShow.Checked;
  Table.IsShowHelper := chkIsShowHelper.Checked;
  if Assigned(chkIsFetch) then
    Table.IsFetch := chkIsFetch.Checked;
  Table.MinValue := StrToFloatDef(edtMinValue.Text, 0);
  Table.MinValueColor := StrToIntDef(edtMinValueColor.Text, 0);
  Table.MaxValue := StrToFloatDef(edtMaxValue.Text, 0);
  Table.MaxValueColor := StrToIntDef(edtMaxValueColor.Text, 0);
  Table.MaxValuePercent := StrToFloatDef(edtMaxValuePercent.Text, 0);
  Table.BarColor := StrToIntDef(edtBarColor.Text, 0);
  Table.BarBgColor := StrToIntDef(edtBarBkColor.Text, 0);
  Table.BarTextColor := StrToIntDef(edtBarTextColor.Text, 0);
  if Assigned(cbbAggregateType) and (cbbAggregateType.ItemIndex >= 0) then
    Table.AggregateType := cbbAggregateType.ItemIndex
  else
    Table.AggregateType := 0;
  inherited;
end;

procedure TfrmSysGridColumn.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;

  lblAggregateType := TLabel.Create(Self);
  lblAggregateType.Parent := pnlContent;
  lblAggregateType.Left := 11;
  lblAggregateType.Top := 208;
  lblAggregateType.Width := 77;
  lblAggregateType.Height := 13;
  lblAggregateType.Alignment := taRightJustify;
  lblAggregateType.Font.Name := 'Tahoma';
  lblAggregateType.Font.Size := 8;
  lblAggregateType.Font.Style := [fsBold];
  lblAggregateType.Caption := 'Aggregate Type';

  cbbAggregateType := TComboBox.Create(Self);
  cbbAggregateType.Parent := pnlContent;
  cbbAggregateType.Left := 94;
  cbbAggregateType.Top := 204;
  cbbAggregateType.Width := 200;
  cbbAggregateType.Height := 23;
  cbbAggregateType.Style := csDropDownList;
  cbbAggregateType.TabOrder := 15;
end;

procedure TfrmSysGridColumn.FormShow(Sender: TObject);
var
  LIsAdminOrManager: Boolean;
begin
  inherited;
  ApplyLocalization;

  LIsAdminOrManager := (TAppContext.Instance.CurrentUser <> nil) and
                       (TAppContext.Instance.CurrentUser.User <> nil) and
                       (TAppContext.Instance.CurrentUser.User.SuperUser or TAppContext.Instance.CurrentUser.User.Manager);

  if Assigned(chkIsFetch) then
    chkIsFetch.Enabled := LIsAdminOrManager;

  edtTableName.SetFocus;
end;

procedure TfrmSysGridColumn.ApplyLocalization;
var
  LPrevIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.TitleSingular, 'Grid Column Setting');

  lblTableName.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColTableName, 'Table Name');
  lblColumnName.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColColumnName, 'Column Name');
  lblColumnOrder.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColColumnOrder, 'Column Order');
  lblColumnWidth.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColColumnWidth, 'Column Width');
  lblDataFormat.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColDataFormat, 'Data Format');
  chkIsShow.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColIsShow, 'Show');
  chkIsShowHelper.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColIsShowHelper, 'Show in Helper');
  if Assigned(chkIsFetch) then
    chkIsFetch.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColIsFetch, 'Fetch');

  lblMinValue.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColMinValue, 'Min Value');
  lblMinValueColor.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColMinValueColor, 'Min Value Color');
  lblMaxValue.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColMaxValue, 'Max Value');
  lblMaxValueColor.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColMaxValueColor, 'Max Value Color');
  lblMaxValuePercent.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColMaxValuePercent, 'Max Value Percent');
  lblBarColor.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColBarColor, 'Bar Color');
  lblBarBgColor.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColBarBkColor, 'Bar Background Color');
  lblBarTextColor.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColBarTextColor, 'Bar Text Color');

  if Assigned(lblAggregateType) then
    lblAggregateType.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColAggregateType, 'Aggregate Type');

  if Assigned(cbbAggregateType) then
  begin
    LPrevIndex := cbbAggregateType.ItemIndex;
    cbbAggregateType.Items.BeginUpdate;
    try
      cbbAggregateType.Items.Clear;
      cbbAggregateType.Items.Add(TLocalizationManager.Translate(TLangKeys.TAggregateType.None, 'None'));
      cbbAggregateType.Items.Add(TLocalizationManager.Translate(TLangKeys.TAggregateType.Sum, 'Sum'));
      cbbAggregateType.Items.Add(TLocalizationManager.Translate(TLangKeys.TAggregateType.Count, 'Count'));
      cbbAggregateType.Items.Add(TLocalizationManager.Translate(TLangKeys.TAggregateType.Average, 'Average'));
      cbbAggregateType.Items.Add(TLocalizationManager.Translate(TLangKeys.TAggregateType.Min, 'Min'));
      cbbAggregateType.Items.Add(TLocalizationManager.Translate(TLangKeys.TAggregateType.Max, 'Max'));
    finally
      cbbAggregateType.Items.EndUpdate;
    end;
    if (LPrevIndex >= 0) and (LPrevIndex < cbbAggregateType.Items.Count) then
      cbbAggregateType.ItemIndex := LPrevIndex
    else
      cbbAggregateType.ItemIndex := 0;
  end;
end;

procedure TfrmSysGridColumn.InitializeInputCase;
begin
  inherited;
  edtTableName.thsInputDataType := itString;
  edtTableName.MaxLength := 128;
  edtColumnName.thsInputDataType := itString;
  edtColumnName.MaxLength := 128;
  edtColumnOrder.thsInputDataType := itInteger;
  edtColumnWidth.thsInputDataType := itInteger;
  edtDataFormat.thsInputDataType := itString;
  edtDataFormat.MaxLength := 16;
  edtMinValue.thsInputDataType := itFloat;
  edtMinValueColor.thsInputDataType := itInteger;
  edtMaxValue.thsInputDataType := itFloat;
  edtMaxValueColor.thsInputDataType := itInteger;
  edtMaxValuePercent.thsInputDataType := itFloat;
  edtBarColor.thsInputDataType := itInteger;
  edtBarBkColor.thsInputDataType := itInteger;
  edtBarTextColor.thsInputDataType := itInteger;
end;

procedure TfrmSysGridColumn.RefreshData;
begin
  inherited;
  edtTableName.Text := Table.TableName;
  edtColumnName.Text := Table.ColumnName;
  edtColumnOrder.Text := IntToStr(Table.ColumnOrder);
  edtColumnWidth.Text := IntToStr(Table.ColumnWidth);
  edtDataFormat.Text := Table.DataFormat;
  chkIsShow.Checked := Table.IsShow;
  chkIsShowHelper.Checked := Table.IsShowHelper;
  if Assigned(chkIsFetch) then
    chkIsFetch.Checked := Table.IsFetch;
  edtMinValue.Text := FloatToStr(Table.MinValue);
  edtMinValueColor.Text := IntToStr(Table.MinValueColor);
  edtMaxValue.Text := FloatToStr(Table.MaxValue);
  edtMaxValueColor.Text := IntToStr(Table.MaxValueColor);
  edtMaxValuePercent.Text := FloatToStr(Table.MaxValuePercent);
  edtBarColor.Text := IntToStr(Table.BarColor);
  edtBarBkColor.Text := IntToStr(Table.BarBgColor);
  edtBarTextColor.Text := IntToStr(Table.BarTextColor);
  if Assigned(cbbAggregateType) then
  begin
    if (Table.AggregateType >= 0) and (Table.AggregateType < cbbAggregateType.Items.Count) then
      cbbAggregateType.ItemIndex := Table.AggregateType
    else
      cbbAggregateType.ItemIndex := 0;
  end;
end;

end.
