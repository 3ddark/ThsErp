inherited frmSysGridFiltrelerSiralamalar: TfrmSysGridFiltrelerSiralamalar
  Caption = 'Grid Varsay'#305'lan Filtre ve S'#305'ralama'
  ClientHeight = 533
  ClientWidth = 799
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 799
    Height = 483
    ExplicitWidth = 797
    ExplicitHeight = 479
    inherited splLeft: TSplitter
      Height = 355
      ExplicitHeight = 355
    end
    inherited splHeader: TSplitter
      Width = 799
      ExplicitWidth = 799
    end
    inherited pnlLeft: TPanel
      Height = 355
      ExplicitHeight = 351
    end
    inherited pnlHeader: TPanel
      Width = 795
      ExplicitWidth = 793
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 732
        ExplicitWidth = 730
      end
    end
    inherited pnlContent: TPanel
      Width = 696
      Height = 355
      ExplicitWidth = 694
      ExplicitHeight = 351
      inherited grd: TDBGrid
        Width = 696
        Height = 355
      end
    end
    inherited pnlButtons: TPanel
      Top = 391
      Width = 799
      ExplicitTop = 387
      ExplicitWidth = 797
      inherited pnlButtonRight: TPanel
        Left = 614
        ExplicitLeft = 612
      end
      inherited pnlButtonLeft: TPanel
        Width = 614
        ExplicitWidth = 612
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 485
    Width = 795
    ExplicitTop = 481
    ExplicitWidth = 793
    inherited btnAccept: TButton
      Left = 589
      ExplicitLeft = 587
    end
    inherited btnClose: TButton
      Left = 693
      ExplicitLeft = 691
    end
  end
  inherited stbBase: TStatusBar
    Top = 515
    Width = 799
    ExplicitTop = 511
    ExplicitWidth = 797
  end
end
