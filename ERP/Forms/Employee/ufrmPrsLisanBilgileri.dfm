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
    ExplicitWidth = 745
    ExplicitHeight = 373
    inherited splLeft: TSplitter
      Height = 297
      ExplicitHeight = 245
    end
    inherited splHeader: TSplitter
      Width = 745
      ExplicitWidth = 745
    end
    inherited pnlLeft: TPanel
      Height = 297
      ExplicitHeight = 297
    end
    inherited pnlHeader: TPanel
      Width = 741
      ExplicitWidth = 741
      inherited edtFilterHelper: TEdit
        Width = 698
        ExplicitWidth = 698
      end
    end
    inherited pnlContent: TPanel
      Width = 642
      Height = 297
      ExplicitWidth = 642
      ExplicitHeight = 297
      inherited grd: TDBGrid
        Width = 642
        Height = 297
      end
    end
    inherited pnlButtons: TPanel
      Top = 333
      Width = 745
      ExplicitTop = 333
      ExplicitWidth = 745
      inherited pnlButtonRight: TPanel
        Left = 560
        ExplicitLeft = 560
      end
      inherited pnlButtonLeft: TPanel
        Width = 560
        ExplicitWidth = 560
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 375
    Width = 741
    ExplicitTop = 375
    ExplicitWidth = 741
    inherited btnAccept: TButton
      Left = 535
      ExplicitLeft = 535
    end
    inherited btnClose: TButton
      Left = 639
      ExplicitLeft = 639
    end
  end
  inherited stbBase: TStatusBar
    Top = 405
    Width = 745
    ExplicitTop = 405
    ExplicitWidth = 745
  end
end
