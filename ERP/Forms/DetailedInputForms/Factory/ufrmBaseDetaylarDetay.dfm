inherited frmBaseDetaylarDetay: TfrmBaseDetaylarDetay
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'frmBaseDetaylarDetay'
  ClientHeight = 468
  ClientWidth = 674
  Constraints.MinHeight = 150
  Constraints.MinWidth = 350
  ExplicitWidth = 680
  ExplicitHeight = 497
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 670
    Height = 416
    ExplicitWidth = 670
    ExplicitHeight = 416
    inherited pgcMain: TPageControl
      Width = 668
      Height = 414
      ExplicitWidth = 668
      ExplicitHeight = 414
    end
  end
  inherited pnlBottom: TPanel
    Top = 420
    Width = 670
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
    Top = 450
    Width = 674
    ExplicitTop = 450
    ExplicitWidth = 674
  end
end
