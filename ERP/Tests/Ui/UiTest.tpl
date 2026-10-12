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

// Ana ekran: PageControl yok, göstergeler kart olarak çizilir, karta tıklayınca liste açılır,
// yetkisi kısıtlı kullanıcıda yalnız izinli kartlar görünür
procedure TestDashboardForm(AURepo: TSysUserRepository);
var
  Outer, Before: TList<TForm>;
  F: TfrmDashboard;
  Opened: TForm;
  Titles: TStringList;

  procedure CollectCards(AParent: TWinControl; AList: TStringList; out AFirstClickable: TLabel);
  var
    I, J: Integer;
    C: TControl;
    L: TLabel;
  begin
    AFirstClickable := nil;
    for I := 0 to AParent.ControlCount - 1 do
      if AParent.Controls[I] is TFlowPanel then
        for J := 0 to TFlowPanel(AParent.Controls[I]).ControlCount - 1 do
        begin
          C := TFlowPanel(AParent.Controls[I]).Controls[J];
          if C is TPanel then
            for var K := 0 to TPanel(C).ControlCount - 1 do
              if (TPanel(C).Controls[K] is TLabel) and (TLabel(TPanel(C).Controls[K]).Align = alTop) then
              begin
                L := TLabel(TPanel(C).Controls[K]);
                AList.Add(L.Caption);
                if (AFirstClickable = nil) and Assigned(L.OnClick) then
                  AFirstClickable := L;
              end;
        end;
  end;

  function Scroll: TScrollBox;
  begin
    // kart alanı çalışma anında oluşturulur (adı yok): formun tek TScrollBox bileşeni
    Result := nil;
    for var I := 0 to F.ComponentCount - 1 do
      if F.Components[I] is TScrollBox then
        Exit(TScrollBox(F.Components[I]));
  end;

var
  Clickable: TLabel;
begin
  TUi.Module := 'Core';
  TUi.FormName := 'TfrmDashboard';
  Outer := TUi.Snapshot;
  Titles := TStringList.Create;
  try
    try
      F := TfrmDashboard.Create(Application);
      F.Show;
      TUi.Pump;
      TUi.TakeDialogs;
      if F.FindComponent('PageControl1') = nil then
        TUi.R('PASS', 'page control removed', '')
      else
        TUi.R('FAIL', 'page control removed', 'PageControl1 still exists');
      // görsel kontrol için ekran görüntüsü (exe yanında UiTest-dashboard.png)
      F.SetBounds(0, 0, 1180, 760);
      TUi.Pump;
      var Bmp := TBitmap.Create;
      var Png := TPngImage.Create;
      try
        Bmp.SetSize(F.ClientWidth, F.ClientHeight);
        F.PaintTo(Bmp.Canvas, 0, 0);
        Png.Assign(Bmp);
        Png.SaveToFile(ExtractFilePath(ParamStr(0)) + 'UiTest-dashboard.png');
      finally
        Png.Free;
        Bmp.Free;
      end;
      CollectCards(Scroll, Titles, Clickable);
      if Titles.Count = 23 then
        TUi.R('PASS', 'super user cards', IntToStr(Titles.Count) + ': ' + Titles.CommaText)
      else
        TUi.R('FAIL', 'super user cards', IntToStr(Titles.Count) + ': ' + Titles.CommaText);
      if Titles.Count > 0 then
        if TUi.LooksLikeKey(Titles.Text) then
          TUi.R('FAIL', 'card titles translated', Titles.CommaText)
        else
          TUi.R('PASS', 'card titles translated', Titles[0]);

      // karta tıklama: ilgili liste açılır
      if Assigned(Clickable) then
      begin
        Before := TUi.Snapshot;
        try
          Clickable.OnClick(Clickable);
          TUi.Pump;
          Opened := TUi.NewForm(Before);
          if Opened <> nil then
            TUi.R('PASS', 'card click opens list', Clickable.Caption + ' -> ' + Opened.ClassName)
          else
            TUi.R('FAIL', 'card click opens list', Clickable.Caption + ': no window ' + TUi.TakeDialogs);
          TUi.CloseNewForms(Before);
          TUi.TakeDialogs;
        finally
          Before.Free;
        end;
      end;

      // TEST (id 4): yalnız kur + satın alma siparişi okuma
      TUi.Sql('SELECT count(*) FROM (SELECT 1) x', []);
      TUnitOfWork.Instance.Connection.ExecSQL('UPDATE sys_access_right SET deny_read = true, is_read = false WHERE sys_user_id = 4');
      TUnitOfWork.Instance.Connection.ExecSQL('UPDATE sys_access_right a SET deny_read = false, is_read = true FROM sys_permission p ' +
        'WHERE p.id = a.sys_permission_id AND a.sys_user_id = 4 AND p.permission_code IN (3001, 1081)');
      TAppContext.Instance.CurrentUser.User := AURepo.FindById(TValue.From<Int64>(4), False);
      try
        TUi.Call(F, 'RefreshUserPermissions', [False]);
        TUi.Pump;
        TUi.TakeDialogs;
        Titles.Clear;
        CollectCards(Scroll, Titles, Clickable);
        if Titles.Count = 3 then
          TUi.R('PASS', 'limited user cards', Titles.CommaText)
        else
          TUi.R('FAIL', 'limited user cards', IntToStr(Titles.Count) + ': ' + Titles.CommaText);
      finally
        TAppContext.Instance.CurrentUser.User := AURepo.FindById(TValue.From<Int64>(1), False);
        TUnitOfWork.Instance.Connection.ExecSQL('UPDATE sys_access_right SET deny_read = false WHERE sys_user_id = 4');
      end;
    except
      on E: Exception do TUi.R('FAIL', 'dashboard', E.ClassName + ': ' + E.Message + ' ' + TUi.TakeDialogs);
    end;
    TUi.CloseNewForms(Outer);
  finally
    Titles.Free;
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
      if TUi.Want('Core', 'TfrmDashboard') then
        TestDashboardForm(URepo);
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
