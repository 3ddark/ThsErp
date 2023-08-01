inherited frmSysKullanicilar: TfrmSysKullanicilar
  Caption = 'Kullan'#305'c'#305'lar'
  ClientHeight = 569
  ClientWidth = 817
  ExplicitWidth = 831
  ExplicitHeight = 604
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 817
    Height = 519
    ExplicitWidth = 815
    ExplicitHeight = 515
    inherited splLeft: TSplitter
      Height = 391
      ExplicitHeight = 391
    end
    inherited splHeader: TSplitter
      Width = 817
      ExplicitWidth = 819
    end
    inherited pnlLeft: TPanel
      Height = 391
      ExplicitHeight = 387
    end
    inherited pnlHeader: TPanel
      Width = 813
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 750
      end
    end
    inherited pnlContent: TPanel
      Width = 714
      Height = 391
      ExplicitHeight = 387
      inherited grd: TDBGrid
        Width = 714
        Height = 391
      end
    end
    inherited pnlButtons: TPanel
      Top = 427
      Width = 817
      ExplicitTop = 423
      inherited pnlButtonRight: TPanel
        Left = 632
      end
      inherited pnlButtonLeft: TPanel
        Width = 632
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 521
    Width = 813
    ExplicitTop = 517
    ExplicitWidth = 811
    inherited btnAccept: TButton
      Left = 607
    end
    inherited btnClose: TButton
      Left = 711
    end
  end
  inherited stbBase: TStatusBar
    Top = 551
    Width = 817
    ExplicitTop = 547
    ExplicitWidth = 815
  end
  inherited pmDB: TPopupMenu
    object mniCopyAccessRightFromUser: TMenuItem
      Caption = 'Hakalar'#305' Di'#287'er Kullan'#305'c'#305'dan Kopyala'
      OnClick = mniCopyAccessRightFromUserClick
    end
  end
end
