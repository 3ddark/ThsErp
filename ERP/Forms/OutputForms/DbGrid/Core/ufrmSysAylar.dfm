inherited frmSysAylar: TfrmSysAylar
  Caption = 'Sistem Aylar'
  ClientHeight = 533
  ClientWidth = 799
  ExplicitWidth = 815
  ExplicitHeight = 572
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 799
    Height = 483
    ExplicitWidth = 799
    ExplicitHeight = 483
    inherited splLeft: TSplitter
      Height = 407
      ExplicitHeight = 351
    end
    inherited splHeader: TSplitter
      Width = 799
      ExplicitWidth = 799
    end
    inherited pnlLeft: TPanel
      Height = 407
      ExplicitHeight = 407
    end
    inherited pnlHeader: TPanel
      Width = 795
      ExplicitWidth = 795
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 752
        ExplicitWidth = 752
      end
    end
    inherited pnlContent: TPanel
      Width = 696
      Height = 407
      ExplicitWidth = 696
      ExplicitHeight = 407
      inherited grd: TDBGrid
        Width = 696
        Height = 407
      end
    end
    inherited pnlButtons: TPanel
      Top = 443
      Width = 799
      ExplicitTop = 443
      ExplicitWidth = 799
      inherited pnlButtonRight: TPanel
        Left = 614
        ExplicitLeft = 614
      end
      inherited pnlButtonLeft: TPanel
        Width = 614
        ExplicitWidth = 614
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 485
    Width = 795
    ExplicitTop = 485
    ExplicitWidth = 795
    inherited btnAccept: TButton
      Left = 589
      ExplicitLeft = 589
    end
    inherited btnClose: TButton
      Left = 693
      ExplicitLeft = 693
    end
  end
  inherited stbBase: TStatusBar
    Top = 515
    Width = 799
    ExplicitTop = 515
    ExplicitWidth = 799
  end
end
