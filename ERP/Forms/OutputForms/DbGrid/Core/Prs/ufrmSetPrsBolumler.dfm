inherited frmSetPrsBolumler: TfrmSetPrsBolumler
  Caption = 'Personel B'#246'l'#252'mler'
  ClientHeight = 434
  ClientWidth = 793
  ExplicitWidth = 809
  ExplicitHeight = 473
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 793
    Height = 384
    ExplicitWidth = 793
    ExplicitHeight = 384
    inherited splLeft: TSplitter
      Height = 308
      ExplicitHeight = 340
    end
    inherited splHeader: TSplitter
      Width = 793
      ExplicitWidth = 793
    end
    inherited pnlLeft: TPanel
      Height = 308
      ExplicitHeight = 308
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
      Height = 308
      ExplicitWidth = 690
      ExplicitHeight = 308
      inherited grd: TDBGrid
        Width = 690
        Height = 308
      end
    end
    inherited pnlButtons: TPanel
      Top = 344
      Width = 793
      ExplicitTop = 344
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
    Top = 386
    Width = 789
    ExplicitTop = 386
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
    Top = 416
    Width = 793
    ExplicitTop = 416
    ExplicitWidth = 793
  end
end
