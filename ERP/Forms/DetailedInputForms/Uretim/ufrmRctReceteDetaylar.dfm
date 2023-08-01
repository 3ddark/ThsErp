inherited frmRctReceteDetaylar: TfrmRctReceteDetaylar
  Caption = 'Re'#231'ete Detaylar'#305
  ClientHeight = 545
  ClientWidth = 775
  ExplicitWidth = 791
  ExplicitHeight = 584
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 775
    Height = 495
    ExplicitWidth = 783
    ExplicitHeight = 511
    inherited splLeft: TSplitter
      Top = 108
      Height = 391
      ExplicitTop = 437
      ExplicitHeight = 502
    end
    inherited splHeader: TSplitter
      Top = 105
      Width = 777
      ExplicitLeft = 0
      ExplicitTop = 74
      ExplicitWidth = 973
    end
    inherited pgcMain: TPageControl
      Top = 108
      Width = 671
      Height = 391
      ExplicitTop = 108
      ExplicitWidth = 677
      ExplicitHeight = 403
      inherited tsMain: TTabSheet
        ExplicitWidth = 663
        ExplicitHeight = 363
      end
    end
    inherited pnlHeader: TPanel
      Width = 773
      Height = 102
      ExplicitWidth = 779
      ExplicitHeight = 102
      inherited pgcHeader: TPageControl
        Width = 771
        Height = 100
        ExplicitWidth = 777
        ExplicitHeight = 100
        inherited tsHeader: TTabSheet
          Caption = 'Genel'
          ExplicitWidth = 743
          ExplicitHeight = 92
          object lblurun_kodu: TLabel
            Left = 69
            Top = 5
            Width = 61
            Height = 13
            Alignment = taRightJustify
            Caption = #220'r'#252'n Kodu'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblurun_adi: TLabel
            Left = 80
            Top = 27
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
          object lblornek_uretm_miktari: TLabel
            Left = 13
            Top = 49
            Width = 117
            Height = 13
            Alignment = taRightJustify
            Caption = #214'rnek '#220'retim Miktar'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblaciklama: TLabel
            Left = 78
            Top = 71
            Width = 52
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'A'#231#305'klama'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object edtrecete_kodu: TEdit
            Left = 131
            Top = 2
            Width = 150
            Height = 21
            TabOrder = 0
          end
          object edtrecete_adi: TEdit
            Left = 131
            Top = 24
            Width = 443
            Height = 21
            TabOrder = 1
          end
          object edtornek_uretm_miktari: TEdit
            Left = 131
            Top = 46
            Width = 78
            Height = 21
            TabOrder = 2
          end
          object edtaciklama: TEdit
            Left = 131
            Top = 68
            Width = 443
            Height = 21
            TabOrder = 3
          end
        end
        inherited tsHeaderDiger: TTabSheet
          ExplicitWidth = 743
          ExplicitHeight = 92
        end
      end
    end
    inherited pnlContent: TPanel
      Top = 108
      Width = 671
      Height = 391
      ExplicitTop = 108
      ExplicitWidth = 677
      ExplicitHeight = 403
      inherited pgcContent: TPageControl
        Width = 669
        Height = 387
        OnChange = pgcContentChange
        ExplicitWidth = 675
        ExplicitHeight = 399
        inherited ts1: TTabSheet
          ExplicitWidth = 661
          ExplicitHeight = 359
          inherited pnl1: TPanel
            Top = 305
            Width = 667
            Height = 66
            ExplicitTop = 305
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
            Height = 305
            ExplicitWidth = 667
            ExplicitHeight = 305
          end
        end
        inherited ts2: TTabSheet
          ExplicitWidth = 661
          ExplicitHeight = 359
          inherited pnl2: TPanel
            Top = 301
            Width = 661
            Height = 66
            ExplicitTop = 301
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
            Height = 301
            ExplicitWidth = 661
            ExplicitHeight = 301
          end
        end
        inherited ts3: TTabSheet
          ExplicitWidth = 661
          ExplicitHeight = 359
          inherited strngrd3: TStringGrid
            Width = 661
            Height = 301
            ExplicitWidth = 661
            ExplicitHeight = 301
          end
          inherited pnl3: TPanel
            Top = 301
            Width = 661
            Height = 66
            ExplicitTop = 301
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
        Left = 558
        Width = 100
        ExplicitLeft = 566
        ExplicitWidth = 100
      end
    end
    inherited pnlLeft: TPanel
      Top = 109
      Height = 388
      ExplicitTop = 109
      ExplicitHeight = 400
    end
  end
  inherited pnlBottom: TPanel
    Top = 497
    Width = 771
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
    Top = 527
    Width = 775
    ExplicitTop = 543
    ExplicitWidth = 783
  end
end
