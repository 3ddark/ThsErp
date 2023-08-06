inherited frmBaseDetaylarDetay: TfrmBaseDetaylarDetay
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'frmBaseDetaylarDetay'
  ClientHeight = 464
  ClientWidth = 672
  Constraints.MinHeight = 150
  Constraints.MinWidth = 350
  ExplicitWidth = 688
  ExplicitHeight = 503
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 672
    Height = 414
    ExplicitWidth = 670
    ExplicitHeight = 416
    inherited pgcMain: TPageControl
      Width = 674
      Height = 418
      ExplicitWidth = 668
      ExplicitHeight = 414
      inherited tsMain: TTabSheet
        ExplicitWidth = 666
        ExplicitHeight = 390
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 416
    Width = 668
    ExplicitTop = 420
    ExplicitWidth = 670
    inherited btnAccept: TButton
      Left = 461
      ExplicitLeft = 461
    end
    inherited btnClose: TButton
      Left = 565
      ExplicitLeft = 565
    end
  end
  inherited stbBase: TStatusBar
    Top = 446
    Width = 672
    ExplicitTop = 450
    ExplicitWidth = 674
  end
end
