inherited frmBaseDetaylarDetay: TfrmBaseDetaylarDetay
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'frmBaseDetaylarDetay'
  ClientHeight = 468
  ClientWidth = 674
  Constraints.MinHeight = 150
  Constraints.MinWidth = 350
  ExplicitWidth = 690
  ExplicitHeight = 507
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 674
    Height = 418
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
