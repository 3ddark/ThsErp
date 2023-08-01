inherited frmRctPaketHammaddeDetaylar: TfrmRctPaketHammaddeDetaylar
  Caption = 'Re'#231'ete Detaylar'#305
  ClientHeight = 557
  ClientWidth = 781
  ExplicitWidth = 797
  ExplicitHeight = 596
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 781
    Height = 507
    ExplicitWidth = 783
    ExplicitHeight = 511
    inherited splLeft: TSplitter
      Top = 44
      Height = 467
      ExplicitTop = 437
      ExplicitHeight = 502
    end
    inherited splHeader: TSplitter
      Top = 41
      Width = 783
      ExplicitLeft = 0
      ExplicitTop = 74
      ExplicitWidth = 973
    end
    inherited pgcMain: TPageControl
      Top = 44
      Width = 677
      Height = 467
      ExplicitTop = 44
      ExplicitWidth = 677
      ExplicitHeight = 467
      inherited tsMain: TTabSheet
        ExplicitWidth = 669
        ExplicitHeight = 439
      end
    end
    inherited pnlHeader: TPanel
      Width = 779
      Height = 38
      ExplicitWidth = 779
      ExplicitHeight = 38
      inherited pgcHeader: TPageControl
        Width = 777
        Height = 36
        ExplicitWidth = 777
        ExplicitHeight = 36
        inherited tsHeader: TTabSheet
          Caption = 'Genel'
          ExplicitLeft = 44
          ExplicitWidth = 729
          ExplicitHeight = 28
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
          ExplicitLeft = 44
          ExplicitWidth = 729
          ExplicitHeight = 28
        end
      end
    end
    inherited pnlContent: TPanel
      Top = 44
      Width = 677
      Height = 467
      ExplicitTop = 44
      ExplicitWidth = 677
      ExplicitHeight = 467
      inherited pgcContent: TPageControl
        Width = 675
        Height = 463
        ExplicitWidth = 675
        ExplicitHeight = 463
        inherited ts1: TTabSheet
          ExplicitWidth = 667
          ExplicitHeight = 435
          inherited pnl1: TPanel
            Top = 369
            Width = 667
            Height = 66
            ExplicitTop = 369
            ExplicitWidth = 667
            ExplicitHeight = 66
            inherited grpGenelToplamKalan: TGroupBox
              Left = 197
              Height = 62
              Visible = False
              ExplicitLeft = 197
              ExplicitHeight = 62
            end
            inherited grpGenelToplam: TGroupBox
              Left = 432
              Height = 62
              ExplicitLeft = 432
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
              Width = 195
              Height = 66
              ExplicitWidth = 195
              ExplicitHeight = 66
            end
          end
          inherited strngrd1: TStringGrid
            Width = 667
            Height = 369
            ExplicitWidth = 667
            ExplicitHeight = 369
          end
        end
        inherited ts2: TTabSheet
          ExplicitWidth = 667
          ExplicitHeight = 435
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
          ExplicitWidth = 667
          ExplicitHeight = 435
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
        Left = 564
        Width = 100
        ExplicitLeft = 566
        ExplicitWidth = 100
      end
    end
    inherited pnlLeft: TPanel
      Top = 45
      Height = 464
      ExplicitTop = 45
      ExplicitHeight = 464
    end
  end
  inherited pnlBottom: TPanel
    Top = 509
    Width = 777
    ExplicitTop = 513
    ExplicitWidth = 779
    inherited btnAccept: TButton
      Left = 573
      ExplicitLeft = 573
    end
    inherited btnClose: TButton
      Left = 677
      ExplicitLeft = 677
    end
  end
  inherited stbBase: TStatusBar
    Top = 539
    Width = 781
    ExplicitTop = 543
    ExplicitWidth = 783
  end
end
