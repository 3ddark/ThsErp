inherited frmCinsAileleri: TfrmCinsAileleri
  Caption = 'Cins Aileleri'
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
    ExplicitHeight = 272
    inherited splLeft: TSplitter
      Height = 80
      ExplicitHeight = 219
    end
    inherited splHeader: TSplitter
      Width = 542
      ExplicitWidth = 554
    end
    inherited pnlLeft: TPanel
      Height = 100
      ExplicitHeight = 100
    end
    inherited pnlHeader: TPanel
      Width = 538
      ExplicitWidth = 538
    end
    inherited pnlContent: TPanel
      Width = 433
      Height = 77
      ExplicitWidth = 433
      ExplicitHeight = 75
      inherited dbgrdBase: TDBGrid
        Width = 431
        Height = 75
      end
    end
    inherited pnlButtons: TPanel
      Top = 117
      Width = 542
      ExplicitTop = 115
      ExplicitWidth = 542
      inherited pnlFilter: TPanel
        Width = 542
        ExplicitWidth = 542
        inherited imgFilterRemove: TImage
          Left = 468
          ExplicitLeft = 468
        end
        inherited imgFilter: TImage
          Left = 430
          ExplicitLeft = 430
        end
        inherited imgFilterBack: TImage
          Left = 506
          ExplicitLeft = 506
        end
        inherited pnlFilterContainer: TPanel
          Width = 426
          ExplicitWidth = 426
        end
      end
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
end
