program UiTest;

{$APPTYPE CONSOLE}
{$I Ths.inc}

uses
  {{USES}};

// Cari hareketlerinde "Detay Göster": her kaynak tipi kendi giriş formunu açmalı
procedure TestShowSources;
const
  Expected: array[1..5] of string = ('TfrmFinMoneyTransaction', 'TfrmFinChequeNote', 'TfrmFinPosTransaction',
    'TfrmFinCreditCardTransaction', 'TfrmPurInvoiceDetail');
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

// Ana ekran: PageControl yok, göstergeler çizilen kartlar (TDashTile) + genel bakış grafikleri (TDashChart),
// karta / grafiğe tıklayınca liste açılır, yetkisi kısıtlı kullanıcıda yalnız izinli kartlar görünür
procedure TestDashboardForm(AURepo: TSysUserRepository);
var
  Outer, Before: TList<TForm>;
  F: TfrmDashboard;
  Opened: TForm;
  Titles, ChartTitles: TStringList;

  procedure CollectCards(AParent: TWinControl; AList: TStringList; out AFirstClickable: TDashTile);
  var
    I, J: Integer;
    C: TControl;
  begin
    AFirstClickable := nil;
    ChartTitles.Clear;
    for I := 0 to AParent.ControlCount - 1 do
      if AParent.Controls[I] is TFlowPanel then
        for J := 0 to TFlowPanel(AParent.Controls[I]).ControlCount - 1 do
        begin
          C := TFlowPanel(AParent.Controls[I]).Controls[J];
          if C is TDashTile then
          begin
            AList.Add(TDashTile(C).Data.Title);
            if (AFirstClickable = nil) and TDashTile(C).Clickable and Assigned(TDashTile(C).OnClick) then
              AFirstClickable := TDashTile(C);
          end
          else if C is TDashChart then
            ChartTitles.Add(TDashChart(C).Data.Title);
        end;
  end;

  function NodeText(N: TTreeNode): string;
  begin
    if Assigned(N) then Result := N.Text else Result := '(empty)';
  end;

  function FormClassText(AForm: TForm): string;
  begin
    if Assigned(AForm) then Result := AForm.ClassName else Result := 'no form';
  end;

  function Nav: TNavMenuPanel;
  begin
    Result := nil;
    for var I := 0 to F.ComponentCount - 1 do
      if F.Components[I] is TNavMenuPanel then
        Exit(TNavMenuPanel(F.Components[I]));
  end;

  function MenuName(ACode: Integer): string;
  begin
    Result := VarToStr(TUi.Sql('SELECT menu_name FROM vw_sys_menu WHERE menu_code = :c AND locale = :l',
      [ACode, TAppContext.Instance.CurrentUser.ActiveLanguage]));
  end;

  // ağaçtaki ekran (klasör olmayan) düğümleri; Favoriler / Son Kullanılanlar kopyaları hariç
  function NavScreens: TStringList;
  var
    N: TTreeNode;
  begin
    Result := TStringList.Create;
    N := Nav.Tree.Items.GetFirstNode;
    while Assigned(N) do
    begin
      if not N.HasChildren and not Nav.IsShortcutNode(N) and (NativeInt(N.Data) > 0) then
        Result.Add(N.Text);
      N := N.GetNext;
    end;
  end;

  // kök düzeyindeki ilk modül (kısayol klasörleri atlanır)
  function FirstModuleNode: TTreeNode;
  begin
    Result := Nav.Tree.Items.GetFirstNode;
    while Assigned(Result) and (NativeInt(Result.Data) < 0) do
      Result := Result.getNextSibling;
  end;

  // kök düzeyinde kısayol klasörü (-1 favoriler, -2 son kullanılanlar)
  function ShortcutFolder(AData: Integer): TTreeNode;
  begin
    Result := Nav.Tree.Items.GetFirstNode;
    while Assigned(Result) and (NativeInt(Result.Data) <> AData) do
      Result := Result.getNextSibling;
  end;

  // ana ağaçta ekran düğümü (kısayol kopyası değil)
  function ScreenNode(ACode: Integer): TTreeNode;
  begin
    Result := Nav.Tree.Items.GetFirstNode;
    while Assigned(Result) do
    begin
      if not Nav.IsShortcutNode(Result) and (Result.Text = MenuName(ACode)) and not Result.HasChildren then
        Exit;
      Result := Result.GetNext;
    end;
  end;

  procedure PressCtrlD;
  var
    LKey: Word;
  begin
    LKey := Ord('D');
    Nav.Tree.OnKeyDown(Nav.Tree, LKey, [ssCtrl]);
    TUi.Pump;
  end;

  function UserMenuValue(ACode: Integer; const AColumn: string): Variant;
  begin
    Result := TUi.Sql('SELECT um.' + AColumn + ' FROM sys_user_menu um JOIN sys_menu m ON m.id = um.sys_menu_id ' +
      'WHERE um.sys_user_id = :u AND m.menu_code = :c', [TAppContext.Instance.CurrentUser.GetUserId, ACode]);
  end;

  procedure CheckNavSearch(const AText: string; AExpectCount: Integer; AMustCode, AMustNotCode: Integer);
  var
    L: TStringList;
    LOk: Boolean;
  begin
    Nav.SearchBox.Text := AText;
    TUi.Pump;
    L := NavScreens;
    try
      LOk := ((AExpectCount < 0) or (L.Count = AExpectCount))
        and ((AMustCode = 0) or (L.IndexOf(MenuName(AMustCode)) >= 0))
        and ((AMustNotCode = 0) or (L.IndexOf(MenuName(AMustNotCode)) < 0));
      if LOk then
        TUi.R('PASS', 'nav search "' + AText + '"', IntToStr(L.Count) + ': ' + L.CommaText)
      else
        TUi.R('FAIL', 'nav search "' + AText + '"', IntToStr(L.Count) + ': ' + L.CommaText);
    finally
      L.Free;
    end;
  end;

  procedure CheckCaptionCode(AForm: TForm; ACode: Integer; const AStep: string);
  begin
    if (AForm <> nil) and EndsStr(' [' + IntToStr(ACode) + ']', AForm.Caption)
      and (Pos('[' + IntToStr(ACode) + ']', AForm.Caption) = Length(AForm.Caption) - Length(IntToStr(ACode)) - 1) then
      TUi.R('PASS', AStep, AForm.Caption)
    else if AForm = nil then
      TUi.R('FAIL', AStep, 'no form')
    else
      TUi.R('FAIL', AStep, AForm.Caption);
  end;

  procedure TestNav;
  var
    L: TStringList;
    Before: TList<TForm>;
    Opened, Child: TForm;
    K: Char;
    N: TTreeNode;
  begin
    if Nav = nil then
    begin
      TUi.R('FAIL', 'nav panel', 'TNavMenuPanel not found');
      Exit;
    end;
    Nav.SearchBox.Text := '';
    TUi.Pump;
    L := NavScreens;
    try
      // klasörler kapalıyken alt düğümler de ağaçta (Items) bulunur
      if L.Count = TUi.Sql('SELECT count(*) FROM sys_menu WHERE action_name IS NOT NULL AND is_active', []) then
        TUi.R('PASS', 'nav super user screens', IntToStr(L.Count))
      else
        TUi.R('FAIL', 'nav super user screens', IntToStr(L.Count));
    finally
      L.Free;
    end;
    N := FirstModuleNode;
    if Assigned(N) and (N.Text = MenuName(100000)) and (N.Level = 0) then
      TUi.R('PASS', 'nav first module', N.Text)
    else
      TUi.R('FAIL', 'nav first module', NodeText(N));

    if (Nav.SearchBox.TextHint <> '') and not TUi.LooksLikeKey(Nav.SearchBox.TextHint) then
      TUi.R('PASS', 'nav search hint', Nav.SearchBox.TextHint)
    else
      TUi.R('FAIL', 'nav search hint', '"' + Nav.SearchBox.TextHint + '"');

    // arama: ad, Türkçe harf duyarsız, anahtar kelime, üst klasör adı, kod öneki
    CheckNavSearch('cek', -1, 300301, 400101);
    // görsel kontrol: arama sonucu (kodlu ekran satırları) -> UiTest-dashboard-nav.png
    var NavBmp := TBitmap.Create;
    var NavPng := TPngImage.Create;
    try
      NavBmp.SetSize(F.ClientWidth, F.ClientHeight);
      F.PaintTo(NavBmp.Canvas, 0, 0);
      NavPng.Assign(NavBmp);
      NavPng.SaveToFile(ExtractFilePath(ParamStr(0)) + 'UiTest-dashboard-nav.png');
    finally
      NavPng.Free;
      NavBmp.Free;
    end;
    CheckNavSearch('MUSTERI CEK', -1, 300301, 300302);
    CheckNavSearch('havale', 1, 300201, 0);
    CheckNavSearch(MenuName(300000), 14, 300305, 400101);
    CheckNavSearch('3003', 5, 300301, 300201);
    CheckNavSearch('zzzz', 0, 0, 0);
    Nav.SearchBox.Text := 'abc';
    Nav.FocusSearch;
    TUi.Pump;
    if Nav.HandleEscape and (Nav.SearchBox.Text = '') then
      TUi.R('PASS', 'nav escape clears search', '')
    else
      TUi.R('FAIL', 'nav escape clears search', '"' + Nav.SearchBox.Text + '"');

    // tam kod + Enter: ekran açılır, başlığın sonunda kod
    Before := TUi.Snapshot;
    try
      Nav.SearchBox.Text := '300301';
      TUi.Pump;
      K := #13;
      Nav.SearchBox.OnKeyPress(Nav.SearchBox, K);
      TUi.Pump;
      Opened := TUi.NewForm(Before);
      if (Opened <> nil) and (Opened.ClassName = 'TfrmFinChequeNotes') then
        TUi.R('PASS', 'nav code + enter opens screen', Opened.ClassName + ' ' + TUi.TakeDialogs)
      else
        TUi.R('FAIL', 'nav code + enter opens screen', FormClassText(Opened) + ' ' + TUi.TakeDialogs);
      CheckCaptionCode(Opened, 300301, 'screen code in caption');

      // son kullanılanlar: ilk sırada az önce açılan ekran, DB'de açılma kaydı
      Nav.SearchBox.Text := '';
      TUi.Pump;
      N := ShortcutFolder(-2);
      if Assigned(N) and (N.getFirstChild <> nil) and (N.getFirstChild.Text = MenuName(300301))
        and (UserMenuValue(300301, 'open_count') >= 1) and not VarIsNull(UserMenuValue(300301, 'last_opened_at')) then
        TUi.R('PASS', 'nav recent', N.getFirstChild.Text + ', open_count=' + VarToStr(UserMenuValue(300301, 'open_count')))
      else
        TUi.R('FAIL', 'nav recent', NodeText(N) + ' / ' + NodeText(N.getFirstChild));

      // favori: Ctrl+D ekler (Favoriler klasörü + DB), tekrar Ctrl+D çıkarır
      N := ScreenNode(400101);
      if Assigned(N) then
      begin
        Nav.Tree.Selected := N;
        PressCtrlD;
        N := ShortcutFolder(-1);
        if Assigned(N) and (N.getFirstChild <> nil) and (N.getFirstChild.Text = MenuName(400101))
          and (UserMenuValue(400101, 'is_favorite') = True) then
        begin
          TUi.R('PASS', 'nav add favorite', N.getFirstChild.Text);
          var FavBmp := TBitmap.Create;
          var FavPng := TPngImage.Create;
          try
            FavBmp.SetSize(F.ClientWidth, F.ClientHeight);
            F.PaintTo(FavBmp.Canvas, 0, 0);
            FavPng.Assign(FavBmp);
            FavPng.SaveToFile(ExtractFilePath(ParamStr(0)) + 'UiTest-dashboard-fav.png');
          finally
            FavPng.Free;
            FavBmp.Free;
          end;
        end
        else
          TUi.R('FAIL', 'nav add favorite', NodeText(N));
        // kısayol kopyası seçiliyken de çıkarılabilir
        if Assigned(N) and (N.getFirstChild <> nil) then
          Nav.Tree.Selected := N.getFirstChild;
        PressCtrlD;
        if (ShortcutFolder(-1) = nil) and (UserMenuValue(400101, 'is_favorite') = False) then
          TUi.R('PASS', 'nav remove favorite', '')
        else
          TUi.R('FAIL', 'nav remove favorite', NodeText(ShortcutFolder(-1)));
        if (Nav.Tree.Selected <> nil) and (Nav.Tree.Selected.Text = MenuName(400101)) then
          TUi.R('PASS', 'nav selection kept', Nav.Tree.Selected.Text)
        else
          TUi.R('FAIL', 'nav selection kept', NodeText(Nav.Tree.Selected));
      end
      else
        TUi.R('FAIL', 'nav add favorite', 'stock card node not found');
      if Opened <> nil then
      begin
        Opened.Caption := 'X';
        CheckCaptionCode(Opened, 300301, 'screen code kept on caption change');
        if Opened.Caption = 'X [300301]' then
          TUi.R('PASS', 'screen code not duplicated', Opened.Caption)
        else
          TUi.R('FAIL', 'screen code not duplicated', Opened.Caption);

        // ekrandan açılan (modal olmayan) form kodu devralır
        Child := TForm.CreateNew(Opened);
        Child.Caption := 'Child';
        Child.Show;
        TUi.Pump;
        CheckCaptionCode(Child, 300301, 'child form inherits screen code');

        // dil değişimi: başlık yeniden yazılır, kod sonda kalır; ağaç adları yeni dilde
        TUi.Call(F, 'ChangeLanguage', ['en-US']);
        TUi.Pump;
        TUi.TakeDialogs;
        CheckCaptionCode(Opened, 300301, 'screen code after language change');
        Nav.SearchBox.Text := '';
        TUi.Pump;
        N := FirstModuleNode;
        if Assigned(N) and (N.Text = MenuName(100000)) and (N.Text <> 'Sistem')
          and Assigned(ShortcutFolder(-2)) and (ShortcutFolder(-2).Text = 'Recently Used') then
          TUi.R('PASS', 'nav language change', N.Text)
        else
          TUi.R('FAIL', 'nav language change', NodeText(N));
        TUi.Call(F, 'ChangeLanguage', ['tr-TR']);
        TUi.Pump;
        TUi.TakeDialogs;
      end;
      TUi.CloseNewForms(Before);
      TUi.TakeDialogs;
    finally
      Before.Free;
    end;
    Nav.SearchBox.Text := '';
    TUi.Pump;

    // komut paleti: kod öneki, seçim, boş sorguda son kullanılanlar
    var Pal := TNavCommandPalette.CreatePalette(F, Nav, 'hint', 'empty');
    try
      var PItem: TSysMenuItem;
      Pal.SearchBox.Text := '3003';
      TUi.Pump;
      if (Pal.List.Count = 5) and Pal.Selected(PItem) and (PItem.MenuCode = 300301) then
        TUi.R('PASS', 'palette code search', IntToStr(Pal.List.Count) + ' -> ' + PItem.MenuName)
      else
        TUi.R('FAIL', 'palette code search', IntToStr(Pal.List.Count));
      Pal.SearchBox.Text := 'havale';
      TUi.Pump;
      if (Pal.List.Count = 1) and Pal.Selected(PItem) and (PItem.MenuCode = 300201) then
        TUi.R('PASS', 'palette keyword search', PItem.MenuName)
      else
        TUi.R('FAIL', 'palette keyword search', IntToStr(Pal.List.Count));
      Pal.SearchBox.Text := '';
      TUi.Pump;
      if (Pal.List.Count > 0) and Pal.Selected(PItem) and (PItem.LastOpenedAt > 0) then
        TUi.R('PASS', 'palette recent when empty', IntToStr(Pal.List.Count) + ', first ' + PItem.MenuName)
      else
        TUi.R('FAIL', 'palette recent when empty', IntToStr(Pal.List.Count));
    finally
      Pal.Free;
    end;

    // açık klasörler dışarıdan verilebilir / okunabilir (kullanıcı ayarı olarak saklanır)
    Nav.ExpandedKeys := [400000, 400900];
    N := FirstModuleNode;
    while Assigned(N) and (N.Text <> MenuName(400000)) do
      N := N.getNextSibling;
    if Assigned(N) and N.Expanded and (N.getFirstChild <> nil) and not N.getFirstChild.Expanded
      and (Length(Nav.ExpandedKeys) >= 2) then
      TUi.R('PASS', 'nav expanded keys', NodeText(N))
    else
      TUi.R('FAIL', 'nav expanded keys', NodeText(N));
    Nav.ExpandedKeys := [];

    // kullanıcı ayarı kaydı (sys_user_setting)
    var USvc := TSysUserSettingService.Create;
    try
      USvc.SetValue(USER_SETTING_NAV_EXPANDED, '400000,1');
      var UVals := USvc.GetValues('nav.');
      try
        if UVals.ContainsKey(USER_SETTING_NAV_EXPANDED) and (UVals[USER_SETTING_NAV_EXPANDED] = '400000,1') then
          TUi.R('PASS', 'user setting roundtrip', UVals[USER_SETTING_NAV_EXPANDED])
        else
          TUi.R('FAIL', 'user setting roundtrip', '');
      finally
        UVals.Free;
      end;
    finally
      USvc.Free;
    end;

    // pasif klasör: altındaki ekranlar ağaçtan kalkar, action kapanır
    TUnitOfWork.Instance.Connection.ExecSQL('UPDATE sys_menu SET is_active = false WHERE menu_code = 300300');
    try
      TUi.Call(F, 'RefreshUserPermissions', [False]);
      TUi.Pump;
      L := NavScreens;
      try
        if (L.IndexOf(MenuName(300301)) < 0) and (L.IndexOf(MenuName(300201)) >= 0)
          and not TAction(F.FindComponent('actfin_customer_cheques')).Enabled then
          TUi.R('PASS', 'passive folder hides screens', IntToStr(L.Count))
        else
          TUi.R('FAIL', 'passive folder hides screens', IntToStr(L.Count));
      finally
        L.Free;
      end;
    finally
      TUnitOfWork.Instance.Connection.ExecSQL('UPDATE sys_menu SET is_active = true WHERE menu_code = 300300');
      TUi.Call(F, 'RefreshUserPermissions', [False]);
      TUi.Pump;
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
  Clickable: TDashTile;
