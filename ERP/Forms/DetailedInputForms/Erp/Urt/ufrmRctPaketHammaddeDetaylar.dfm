inherited frmRctPaketHammaddeDetaylar: TfrmRctPaketHammaddeDetaylar
  Caption = 'Re'#231'ete Detaylar'#305
  ClientHeight = 561
  ClientWidth = 783
  ExplicitWidth = 799
  ExplicitHeight = 600
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 779
    Height = 509
    ExplicitWidth = 779
    ExplicitHeight = 495
    inherited splLeft: TSplitter
      Top = 45
      Height = 463
      ExplicitTop = 437
      ExplicitHeight = 502
    end
    inherited splHeader: TSplitter
      Top = 42
      Width = 777
      ExplicitLeft = 0
      ExplicitTop = 74
      ExplicitWidth = 973
    end
    inherited pgcMain: TPageControl
      Top = 45
      Width = 671
      Height = 463
      ExplicitTop = 109
      ExplicitWidth = 671
      ExplicitHeight = 385
      inherited tsMain: TTabSheet
        ExplicitWidth = 663
        ExplicitHeight = 357
      end
    end
    inherited pnlHeader: TPanel
      Width = 773
      Height = 38
      ExplicitWidth = 773
      ExplicitHeight = 38
      inherited pgcHeader: TPageControl
        Width = 771
        Height = 36
        ExplicitWidth = 771
        ExplicitHeight = 100
        inherited tsHeader: TTabSheet
          Caption = 'Genel'
          ExplicitLeft = 24
          ExplicitTop = 4
          ExplicitWidth = 743
          ExplicitHeight = 92
          object lblpaket_adi: TLabel
            Left = 80
            Top = 7
            Width = 50
            Height = 13
            Alignment = taRightJustify
            Caption = #220'r'#252'n Ad'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object edtpaket_adi: TEdit
            Left = 131
            Top = 4
            Width = 454
            Height = 21
            TabOrder = 0
          end
        end
        inherited tsHeaderDiger: TTabSheet
          ExplicitLeft = 24
          ExplicitTop = 4
          ExplicitWidth = 743
          ExplicitHeight = 92
        end
      end
    end
    inherited pnlContent: TPanel
      Top = 45
      Width = 671
      Height = 463
      ExplicitTop = 109
      ExplicitWidth = 671
      ExplicitHeight = 385
      inherited pgcContent: TPageControl
        Width = 669
        Height = 459
        ExplicitWidth = 669
        ExplicitHeight = 381
        inherited ts1: TTabSheet
          ExplicitLeft = 4
          ExplicitTop = 24
          ExplicitWidth = 661
          ExplicitHeight = 353
          inherited pnl1: TPanel
            Top = 351
            Width = 661
            Height = 66
            ExplicitTop = 287
            ExplicitWidth = 661
            ExplicitHeight = 66
            inherited grpGenelToplamKalan: TGroupBox
              Left = 191
              Height = 62
              Visible = False
              ExplicitLeft = 191
              ExplicitHeight = 62
            end
            inherited grpGenelToplam: TGroupBox
              Left = 426
              Height = 62
              ExplicitLeft = 426
              ExplicitHeight = 62
              inherited lblToplamTutar: TLabel
                Caption = 'Toplam Maliyet'
              end
              inherited lblToplamIskontoTutar: TLabel
                Visible = False
              end
              inherited lblValToplamIskontoTutar: TLabel
                Visible = False
              end
              inherited lblAraToplam: TLabel
                Visible = False
              end
              inherited lblValAraToplam: TLabel
                Visible = False
              end
              inherited lblToplamKDVTutar: TLabel
                Visible = False
              end
              inherited lblValToplamKDVTutar: TLabel
                Visible = False
              end
              inherited lblGenelToplam: TLabel
                Visible = False
              end
              inherited lblValGenelToplam: TLabel
                Visible = False
              end
            end
            inherited flwpnl1: TFlowPanel
              Width = 189
              Height = 66
              ExplicitWidth = 189
              ExplicitHeight = 66
            end
          end
          inherited strngrd1: TStringGrid
            Width = 661
            Height = 351
            ExplicitWidth = 661
            ExplicitHeight = 351
          end
        end
        inherited ts2: TTabSheet
          ExplicitLeft = 4
          ExplicitTop = 24
          ExplicitWidth = 661
          ExplicitHeight = 353
          inherited pnl2: TPanel
            Top = 351
            Width = 661
            Height = 66
            ExplicitTop = 287
            ExplicitWidth = 661
            ExplicitHeight = 66
            inherited flwpnl2: TFlowPanel
              Width = 655
              Height = 60
              ExplicitWidth = 655
              ExplicitHeight = 60
            end
          end
          inherited strngrd2: TStringGrid
            Width = 661
            Height = 351
            ExplicitWidth = 661
            ExplicitHeight = 287
          end
        end
        inherited ts3: TTabSheet
          ExplicitLeft = 4
          ExplicitTop = 24
          ExplicitWidth = 661
          ExplicitHeight = 353
          inherited strngrd3: TStringGrid
            Width = 661
            Height = 351
            ExplicitWidth = 661
            ExplicitHeight = 287
          end
          inherited pnl3: TPanel
            Top = 351
            Width = 661
            Height = 66
            ExplicitTop = 287
            ExplicitWidth = 661
            ExplicitHeight = 66
            inherited flwpnl3: TFlowPanel
              Width = 655
              Height = 60
              ExplicitWidth = 655
              ExplicitHeight = 60
            end
          end
        end
      end
      inherited btnHeaderShowHide: TButton
        Left = 566
        Width = 100
        ExplicitLeft = 566
        ExplicitWidth = 100
      end
    end
    inherited pnlLeft: TPanel
      Top = 46
      Height = 460
      ExplicitTop = 110
      ExplicitHeight = 382
    end
  end
  inherited pnlBottom: TPanel
    Top = 513
    Width = 779
    ExplicitTop = 499
    ExplicitWidth = 779
    inherited btnAccept: TButton
      Left = 570
      ExplicitLeft = 570
    end
    inherited btnClose: TButton
      Left = 674
      ExplicitLeft = 674
    end
  end
  inherited stbBase: TStatusBar
    Top = 543
    Width = 783
    ExplicitTop = 543
    ExplicitWidth = 783
  end
  inherited frxrprtBase: TfrxReport
    ScriptText.Strings = ()
  end
end
