inherited frmBaseInput: TfrmBaseInput
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    object pgcMain: TPageControl
      Left = 1
      Top = 1
      Width = 600
      Height = 348
      ActivePage = tsMain
      Align = alClient
      TabOrder = 0
      TabStop = False
      object tsMain: TTabSheet
        Caption = 'tsMain'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
      end
    end
  end
  object pmLabels: TPopupMenu
    Left = 168
    Top = 8
    object mniAddLanguageContent: TMenuItem
      Caption = 'Add Language Data'
    end
    object mniEditFormTitleByLang: TMenuItem
      Caption = 'Edit Form Title By Language'
    end
  end
end