begin
  TUi.Module := 'Core';
  TUi.FormName := 'TfrmDashboard';
  Outer := TUi.Snapshot;
  Titles := TStringList.Create;
  ChartTitles := TStringList.Create;
  try
    try
      F := TfrmDashboard.Create(Application);
      F.Show;
      TUi.Pump;
      var OpenDlg := TUi.TakeDialogs;
      if OpenDlg <> '' then
        TUi.R('FAIL', 'dashboard open dialogs', OpenDlg);
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
      if ChartTitles.Count = 4 then
        TUi.R('PASS', 'super user charts', ChartTitles.CommaText)
      else
        TUi.R('FAIL', 'super user charts', IntToStr(ChartTitles.Count) + ': ' + ChartTitles.CommaText);
      if (ChartTitles.Count > 0) and TUi.LooksLikeKey(ChartTitles.Text) then
        TUi.R('FAIL', 'chart titles translated', ChartTitles.CommaText);

      // karta tıklama: ilgili liste açılır
      if Assigned(Clickable) then
      begin
        Before := TUi.Snapshot;
        try
          Clickable.OnClick(Clickable);
          TUi.Pump;
          Opened := TUi.NewForm(Before);
          if Opened <> nil then
            TUi.R('PASS', 'card click opens list', Clickable.Data.Title + ' -> ' + Opened.ClassName)
          else
            TUi.R('FAIL', 'card click opens list', Clickable.Data.Title + ': no window ' + TUi.TakeDialogs);
          if (Opened <> nil) and EndsStr(']', Opened.Caption) and (Pos(' [', Opened.Caption) > 0) then
            TUi.R('PASS', 'card click screen code', Opened.Caption)
          else if Opened <> nil then
            TUi.R('FAIL', 'card click screen code', Opened.Caption);
          TUi.CloseNewForms(Before);
          TUi.TakeDialogs;
        finally
          Before.Free;
        end;
      end;

      TestNav;

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
        if ChartTitles.Count = 1 then
          TUi.R('PASS', 'limited user charts', ChartTitles.CommaText)
        else
          TUi.R('FAIL', 'limited user charts', IntToStr(ChartTitles.Count) + ': ' + ChartTitles.CommaText);
        // ağaçta yalnız izinli ekranlar: kur, satın alma siparişi + kalemleri (aynı yetki) + yetkisiz şifre değiştir
        var NavL := NavScreens;
        try
          if (NavL.Count = 4) and (NavL.IndexOf(MenuName(200202)) >= 0) and (NavL.IndexOf(MenuName(500302)) >= 0)
            and (NavL.IndexOf(MenuName(500402)) >= 0)
            and (NavL.IndexOf(MenuName(100108)) >= 0) then
            TUi.R('PASS', 'limited user nav', NavL.CommaText)
          else
            TUi.R('FAIL', 'limited user nav', IntToStr(NavL.Count) + ': ' + NavL.CommaText);
        finally
          NavL.Free;
        end;
        if not TAction(F.FindComponent('actstk_stok_kartlari')).Enabled and TAction(F.FindComponent('actpur_orders')).Enabled then
          TUi.R('PASS', 'limited user actions', '')
        else
          TUi.R('FAIL', 'limited user actions', 'action enabled state does not follow sys_menu permission');
      finally
        TAppContext.Instance.CurrentUser.User := AURepo.FindById(TValue.From<Int64>(1), False);
        TUnitOfWork.Instance.Connection.ExecSQL('UPDATE sys_access_right SET deny_read = false WHERE sys_user_id = 4');
      end;
    except
      on E: Exception do TUi.R('FAIL', 'dashboard', E.ClassName + ': ' + E.Message + ' ' + TUi.TakeDialogs);
    end;
    TUi.CloseNewForms(Outer);
  finally
    ChartTitles.Free;
    Titles.Free;
    Outer.Free;
  end;
