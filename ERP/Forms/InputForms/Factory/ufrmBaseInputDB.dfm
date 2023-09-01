inherited frmBaseInputDB: TfrmBaseInputDB
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 401
  Constraints.MinHeight = 150
  Constraints.MinWidth = 350
  ExplicitWidth = 612
  ExplicitHeight = 430
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 351
    ExplicitHeight = 351
    inherited pgcMain: TPageControl
      Height = 351
      ExplicitHeight = 351
      inherited tsMain: TTabSheet
        Caption = 'Genel'
        ExplicitHeight = 323
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 353
    ExplicitTop = 353
  end
  inherited stbBase: TStatusBar
    Top = 383
    ExplicitTop = 383
  end
end
