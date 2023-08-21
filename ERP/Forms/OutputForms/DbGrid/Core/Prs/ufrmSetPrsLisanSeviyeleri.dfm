inherited frmSetPrsLisanSeviyeleri: TfrmSetPrsLisanSeviyeleri
  Caption = 'Employee Language Levels'
  ClientHeight = 521
  ClientWidth = 795
  ExplicitWidth = 811
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 795
    Height = 471
    ExplicitWidth = 795
    ExplicitHeight = 471
    inherited splHeader: TSplitter
      Width = 795
    end
    inherited pnlLeft: TPanel
      ExplicitHeight = 343
    end
    inherited pnlHeader: TPanel
      Width = 791
      ExplicitWidth = 791
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 748
        ExplicitWidth = 748
      end
    end
    inherited pnlContent: TPanel
      Width = 692
      ExplicitWidth = 692
      ExplicitHeight = 343
      inherited grd: TDBGrid
        Width = 692
      end
    end
    inherited pnlButtons: TPanel
      Width = 795
      ExplicitTop = 379
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
    Top = 473
    Width = 791
    ExplicitTop = 473
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
    Top = 503
    Width = 795
    ExplicitTop = 503
    ExplicitWidth = 795
  end
end
