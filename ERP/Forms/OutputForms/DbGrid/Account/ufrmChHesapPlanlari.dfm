inherited frmChHesapPlanlari: TfrmChHesapPlanlari
  Caption = 'Hesap Planlar'#305
  ClientHeight = 517
  ClientWidth = 791
  ExplicitWidth = 807
  ExplicitHeight = 556
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 791
    Height = 467
    ExplicitWidth = 791
    ExplicitHeight = 467
    inherited splLeft: TSplitter
      Height = 391
      ExplicitHeight = 343
    end
    inherited splHeader: TSplitter
      Width = 791
      ExplicitWidth = 793
    end
    inherited pnlLeft: TPanel
      Height = 391
      ExplicitHeight = 391
    end
    inherited pnlHeader: TPanel
      Width = 787
      ExplicitWidth = 787
      inherited edtFilterHelper: TEdit
        Width = 744
        ExplicitWidth = 744
      end
    end
    inherited pnlContent: TPanel
      Width = 688
      Height = 391
      ExplicitWidth = 688
      ExplicitHeight = 391
      inherited grd: TDBGrid
        Width = 688
        Height = 391
      end
    end
    inherited pnlButtons: TPanel
      Top = 427
      Width = 791
      ExplicitTop = 427
      ExplicitWidth = 791
      inherited pnlButtonRight: TPanel
        Left = 606
        ExplicitLeft = 606
      end
      inherited pnlButtonLeft: TPanel
        Width = 606
        ExplicitWidth = 606
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 469
    Width = 787
    ExplicitTop = 469
    ExplicitWidth = 787
    inherited btnAccept: TButton
      Left = 581
      ExplicitLeft = 581
    end
    inherited btnClose: TButton
      Left = 685
      ExplicitLeft = 685
    end
  end
  inherited stbBase: TStatusBar
    Top = 499
    Width = 791
    ExplicitTop = 499
    ExplicitWidth = 791
  end
end
