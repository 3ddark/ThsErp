inherited frmBaseStrGrid: TfrmBaseStrGrid
  Caption = 'String Grid Base'
  ClientHeight = 478
  ClientWidth = 820
  ExplicitWidth = 836
  ExplicitHeight = 517
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 820
    Height = 428
    ExplicitWidth = 820
    ExplicitHeight = 428
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
      ExplicitHeight = 389
    end
    inherited pnlHeader: TPanel
      Width = 816
      TabOrder = 0
      ExplicitWidth = 816
    end
    inherited pnlContent: TPanel
      Width = 711
      Height = 389
      ExplicitWidth = 711
      ExplicitHeight = 389
      object strngrdBase: TStringGrid
        Left = 1
        Top = 1
        Width = 709
        Height = 387
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
      Left = 610
      ExplicitLeft = 610
    end
    inherited btnClose: TButton
      Left = 714
      ExplicitLeft = 714
    end
  end
  inherited stbBase: TStatusBar
    Top = 460
    Width = 820
    ExplicitTop = 460
    ExplicitWidth = 820
  end
end
