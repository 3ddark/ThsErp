inherited frmSatTeklifler: TfrmSatTeklifler
  Caption = 'Sat'#305#351' Teklifler'
  ClientHeight = 561
  ClientWidth = 807
  ExplicitWidth = 823
  ExplicitHeight = 600
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 807
    Height = 511
    ExplicitWidth = 807
    ExplicitHeight = 511
    inherited splLeft: TSplitter
      Height = 435
      ExplicitHeight = 435
    end
    inherited splHeader: TSplitter
      Width = 807
      ExplicitWidth = 807
    end
    inherited pnlLeft: TPanel
      Height = 435
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
      Height = 435
      ExplicitWidth = 704
      ExplicitHeight = 435
      inherited grd: TDBGrid
        Width = 704
        Height = 435
      end
    end
    inherited pnlButtons: TPanel
      Top = 471
      Width = 807
      ExplicitTop = 471
      ExplicitWidth = 807
      inherited pnlButtonRight: TPanel
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 185
          Height = 40
          Align = alClient
          Caption = 'H'#305'zl'#305' Filtre'
          Items.Strings = (
            'Bekleyenler'
            'Sipari'#351' Olanlar'
            'T'#252'm'#252)
          TabOrder = 0
          OnClick = HizliFiltre
        end
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
