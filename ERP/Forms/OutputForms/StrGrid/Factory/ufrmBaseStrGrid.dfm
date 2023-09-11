inherited frmBaseStrGrid: TfrmBaseStrGrid
  Caption = 'String Grid Base'
  ClientHeight = 478
  ClientWidth = 820
  ExplicitWidth = 834
  ExplicitHeight = 514
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 820
    Height = 428
    ExplicitWidth = 818
    ExplicitHeight = 425
    inherited splLeft: TSplitter
      Height = 392
      ExplicitHeight = 373
    end
    inherited splHeader: TSplitter
      Width = 820
      ExplicitWidth = 814
    end
    inherited pnlLeft: TPanel
      Height = 389
      TabOrder = 1
      ExplicitHeight = 386
    end
    inherited pnlHeader: TPanel
      Width = 816
      TabOrder = 0
      ExplicitWidth = 814
    end
    inherited pnlContent: TPanel
      Width = 711
      Height = 389
      ExplicitWidth = 709
      ExplicitHeight = 386
      object strngrdBase: TStringGrid
        Left = 1
        Top = 1
        Width = 709
        Height = 387
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 707
        ExplicitHeight = 384
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
    ExplicitTop = 427
    ExplicitWidth = 814
    inherited btnAccept: TButton
      Left = 610
      ExplicitLeft = 608
    end
    inherited btnClose: TButton
      Left = 714
      ExplicitLeft = 712
    end
  end
  inherited stbBase: TStatusBar
    Top = 460
    Width = 820
    ExplicitTop = 457
    ExplicitWidth = 818
  end
end
