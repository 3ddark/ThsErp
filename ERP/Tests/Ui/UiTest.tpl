program UiTest;

{$APPTYPE CONSOLE}
{$I Ths.inc}

uses
  {{USES}};

var
  GConn: TFDConnection;
  Ctx: TUserContext;
  URepo: TSysUserRepository;

begin
  Application.Initialize;
  Application.DefaultFont.Name := 'Tahoma';
  Application.UpdateFormatSettings := False;
  FormatSettings.ThousandSeparator := '.';
  FormatSettings.DecimalSeparator := ',';
  FormatSettings.DateSeparator := '.';
  FormatSettings.ShortDateFormat := 'dd.mm.yyyy';
  FormatSettings.LongDateFormat  := 'dd.mm.yyyy dddd';
  FormatSettings.ShortTimeFormat := 'HH:mm';
  FormatSettings.LongTimeFormat  := 'HH:mm:ss';
  FormatSettings.TimeSeparator   := ':';
  UseLatestCommonDialogs := False;

  TUi.FilterModule := ParamStr(1);
  TUi.FilterForm := ParamStr(2);
  TUi.OpenReport(ExtractFilePath(ParamStr(0)) + 'UiTest-report.txt');
  try
    try
      Application.CreateForm(Tdm, dm);
      TLocalizationManager.SetLanguage('tr-TR');
      GConn := TConnectionManager.Instance.GetConnection(ContextMain, '127.0.0.1', 'ths_erp_it', 'postgres', 'qwe', 5432);
      TUnitOfWork.Initialize(GConn);
      TLanguageCache.Load;
      TSysGridColumnCache.LoadGlobal(GConn);
      GConn.ExecSQLScalar('SELECT set_config(''ths_erp.user_name'', :uname, false)', ['UI_TEST']);
      TAppContext.Initialize(GConn);
      Ctx := TUserContext.Create(nil, True);
      Ctx.ActiveLanguage := 'tr-TR';
      TAppContext.Instance.SetCurrentUser(Ctx);
      URepo := TSysUserRepository.Create(GConn);
      Ctx.User := URepo.FindById(TValue.From<Int64>(1), False);
      TSysGridColumnCache.LoadUser(GConn, 1);
      TUi.Install;

{{CALLS}}
    except
      on E: Exception do
      begin
        TUi.Module := 'main';
        TUi.R('FAIL', 'fatal', E.ClassName + ': ' + E.Message);
      end;
    end;
    TUi.Module := '';
    TUi.FormName := '';
    TUi.R('SUM', '', Format('pass=%d fail=%d warn=%d', [TUi.Pass, TUi.Fail, TUi.Warn]));
  finally
    TUi.CloseReport;
  end;
  GLogger.Flush;
  ExitProcess(Ord(TUi.Fail > 0));
end.
