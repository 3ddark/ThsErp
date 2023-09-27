inherited frmBaseInput: TfrmBaseInput
  ClientHeight = 395
  ClientWidth = 606
  ExplicitWidth = 620
  ExplicitHeight = 431
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 606
    Height = 345
    ExplicitWidth = 604
    ExplicitHeight = 342
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
    ExplicitTop = 344
    ExplicitWidth = 600
    inherited btnAccept: TButton
      Left = 396
      ExplicitLeft = 394
    end
    inherited btnClose: TButton
      Left = 500
      ExplicitLeft = 498
    end
  end
  inherited stbBase: TStatusBar
    Top = 377
    Width = 606
    ExplicitTop = 374
    ExplicitWidth = 604
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
