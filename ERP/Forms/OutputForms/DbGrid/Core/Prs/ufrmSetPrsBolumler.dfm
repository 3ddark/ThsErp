inherited frmSetPrsBolumler: TfrmSetPrsBolumler
  Caption = 'Personel B'#246'l'#252'mler'
  ClientHeight = 434
  ClientWidth = 793
  ExplicitWidth = 807
  ExplicitHeight = 470
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 793
    Height = 384
    ExplicitWidth = 791
    ExplicitHeight = 381
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
      ExplicitHeight = 305
    end
    inherited pnlHeader: TPanel
      Width = 789
      ExplicitWidth = 787
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 746
        ExplicitWidth = 744
      end
    end
    inherited pnlContent: TPanel
      Width = 690
      Height = 308
      ExplicitWidth = 688
      ExplicitHeight = 305
      inherited grd: TDBGrid
        Width = 690
        Height = 308
      end
    end
    inherited pnlButtons: TPanel
      Top = 344
      Width = 793
      ExplicitTop = 341
      inherited pnlButtonRight: TPanel
        Left = 608
        ExplicitLeft = 606
        ExplicitHeight = 40
      end
      inherited pnlButtonLeft: TPanel
        Width = 608
        ExplicitWidth = 606
        ExplicitHeight = 40
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 386
    Width = 789
    ExplicitTop = 383
    ExplicitWidth = 787
    inherited btnAccept: TButton
      Left = 583
      ExplicitLeft = 581
    end
    inherited btnClose: TButton
      Left = 687
      ExplicitLeft = 685
    end
  end
  inherited stbBase: TStatusBar
    Top = 416
    Width = 793
    ExplicitTop = 413
    ExplicitWidth = 791
  end
end
