inherited frmSetChFasonMarkalar: TfrmSetChFasonMarkalar
  Caption = 'Set Ch Fason Markalar'
  ClientHeight = 311
  ClientWidth = 548
  ExplicitWidth = 564
  ExplicitHeight = 350
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 544
    Height = 259
    ExplicitWidth = 544
    ExplicitHeight = 259
    inherited splLeft: TSplitter
      Height = 169
      ExplicitHeight = 219
    end
    inherited splHeader: TSplitter
      Width = 542
      ExplicitWidth = 554
    end
    inherited pnlLeft: TPanel
      Height = 166
      ExplicitHeight = 138
    end
    inherited pnlHeader: TPanel
      Width = 538
      ExplicitWidth = 538
      inherited edtFilterHelper: TEdit
        Width = 437
        ExplicitWidth = 437
      end
    end
    inherited pnlContent: TPanel
      Width = 433
      Height = 166
      ExplicitWidth = 433
      ExplicitHeight = 166
      inherited grd: TDBGrid
        Width = 431
        Height = 116
      end
      inherited pnlfiltre: TPanel
        Top = 117
        Width = 431
        ExplicitTop = 89
        ExplicitWidth = 431
        inherited pnlfiltre_icerik: TPanel
          Width = 431
          ExplicitWidth = 431
          inherited chkfiltre: TCheckBox
            Width = 300
            ExplicitWidth = 300
          end
          inherited edtfiltre: TEdit
            Width = 300
            ExplicitWidth = 300
          end
        end
      end
    end
    inherited pnlButtons: TPanel
      Top = 206
      Width = 542
      ExplicitTop = 178
      ExplicitWidth = 542
      inherited pnlButtonRight: TPanel
        Left = 357
        ExplicitLeft = 357
      end
      inherited pnlButtonLeft: TPanel
        Width = 357
        ExplicitWidth = 357
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 263
    Width = 544
    ExplicitTop = 263
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
end
