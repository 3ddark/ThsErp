unit ufrmSysGridColumn;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.CheckLst,
  ufrmInputSimpleDB, SharedFormTypes,
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
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
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
  Table.MinValue := StrToFloatDef(edtMinValue.Text, 0);
  Table.MinValueColor := StrToIntDef(edtMinValueColor.Text, 0);
  Table.MaxValue := StrToFloatDef(edtMaxValue.Text, 0);
  Table.MaxValueColor := StrToIntDef(edtMaxValueColor.Text, 0);
  Table.MaxValuePercent := StrToFloatDef(edtMaxValuePercent.Text, 0);
  Table.BarColor := StrToIntDef(edtBarColor.Text, 0);
  Table.BarBgColor := StrToIntDef(edtBarBkColor.Text, 0);
  Table.BarTextColor := StrToIntDef(edtBarTextColor.Text, 0);
  inherited;
end;

procedure TfrmSysGridColumn.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysGridColumn.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Grid Column';

  edtTableName.SetFocus;
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
  edtMinValue.Text := FloatToStr(Table.MinValue);
  edtMinValueColor.Text := IntToStr(Table.MinValueColor);
  edtMaxValue.Text := FloatToStr(Table.MaxValue);
  edtMaxValueColor.Text := IntToStr(Table.MaxValueColor);
  edtMaxValuePercent.Text := FloatToStr(Table.MaxValuePercent);
  edtBarColor.Text := IntToStr(Table.BarColor);
  edtBarBkColor.Text := IntToStr(Table.BarBgColor);
  edtBarTextColor.Text := IntToStr(Table.BarTextColor);
end;

end.
