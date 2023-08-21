inherited frmSetPrsLisanBilgileri: TfrmSetPrsLisanBilgileri
  Caption = 'Personel Lisan Bilgileri'
  ClientHeight = 423
  ClientWidth = 745
  ExplicitWidth = 761
  ExplicitHeight = 462
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 745
    Height = 373
    ExplicitHeight = 468
    inherited splLeft: TSplitter
      Height = 245
    end
    inherited splHeader: TSplitter
      Width = 745
    end
    inherited pnlLeft: TPanel
      Height = 245
      ExplicitHeight = 340
    end
    inherited pnlHeader: TPanel
      Width = 741
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 698
      end
    end
    inherited pnlContent: TPanel
      Width = 642
      Height = 245
      ExplicitHeight = 340
      inherited grd: TDBGrid
        Width = 642
        Height = 245
      end
    end
    inherited pnlButtons: TPanel
      Top = 281
      Width = 745
      ExplicitTop = 376
      inherited pnlButtonRight: TPanel
        Left = 560
      end
      inherited pnlButtonLeft: TPanel
        Width = 560
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 375
    Width = 741
    ExplicitTop = 470
    inherited btnAccept: TButton
      Left = 535
    end
    inherited btnClose: TButton
      Left = 639
    end
  end
  inherited stbBase: TStatusBar
    Top = 405
    Width = 745
    ExplicitTop = 500
  end
end
