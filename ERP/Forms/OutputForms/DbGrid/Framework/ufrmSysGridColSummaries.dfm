inherited frmSysGridColSummaries: TfrmSysGridColSummaries
  Caption = 'Grid Column Summaries'
  ClientHeight = 311
  ClientWidth = 548
  ExplicitWidth = 564
  ExplicitHeight = 350
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 544
    Height = 245
    ExplicitWidth = 544
    ExplicitHeight = 245
    inherited splLeft: TSplitter
      Height = 127
      ExplicitHeight = 219
    end
    inherited splHeader: TSplitter
      Width = 542
      ExplicitWidth = 554
    end
    inherited pnlLeft: TPanel
      Height = 124
      ExplicitHeight = 124
    end
    inherited pnlHeader: TPanel
      Width = 538
      ExplicitWidth = 538
    end
    inherited pnlContent: TPanel
      Width = 433
      Height = 124
      ExplicitWidth = 433
      ExplicitHeight = 124
      inherited grdBase: TcxGrid
        Width = 431
        Height = 122
        ExplicitWidth = 431
        ExplicitHeight = 122
      end
    end
    inherited pnlButtons: TPanel
      Top = 164
      Width = 542
      ExplicitTop = 164
      ExplicitWidth = 542
    end
  end
  inherited pnlBottom: TPanel
    Top = 249
    Width = 544
    ExplicitTop = 249
    ExplicitWidth = 544
    inherited btnAccept: TButton
      Left = 335
      ExplicitLeft = 335
    end
    inherited btnClose: TButton
      Left = 439
      ExplicitLeft = 439
    end
  end
  inherited stbBase: TStatusBar
    Top = 293
    Width = 548
    ExplicitTop = 293
    ExplicitWidth = 548
  end
  inherited frxrprtBase: TfrxReport
    ScriptText.Strings = ()
  end
  inherited cxEditRepository1: TcxEditRepository
    PixelsPerInch = 96
  end
  inherited cxStyleRepository1: TcxStyleRepository
    PixelsPerInch = 96
  end
end
