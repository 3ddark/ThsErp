inherited frmPrsLisanBilgileri: TfrmPrsLisanBilgileri
  Caption = 'Personel Lisan Bilgileri'
  ClientHeight = 423
  ClientWidth = 745
  ExplicitWidth = 761
  ExplicitHeight = 462
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 745
    Height = 373
    ExplicitWidth = 743
    ExplicitHeight = 370
    inherited splLeft: TSplitter
      Height = 245
      ExplicitHeight = 245
    end
    inherited splHeader: TSplitter
      Width = 745
      ExplicitWidth = 745
    end
    inherited pnlLeft: TPanel
      Height = 245
      ExplicitHeight = 242
    end
    inherited pnlHeader: TPanel
      Width = 741
      ExplicitWidth = 739
      inherited edtFilterHelper: TEdit
        Width = 698
        ExplicitWidth = 696
      end
    end
    inherited pnlContent: TPanel
      Width = 642
      Height = 245
      ExplicitWidth = 640
      ExplicitHeight = 242
      inherited grd: TDBGrid
        Width = 642
        Height = 245
      end
    end
    inherited pnlButtons: TPanel
      Top = 281
      Width = 745
      ExplicitTop = 278
      ExplicitWidth = 743
      inherited pnlButtonRight: TPanel
        Left = 560
        ExplicitLeft = 558
      end
      inherited pnlButtonLeft: TPanel
        Width = 560
        ExplicitWidth = 558
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 375
    Width = 741
    ExplicitTop = 372
    ExplicitWidth = 739
    inherited btnAccept: TButton
      Left = 535
      ExplicitLeft = 533
    end
    inherited btnClose: TButton
      Left = 639
      ExplicitLeft = 637
    end
  end
  inherited stbBase: TStatusBar
    Top = 405
    Width = 745
    ExplicitTop = 402
    ExplicitWidth = 743
  end
end
