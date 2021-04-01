inherited frmBbkKayitlar: TfrmBbkKayitlar
  Caption = 'Bilgi Bankas'#305' Kay'#305'tlar'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited pnlButtons: TPanel
      inherited pnlButtonRight: TPanel
        object rghizli_filtre: TRadioGroup
          Left = 0
          Top = 0
          Width = 185
          Height = 80
          Align = alClient
          Caption = 'H'#305'zl'#305' Filtre'
          Items.Strings = (
            'Genel'
            'Asans'#246'r'
            'Export')
          TabOrder = 0
          OnClick = HizliFiltre
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    inherited btnAccept: TButton
      Caption = 'KAYDET'
    end
  end
  inherited pmDB: TPopupMenu
    object mniN1: TMenuItem [2]
      Caption = '-'
    end
    object mnitasi: TMenuItem [3]
      Caption = 'Di'#287'er Men'#252'ye Ta'#351#305
      object mnito_genel: TMenuItem
        Caption = 'Genele Ta'#351#305
        OnClick = mnito_genelClick
      end
      object mnito_asansor: TMenuItem
        Caption = 'Asans'#246're Ta'#351#305
        OnClick = mnito_asansorClick
      end
      object mnito_export: TMenuItem
        Caption = 'Exporta Ta'#351#305
        OnClick = mnito_exportClick
      end
    end
  end
  inherited frxrprtBase: TfrxReport
    ScriptText.Strings = ()
  end
end
