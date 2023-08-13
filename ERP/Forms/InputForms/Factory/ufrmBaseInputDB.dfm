inherited frmBaseInputDB: TfrmBaseInputDB
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 398
  Constraints.MinHeight = 150
  Constraints.MinWidth = 350
  ExplicitHeight = 437
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 348
    ExplicitHeight = 352
    inherited pgcMain: TPageControl
      Height = 352
      ExplicitHeight = 352
      inherited tsMain: TTabSheet
        ExplicitHeight = 324
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 350
    ExplicitTop = 354
  end
  inherited stbBase: TStatusBar
    Top = 380
    ExplicitTop = 384
  end
end
