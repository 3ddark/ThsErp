inherited frmSetPrsLisanSeviyeleri: TfrmSetPrsLisanSeviyeleri
  Caption = 'Personel Lisan Seviyeleri'
  ClientHeight = 436
  ClientWidth = 795
  ExplicitWidth = 809
  ExplicitHeight = 472
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 795
    Height = 386
    ExplicitWidth = 793
    ExplicitHeight = 383
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
      ExplicitHeight = 307
    end
    inherited pnlHeader: TPanel
      Width = 791
      ExplicitWidth = 789
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 748
        ExplicitWidth = 746
      end
    end
    inherited pnlContent: TPanel
      Width = 692
      Height = 310
      ExplicitWidth = 690
      ExplicitHeight = 307
      inherited grd: TDBGrid
        Width = 692
        Height = 310
      end
    end
    inherited pnlButtons: TPanel
      Top = 346
      Width = 795
      ExplicitTop = 343
      ExplicitWidth = 793
      inherited pnlButtonRight: TPanel
        Left = 610
        ExplicitLeft = 608
        ExplicitHeight = 40
      end
      inherited pnlButtonLeft: TPanel
        Width = 610
        ExplicitWidth = 608
        ExplicitHeight = 40
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 388
    Width = 791
    ExplicitTop = 385
    ExplicitWidth = 789
    inherited btnAccept: TButton
      Left = 585
      ExplicitLeft = 583
    end
    inherited btnClose: TButton
      Left = 689
      ExplicitLeft = 687
    end
  end
  inherited stbBase: TStatusBar
    Top = 418
    Width = 795
    ExplicitTop = 415
    ExplicitWidth = 793
  end
end
