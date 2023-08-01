unit ufrmSysDatabaseMonitor;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Dialogs,
  Data.DB,
  ufrmBase,
  ufrmBaseDBGrid, System.Actions, Vcl.ActnList, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZPgEventAlerter;

type
  TfrmSysDatabaseMonitor = class(TfrmBaseDBGrid)
    mnikill_process_by_id: TMenuItem;
    cbbrefresh_period: TComboBox;
    tmrrefresh: TTimer;
    procedure mnikill_process_by_idClick(Sender: TObject);
    procedure cbbrefresh_periodChange(Sender: TObject);
    procedure tmrrefreshTimer(Sender: TObject);
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure mnicopy_recordClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table,
  Ths.Database.Table.View.SysDbStatus;

{$R *.dfm}

procedure TfrmSysDatabaseMonitor.cbbrefresh_periodChange(Sender: TObject);
begin
  if cbbrefresh_period.ItemIndex = 1 then
    tmrrefresh.Interval := 1000
  else if cbbrefresh_period.ItemIndex = 2 then
    tmrrefresh.Interval := 5000
  else if cbbrefresh_period.ItemIndex = 3 then
    tmrrefresh.Interval := 10000;
end;

function TfrmSysDatabaseMonitor.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
end;

procedure TfrmSysDatabaseMonitor.FormShow(Sender: TObject);
begin
  inherited;
  btnAddNew.Visible := False;
  pnlButtons.Visible := False;
  mniPreview.Visible := False;
  mniLangDataContent.Visible := False;

  setDisplayFormatInteger(TSysDBStatus(Table).PID.FieldName, '0', grd.DataSource.DataSet);

  cbbrefresh_period.ItemIndex := 0;
  cbbrefresh_periodChange(cbbrefresh_period);
  pnlHeader.Visible := True;
  edtFilterHelper.Visible := False;
  lblFilterHelper.Caption := 'Yenileme';
end;

procedure TfrmSysDatabaseMonitor.mnicopy_recordClick(Sender: TObject);
begin
  //
end;

procedure TfrmSysDatabaseMonitor.mnikill_process_by_idClick(Sender: TObject);
var
  LQry: TZQuery;
  LBtnResult: Integer;
  LPid: Integer;
  LField: TField;
begin
  LField := grd.DataSource.DataSet.FieldByName(TSysDBStatus(Table).PID.FieldName);
  if Assigned(LField) then
  begin
    if not LField.IsNull then
    begin
      LPid := LField.AsInteger;

      LBtnResult :=
        CustomMsgDlg(
        TranslateText('Kullanýcýnýn baðlantýsýný sonlandýrmak istediðinden emin misin?', FrameworkLang.MessageUpdateRecord, LngMsgData, LngSystem),
        mtConfirmation, mbYesNo, [TranslateText('Evet', FrameworkLang.GeneralYesLower, LngGeneral, LngSystem),
                                  TranslateText('Hayýr', FrameworkLang.GeneralNoLower, LngGeneral, LngSystem)], mbNo,
                                  TranslateText('Kullanýcý Onayý', FrameworkLang.GeneralConfirmationLower, LngGeneral, LngSystem));
      if LBtnResult = mrYes then
      begin
        LQry := GDataBase.NewQuery();
        try
          LQry.SQL.Text := 'SELECT pg_terminate_backend(' + LPid.ToString + ') FROM pg_stat_activity WHERE datname = current_database();';
          LQry.Open;
          ShowMessage('Kullanýcý sonlandýrma iþlemi baþarýlý bir þekilde yapýldý.');
          grd.DataSource.DataSet.Refresh;
        finally
          LQry.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmSysDatabaseMonitor.tmrrefreshTimer(Sender: TObject);
begin
  if cbbrefresh_period.ItemIndex > 0 then
    grd.DataSource.DataSet.Refresh;
end;

end.
