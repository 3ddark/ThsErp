inherited frmBaseInputDB: TfrmBaseInputDB
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Constraints.MinHeight = 150
  Constraints.MinWidth = 350
  ExplicitWidth = 612
  ExplicitHeight = 427
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitHeight = 348
    inherited pgcMain: TPageControl
      inherited tsMain: TTabSheet
        Caption = 'Genel'
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 598
        ExplicitHeight = 320
      end
    end
  end
  inherited pnlBottom: TPanel
    ExplicitTop = 350
  end
  inherited stbBase: TStatusBar
    ExplicitTop = 380
  end
end
