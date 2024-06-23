inherited frmSetPrsLisanSeviyeleri: TfrmSetPrsLisanSeviyeleri
  Caption = 'Personel Lisan Seviyeleri'
  ClientHeight = 436
  ClientWidth = 795
  ExplicitWidth = 811
  ExplicitHeight = 475
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 795
    Height = 386
    ExplicitWidth = 795
    ExplicitHeight = 386
    inherited splLeft: TSplitter
      Height = 310
      ExplicitHeight = 310
    end
    inherited splHeader: TSplitter
      Width = 795
      ExplicitWidth = 795
    end
    inherited pnlLeft: TPanel
      Height = 310
      ExplicitHeight = 310
    end
    inherited pnlHeader: TPanel
      Width = 791
      ExplicitWidth = 791
      inherited edtFilterHelper: TEdit
        Width = 748
        ExplicitWidth = 748
      end
    end
    inherited pnlContent: TPanel
      Width = 692
      Height = 310
      ExplicitWidth = 692
      ExplicitHeight = 310
      inherited grd: TDBGrid
        Width = 692
        Height = 310
      end
    end
    inherited pnlButtons: TPanel
      Top = 346
      Width = 795
      ExplicitTop = 346
      ExplicitWidth = 795
      inherited pnlButtonRight: TPanel
        Left = 610
        ExplicitLeft = 610
      end
      inherited pnlButtonLeft: TPanel
        Width = 610
        ExplicitWidth = 610
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 388
    Width = 791
    ExplicitTop = 388
    ExplicitWidth = 791
    inherited btnAccept: TButton
      Left = 585
      ExplicitLeft = 585
    end
    inherited btnClose: TButton
      Left = 689
      ExplicitLeft = 689
    end
  end
  inherited stbBase: TStatusBar
    Top = 418
    Width = 795
    ExplicitTop = 418
    ExplicitWidth = 795
  end
end
