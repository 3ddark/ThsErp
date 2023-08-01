inherited frmSysApplicationSettingsOther: TfrmSysApplicationSettingsOther
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'System Application Settings Other'
  ClientHeight = 440
  ClientWidth = 669
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 685
  ExplicitHeight = 479
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 669
    Height = 390
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 669
    ExplicitHeight = 390
    inherited pgcMain: TPageControl
      Width = 669
      Height = 390
      ExplicitWidth = 669
      ExplicitHeight = 390
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 661
        ExplicitHeight = 360
        object lblpath_stock_image: TLabel
          Left = 30
          Top = 5
          Width = 124
          Height = 13
          Alignment = taRightJustify
          Caption = 'Stok Card Image Path'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblpath_update: TLabel
          Left = 62
          Top = 29
          Width = 92
          Height = 13
          Alignment = taRightJustify
          Caption = 'Update File Path'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtpath_stock_image: TEdit
          Left = 160
          Top = 2
          Width = 462
          Height = 23
          TabOrder = 0
        end
        object btnpath_stock_image: TButton
          Left = 624
          Top = 2
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 1
          OnClick = btnpath_stock_imageClick
        end
        object edtpath_update: TEdit
          Left = 160
          Top = 26
          Width = 462
          Height = 23
          TabOrder = 2
        end
        object btnpath_update: TButton
          Left = 624
          Top = 26
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 3
          OnClick = btnpath_updateClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 392
    Width = 665
    ExplicitTop = 392
    ExplicitWidth = 665
    inherited btnAccept: TButton
      Left = 459
      ExplicitLeft = 459
    end
    inherited btnClose: TButton
      Left = 563
      ExplicitLeft = 563
    end
  end
  inherited stbBase: TStatusBar
    Top = 422
    Width = 669
    ExplicitTop = 422
    ExplicitWidth = 669
  end
end
