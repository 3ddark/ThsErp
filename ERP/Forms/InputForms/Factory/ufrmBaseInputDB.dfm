inherited frmBaseInputDB: TfrmBaseInputDB
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 401
  Constraints.MinHeight = 150
  Constraints.MinWidth = 350
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 351
    ExplicitHeight = 348
    inherited pgcMain: TPageControl
      inherited tsMain: TTabSheet
        Caption = 'Genel'
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 353
    ExplicitTop = 350
  end
  inherited stbBase: TStatusBar
    Top = 383
    ExplicitTop = 380
  end
end
