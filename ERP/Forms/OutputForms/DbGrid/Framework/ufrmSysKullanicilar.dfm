inherited frmSysKullanicilar: TfrmSysKullanicilar
  Caption = 'Kullan'#305'c'#305'lar'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pmDB: TPopupMenu
    object mniCopyAccessRightFromUser: TMenuItem
      Caption = 'Hakalar'#305' Di'#287'er Kullan'#305'c'#305'dan Kopyala'
      OnClick = mniCopyAccessRightFromUserClick
    end
  end
  inherited frxrprtBase: TfrxReport
    ScriptText.Strings = ()
  end
end