end;

// Uygulama ayarları: tek kayıtlık, sekmeli, listeden açılmaz; ana ekrandaki gibi açılır (kayıt varsa inceleme)
procedure TestAppSettingForm;
const
  Langs: array[0..2] of string = ('en-US', 'de-DE', 'tr-TR');
var
  Outer: TList<TForm>;
  JS, JN: TJSONObject;
  Id: Int64;
  S, D, Lang: string;
  F: TForm;
  Helpers: TList<Ths.Helper.Edit.TEdit>;
  H: Ths.Helper.Edit.TEdit;

  function OpenForm: TForm;
  var
    LSvc: TSysApplicationSettingService;
    LSetting: TSysApplicationSetting;
  begin
    Result := nil;
    LSvc := TSysApplicationSettingService.Create;
    try
      LSetting := LSvc.BusinessFindSetting(False, False, True);
    except
      LSvc.Free;
      raise;
    end;
    if not Assigned(LSetting) then
    begin
      LSvc.Free;
      Exit;
    end;
    Id := LSetting.Id;
    Result := TfrmSysApplicationSetting.Create(Application, LSvc, LSetting, ifmRewiev, nil, ivmNormal, True);
    Result.Show;
    TUi.Pump;
  end;

begin
  TUi.Module := 'System';
  TUi.FormName := 'TfrmSysApplicationSetting';
  Outer := TUi.Snapshot;
  JS := nil;
  try
    try
      TUi.Dialogs.Clear;
      F := OpenForm;
      D := TUi.TakeDialogs;
      if F = nil then
      begin
        TUi.R('WARN', 'data', 'no sys_application_setting row');
        Exit;
      end;
      TUi.R(IfThen(TUi.HasError(D), 'FAIL', 'PASS'), 'open (review)', F.Caption + ' ' + D);
      JS := TUi.RowJson('sys_application_setting', Id);

      // görünüm: yerleşim, Tab sırası, başlıklar (3 dil), sekmeler, alanlar DB satırıyla aynı, inceleme salt okunur
      S := TUi.LayoutProblems(F);
      if S <> '' then TUi.R('FAIL', 'layout', S) else TUi.R('PASS', 'layout', '');
      S := TUi.TabOrderProblems(F);
      if S <> '' then TUi.R('FAIL', 'tab order', S) else TUi.R('PASS', 'tab order', '');
      S := TUi.CaptionProblems(F);
      if S <> '' then TUi.R('WARN', 'captions tr-TR', S);
      for Lang in Langs do
      begin
        TUi.SetLanguage(Lang, [F]);
        S := TUi.CaptionProblems(F);
        D := TUi.TakeDialogs;
        if TUi.LooksLikeKey(F.Caption) or (D <> '') then
          TUi.R('FAIL', 'language ' + Lang, 'caption [' + F.Caption + '] ' + D)
        else if (S <> '') and (Lang <> 'tr-TR') then
          TUi.R('WARN', 'input captions ' + Lang, S)
        else
          TUi.R('PASS', 'language ' + Lang, F.Caption);
      end;
      S := TUi.ReviewProblems(F);
      if S <> '' then TUi.R('FAIL', 'review read-only', S) else TUi.R('PASS', 'review read-only', '');
      S := TUi.SwitchTabs(F);
      if S <> '' then TUi.R('FAIL', 'tab switch', S) else TUi.R('PASS', 'tab switch', '');
      S := TUi.FieldValueProblems(F, JS);
      if S <> '' then TUi.R('FAIL', 'fields filled', S) else TUi.R('PASS', 'fields filled', 'all controls match DB row');

      // inceleme -> güncelle -> aynı değerlerle onayla: satır değişmemeli
      S := TUi.Accept(F);
      D := TUi.TakeDialogs;
      if (S <> '') or (TUi.Mode(F) <> 'ifmUpdate') then
        TUi.R('FAIL', 'review -> update', Format('mode %s %s %s', [TUi.Mode(F), S, D]))
      else
      begin
        TUi.R('PASS', 'review -> update', '');
        S := TUi.Accept(F);
        D := TUi.TakeDialogs;
        JN := TUi.RowJson('sys_application_setting', Id);
        try
          if S <> '' then
            TUi.R('FAIL', 'update same values', S + ' ' + D)
          else if TUi.Alive(F) then
            TUi.R('FAIL', 'update same values', 'form still open: ' + D)
          else
          begin
            S := TUi.DiffRows(JS, JN, False);
            if S <> '' then TUi.R('FAIL', 'update same values', 'row changed: ' + S)
            else TUi.R('PASS', 'update same values', 'row unchanged');
          end;
        finally
          JN.Free;
        end;
      end;
      TUi.CloseNewForms(Outer);
      TUi.TakeDialogs;

      // yeniden aç -> güncelle: zorunlu alanlar (sekme + odak), helper seçimleri, onaylamadan kapat -> rollback
      F := OpenForm;
      TUi.TakeDialogs;
      if F <> nil then
      begin
        TUi.Accept(F);
        TUi.TakeDialogs;
        if TUi.Mode(F) = 'ifmUpdate' then
        begin
          TUi.RequiredTabCheck(F);
          Helpers := TUi.HelperEdits(F);
          try
            for H in Helpers do
            begin
              TUi.Dialogs.Clear;
              try
                H.OnHelperProcess(H);
                TUi.Pump;
                D := TUi.TakeDialogs;
                if TUi.HasError(D) then
                  TUi.R('FAIL', 'helper ' + H.Name, D)
                else if ContainsText(D, 'HELPER-EMPTY') then
                  TUi.R('WARN', 'helper ' + H.Name, 'helper list empty: ' + D)
                else if not ContainsText(D, 'HELPER:') then
                  TUi.R('FAIL', 'helper ' + H.Name, 'no helper list shown: ' + D)
                else
                  TUi.R('PASS', 'helper ' + H.Name, H.Text);
              except
                on E: Exception do TUi.R('FAIL', 'helper ' + H.Name, E.ClassName + ': ' + E.Message + ' ' + TUi.TakeDialogs);
              end;
            end;
          finally
            Helpers.Free;
          end;
          if TUi.Alive(F) then
          begin
            TUi.CloseForm(F);
            D := TUi.TakeDialogs;
            JN := TUi.RowJson('sys_application_setting', Id);
            try
              S := TUi.DiffRows(JS, JN, False);
              if TUnitOfWork.Instance.InTransaction then
                TUi.R('FAIL', 'close without confirm', 'transaction still open ' + D)
              else if S <> '' then
                TUi.R('FAIL', 'close without confirm', 'row changed: ' + S)
              else
                TUi.R('PASS', 'close without confirm', 'rolled back');
            finally
              JN.Free;
            end;
          end;
        end
        else
          TUi.R('FAIL', 'review -> update (2)', 'mode ' + TUi.Mode(F));
      end;
    except
      on E: Exception do TUi.R('FAIL', 'application setting', E.ClassName + ': ' + E.Message + ' ' + TUi.TakeDialogs);
    end;
    TUi.CloseNewForms(Outer);
    TUi.TakeDialogs;
  finally
    JS.Free;
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
      GConn := TConnectionManager.Instance.GetConnection(ContextMain, '127.0.0.1', 'ths_erp_it', 'postgres', 'qwe', {{PORT}});
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
      if TUi.Want('System', 'TfrmSysApplicationSetting') then
        TestAppSettingForm;
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
