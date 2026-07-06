inherited frmBaseInput: TfrmBaseInput
  ClientHeight = 395
  ClientWidth = 606
  ExplicitHeight = 434
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 606
    Height = 345
    ExplicitWidth = 606
    ExplicitHeight = 345
    object pgcMain: TPageControl
      Left = 0
      Top = 0
      Width = 606
      Height = 345
      ActivePage = tsMain
      Align = alClient
      TabOrder = 0
      TabStop = False
      object tsMain: TTabSheet
        Caption = 'Genel'
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 347
    Width = 602
    ExplicitTop = 347
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
    Top = 377
    Width = 606
    ExplicitTop = 377
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
