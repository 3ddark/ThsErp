inherited frmBaseDetaylarDetay: TfrmBaseDetaylarDetay
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'frmBaseDetaylarDetay'
  ClientHeight = 473
  ClientWidth = 676
  Constraints.MinHeight = 150
  Constraints.MinWidth = 350
  ExplicitWidth = 692
  ExplicitHeight = 512
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 676
    Height = 423
    ExplicitWidth = 670
    ExplicitHeight = 411
    inherited pgcMain: TPageControl
      Width = 676
      Height = 423
      ExplicitWidth = 670
      ExplicitHeight = 411
      inherited tsMain: TTabSheet
        ExplicitWidth = 668
        ExplicitHeight = 395
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 425
    Width = 672
    ExplicitTop = 413
    ExplicitWidth = 666
    inherited btnAccept: TButton
      Left = 466
      ExplicitLeft = 460
    end
    inherited btnClose: TButton
      Left = 570
      ExplicitLeft = 564
    end
  end
  inherited stbBase: TStatusBar
    Top = 455
    Width = 676
    ExplicitTop = 443
    ExplicitWidth = 670
  end
end
