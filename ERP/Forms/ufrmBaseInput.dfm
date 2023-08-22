inherited frmBaseInput: TfrmBaseInput
  ClientWidth = 606
  ExplicitWidth = 620
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 606
    ExplicitWidth = 606
    object pgcMain: TPageControl
      Left = 0
      Top = 0
      Width = 606
      Height = 348
      ActivePage = tsMain
      Align = alClient
      TabOrder = 0
      TabStop = False
      ExplicitWidth = 604
      ExplicitHeight = 344
      object tsMain: TTabSheet
        Caption = 'tsMain'
      end
    end
  end
  inherited pnlBottom: TPanel
    Width = 602
    ExplicitWidth = 602
    inherited btnAccept: TButton
      Left = 396
      ExplicitLeft = 396
    end
    inherited btnClose: TButton
      Left = 500
      ExplicitLeft = 500
    end
  end
  inherited stbBase: TStatusBar
    Width = 606
    ExplicitWidth = 606
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
