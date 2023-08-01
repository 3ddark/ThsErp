inherited frmChHesapPlanlari: TfrmChHesapPlanlari
  Caption = 'Hesap Planlar'#305
  ClientHeight = 517
  ClientWidth = 791
  ExplicitWidth = 807
  ExplicitHeight = 556
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 791
    Height = 467
    ExplicitWidth = 793
    ExplicitHeight = 471
    inherited splLeft: TSplitter
      Height = 343
      ExplicitHeight = 343
    end
    inherited splHeader: TSplitter
      Width = 793
      ExplicitWidth = 793
    end
    inherited pnlLeft: TPanel
      Height = 343
      ExplicitHeight = 343
    end
    inherited pnlHeader: TPanel
      Width = 789
      ExplicitWidth = 789
      inherited edtFilterHelper: TEdit
        Width = 746
        ExplicitWidth = 746
      end
    end
    inherited pnlContent: TPanel
      Width = 690
      Height = 343
      ExplicitWidth = 690
      ExplicitHeight = 343
      inherited grd: TDBGrid
        Width = 690
        Height = 343
      end
    end
    inherited pnlButtons: TPanel
      Top = 379
      Width = 793
      ExplicitTop = 379
      ExplicitWidth = 793
      inherited pnlButtonRight: TPanel
        Left = 608
        ExplicitLeft = 608
      end
      inherited pnlButtonLeft: TPanel
        Width = 608
        ExplicitWidth = 608
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 469
    Width = 787
    ExplicitTop = 473
    ExplicitWidth = 789
    inherited btnAccept: TButton
      Left = 583
      ExplicitLeft = 583
    end
    inherited btnClose: TButton
      Left = 687
      ExplicitLeft = 687
    end
  end
  inherited stbBase: TStatusBar
    Top = 499
    Width = 791
    ExplicitTop = 503
    ExplicitWidth = 793
  end
end
