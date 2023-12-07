inherited frmSysKullanicilar: TfrmSysKullanicilar
  Caption = 'Sistem Kullan'#305'c'#305'lar'
  ClientHeight = 569
  ClientWidth = 817
  ExplicitWidth = 833
  ExplicitHeight = 608
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 817
    Height = 519
    ExplicitWidth = 817
    ExplicitHeight = 519
    inherited splLeft: TSplitter
      Height = 443
      ExplicitHeight = 391
    end
    inherited splHeader: TSplitter
      Width = 817
      ExplicitWidth = 819
    end
    inherited pnlLeft: TPanel
      Height = 443
      ExplicitHeight = 443
    end
    inherited pnlHeader: TPanel
      Width = 813
      ExplicitWidth = 813
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 770
        ExplicitWidth = 770
      end
    end
    inherited pnlContent: TPanel
      Width = 714
      Height = 443
      ExplicitWidth = 714
      ExplicitHeight = 443
      inherited grd: TDBGrid
        Width = 714
        Height = 443
      end
    end
    inherited pnlButtons: TPanel
      Top = 479
      Width = 817
      ExplicitTop = 479
      ExplicitWidth = 817
      inherited pnlButtonRight: TPanel
        Left = 632
        ExplicitLeft = 632
      end
      inherited pnlButtonLeft: TPanel
        Width = 632
        ExplicitWidth = 632
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 521
    Width = 813
    ExplicitTop = 521
    ExplicitWidth = 813
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
    Top = 551
    Width = 817
    ExplicitTop = 551
    ExplicitWidth = 817
  end
  inherited pmDB: TPopupMenu
    object mniCopyAccessRightFromUser: TMenuItem
      Caption = 'Hakalar'#305' Di'#287'er Kullan'#305'c'#305'dan Kopyala'
      OnClick = mniCopyAccessRightFromUserClick
    end
  end
end
