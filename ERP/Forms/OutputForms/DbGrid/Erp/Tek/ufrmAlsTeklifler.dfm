inherited frmAlsTeklifler: TfrmAlsTeklifler
  Caption = 'Sat'#305'n Alma Teklifler'
  ClientHeight = 561
  ClientWidth = 807
  ExplicitWidth = 823
  ExplicitHeight = 600
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 807
    Height = 511
    ExplicitWidth = 807
    ExplicitHeight = 511
    inherited splLeft: TSplitter
      Height = 404
      ExplicitHeight = 404
    end
    inherited splHeader: TSplitter
      Width = 807
      ExplicitWidth = 807
    end
    inherited pnlLeft: TPanel
      Height = 404
      ExplicitHeight = 435
    end
    inherited pnlHeader: TPanel
      Width = 803
      ExplicitWidth = 803
      inherited edtFilterHelper: TEdit
        Width = 760
        ExplicitWidth = 760
      end
    end
    inherited pnlContent: TPanel
      Width = 704
      Height = 404
      ExplicitWidth = 704
      ExplicitHeight = 435
      inherited grd: TDBGrid
        Width = 704
        Height = 404
      end
    end
    inherited pnlButtons: TPanel
      Top = 440
      Width = 807
      Height = 71
      ExplicitTop = 440
      ExplicitWidth = 807
      ExplicitHeight = 71
      inherited pnlButtonRight: TPanel
        Left = 672
        Width = 135
        Height = 71
        ExplicitLeft = 672
        ExplicitWidth = 135
        ExplicitHeight = 71
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 135
          Height = 71
          Align = alClient
          Caption = 'H'#305'zl'#305' Filtre'
          Items.Strings = (
            'Bekleyenler'
            'Sipari'#351' Olanlar'
            'T'#252'm'#252)
          TabOrder = 0
          OnClick = HizliFiltre
          ExplicitWidth = 185
          ExplicitHeight = 40
        end
      end
      inherited pnlButtonLeft: TPanel
        Width = 672
        Height = 71
        ExplicitWidth = 622
        ExplicitHeight = 40
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 513
    Width = 803
    ExplicitTop = 513
    ExplicitWidth = 803
    inherited btnAccept: TButton
      Left = 597
      ExplicitLeft = 597
    end
    inherited btnClose: TButton
      Left = 701
      ExplicitLeft = 701
    end
  end
  inherited stbBase: TStatusBar
    Top = 543
    Width = 807
    ExplicitTop = 543
    ExplicitWidth = 807
  end
  inherited pmDB: TPopupMenu
    object mniSipariseAktar: TMenuItem [2]
      Caption = 'Sipari'#351'e Aktar'
      ImageIndex = 88
      OnClick = mniSipariseAktarClick
    end
  end
end
