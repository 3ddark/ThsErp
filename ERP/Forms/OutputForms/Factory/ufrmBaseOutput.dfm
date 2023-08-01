inherited frmBaseOutput: TfrmBaseOutput
  Caption = 'Output Base Form'
  ClientHeight = 407
  ClientWidth = 663
  ExplicitWidth = 677
  ExplicitHeight = 442
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 663
    Height = 357
    ExplicitWidth = 661
    ExplicitHeight = 353
    object splLeft: TSplitter
      Left = 103
      Top = 36
      Height = 321
      Beveled = True
      Color = clBtnFace
      ParentColor = False
      ExplicitLeft = 101
      ExplicitTop = 34
      ExplicitHeight = 213
    end
    object splHeader: TSplitter
      Left = 0
      Top = 33
      Width = 663
      Height = 3
      Cursor = crVSplit
      Align = alTop
      Beveled = True
      Color = clBtnFace
      ParentColor = False
      ExplicitLeft = 1
      ExplicitTop = 34
      ExplicitWidth = 484
    end
    object pnlLeft: TPanel
      AlignWithMargins = True
      Left = 2
      Top = 37
      Width = 100
      Height = 318
      Margins.Left = 2
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 2
      Align = alLeft
      Caption = 'pnlLeft'
      Constraints.MinHeight = 100
      Constraints.MinWidth = 100
      TabOrder = 0
      ExplicitHeight = 314
    end
    object pnlHeader: TPanel
      AlignWithMargins = True
      Left = 2
      Top = 2
      Width = 659
      Height = 30
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 1
      Align = alTop
      Caption = 'Panel1'
      Constraints.MinHeight = 30
      TabOrder = 1
      ExplicitWidth = 657
    end
    object pnlContent: TPanel
      AlignWithMargins = True
      Left = 107
      Top = 37
      Width = 554
      Height = 318
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      TabOrder = 2
      ExplicitWidth = 552
      ExplicitHeight = 314
    end
  end
  inherited pnlBottom: TPanel
    Top = 359
    Width = 659
    ExplicitTop = 355
    ExplicitWidth = 657
    inherited btnAccept: TButton
      Left = 453
      ExplicitLeft = 451
    end
    inherited btnClose: TButton
      Left = 557
      ExplicitLeft = 555
    end
  end
  inherited stbBase: TStatusBar
    Top = 389
    Width = 663
    ExplicitTop = 385
    ExplicitWidth = 661
  end
  object pmDB: TPopupMenu [4]
    Left = 208
    Top = 128
  end
end
