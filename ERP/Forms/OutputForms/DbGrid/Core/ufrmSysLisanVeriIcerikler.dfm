inherited frmSysLisanVeriIcerikler: TfrmSysLisanVeriIcerikler
  Caption = 'Lisan Data '#304#231'erikler'
  ClientHeight = 553
  ClientWidth = 801
  ExplicitWidth = 815
  ExplicitHeight = 588
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 801
    Height = 503
    ExplicitWidth = 799
    ExplicitHeight = 499
    inherited splLeft: TSplitter
      Height = 375
      ExplicitHeight = 375
    end
    inherited splHeader: TSplitter
      Width = 801
      ExplicitWidth = 801
    end
    inherited pnlLeft: TPanel
      Height = 375
      ExplicitHeight = 371
    end
    inherited pnlHeader: TPanel
      Width = 797
      ExplicitWidth = 795
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 734
        ExplicitWidth = 732
      end
    end
    inherited pnlContent: TPanel
      Width = 698
      Height = 375
      ExplicitWidth = 696
      ExplicitHeight = 371
      inherited grd: TDBGrid
        Width = 698
        Height = 375
      end
    end
    inherited pnlButtons: TPanel
      Top = 411
      Width = 801
      ExplicitTop = 407
      ExplicitWidth = 799
      inherited pnlButtonRight: TPanel
        Left = 616
      end
      inherited pnlButtonLeft: TPanel
        Width = 616
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 505
    Width = 797
    ExplicitTop = 501
    ExplicitWidth = 795
    inherited btnAccept: TButton
      Left = 591
      ExplicitLeft = 589
    end
    inherited btnClose: TButton
      Left = 695
      ExplicitLeft = 693
    end
  end
  inherited stbBase: TStatusBar
    Top = 535
    Width = 801
    ExplicitTop = 531
    ExplicitWidth = 799
  end
end
