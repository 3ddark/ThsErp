program UiTest;

{$APPTYPE CONSOLE}
{$I Ths.inc}

uses
  {{USES}};

// Cari hareketlerinde "Detay Göster": her kaynak tipi kendi giriş formunu açmalı
procedure TestShowSources;
const
  Expected: array[1..5] of string = ('TfrmFinMoneyTransaction', 'TfrmFinChequeNote', 'TfrmFinPosTransaction',
    'TfrmFinCreditCardTransaction', 'TfrmPurInvoice');
var
  Outer, Before: TList<TForm>;
  LFrm: TfrmAccAccountTransactions;
  F: TForm;
  V: Variant;
  T: Integer;
begin
  TUi.Module := 'Account';
  TUi.FormName := 'TfrmAccAccountTransactions';
  Outer := TUi.Snapshot;
  try
    LFrm := TfrmAccAccountTransactions.Create(Application, TAccAccountTransactionService.Create, TAccAccountTransaction.Create);
    LFrm.Show;
    TUi.Pump;
    for T := 1 to 5 do
    begin
      V := TUi.Sql('SELECT min(document_id) FROM vw_acc_account_transaction WHERE source_type = :t', [T]);
      if VarIsNull(V) or VarIsEmpty(V) then
      begin
        TUi.R('WARN', 'show source ' + IntToStr(T), 'no rows of this source type');
        Continue;
      end;
      Before := TUi.Snapshot;
      try
        try
          LFrm.OpenSourceDocument(T, V);
          TUi.Pump;
          F := TUi.NewForm(Before);
          if (F <> nil) and SameText(F.ClassName, Expected[T]) then
            TUi.R('PASS', 'show source ' + IntToStr(T), F.ClassName + ' "' + F.Caption + '" ' + TUi.Mode(F) + ' ' + TUi.TakeDialogs)
          else if F = nil then
            TUi.R('FAIL', 'show source ' + IntToStr(T), 'no form opened ' + TUi.TakeDialogs)
          else
            TUi.R('FAIL', 'show source ' + IntToStr(T), 'unexpected form ' + F.ClassName);
        except
          on E: Exception do TUi.R('FAIL', 'show source ' + IntToStr(T), E.ClassName + ': ' + E.Message);
        end;
        TUi.CloseNewForms(Before);
        TUi.TakeDialogs;
      finally
        Before.Free;
      end;
    end;
    TUi.CloseNewForms(Outer);
  finally
    Outer.Free;
  end;
end;

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
      if TUi.Want('Account', 'TfrmAccAccountTransactions') then
        TestShowSources;
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
