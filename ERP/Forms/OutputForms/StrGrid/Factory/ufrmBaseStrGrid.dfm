inherited frmBaseStrGrid: TfrmBaseStrGrid
  Caption = 'String Grid Base'
  ClientHeight = 478
  ClientWidth = 820
  ExplicitWidth = 836
  ExplicitHeight = 517
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 816
    Height = 426
    ExplicitWidth = 816
    ExplicitHeight = 426
    inherited splLeft: TSplitter
      Height = 388
      ExplicitHeight = 373
    end
    inherited splHeader: TSplitter
      Width = 814
      ExplicitWidth = 814
    end
    inherited pnlLeft: TPanel
      Height = 385
      ExplicitHeight = 385
    end
    inherited pnlHeader: TPanel
      Width = 810
      ExplicitWidth = 810
    end
    inherited pnlContent: TPanel
      Width = 705
      Height = 385
      ExplicitWidth = 705
      ExplicitHeight = 385
      object strngrdBase: TStringGrid
        Left = 1
        Top = 1
        Width = 703
        Height = 383
        Align = alClient
        TabOrder = 0
        ColWidths = (
          64
          64
          64
          64
          64)
        RowHeights = (
          24
          24
          24
          24
          24)
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 430
    Width = 816
    ExplicitTop = 430
    ExplicitWidth = 816
    inherited btnAccept: TButton
      Left = 607
      ExplicitLeft = 607
    end
    inherited btnClose: TButton
      Left = 711
      ExplicitLeft = 711
    end
  end
  inherited stbBase: TStatusBar
    Top = 460
    Width = 820
    ExplicitTop = 460
    ExplicitWidth = 820
  end
end
