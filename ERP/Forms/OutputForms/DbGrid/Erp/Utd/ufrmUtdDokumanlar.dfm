inherited frmUtdDokumanlar: TfrmUtdDokumanlar
  Caption = #220'retim Teknik Dok'#252'manlar'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBottom: TPanel
    inherited btnAccept: TButton
      Caption = 'KAYDET'
    end
    inherited btnDelete: TButton
      Caption = 'S'#304'L'
    end
    inherited btnClose: TButton
      Caption = 'KAPAT'
    end
  end
  inherited pmDB: TPopupMenu
    object mniDosyaGoster: TMenuItem [0]
      Caption = 'Dosyay'#305' G'#246'ster'
      OnClick = mniDosyaGosterClick
    end
  end
  inherited frxrprtBase: TfrxReport
    ScriptText.Strings = ()
  end
end
