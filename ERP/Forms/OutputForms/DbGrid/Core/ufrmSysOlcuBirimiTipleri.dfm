inherited frmSysOlcuBirimiTipleri: TfrmSysOlcuBirimiTipleri
  Caption = 'Sistem '#214'l'#231#252' Birimi Tipleri'
  ClientHeight = 557
  ClientWidth = 795
  ExplicitWidth = 811
  ExplicitHeight = 596
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 795
    Height = 507
    ExplicitWidth = 795
    ExplicitHeight = 507
    inherited splLeft: TSplitter
      Height = 431
      ExplicitHeight = 383
    end
    inherited splHeader: TSplitter
      Width = 795
      ExplicitWidth = 797
    end
    inherited pnlLeft: TPanel
      Height = 431
      ExplicitHeight = 431
    end
    inherited pnlHeader: TPanel
      Width = 791
      ExplicitWidth = 791
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 748
        ExplicitWidth = 748
      end
    end
    inherited pnlContent: TPanel
      Width = 692
      Height = 431
      ExplicitWidth = 692
      ExplicitHeight = 431
      inherited grd: TDBGrid
        Width = 692
        Height = 431
      end
    end
    inherited pnlButtons: TPanel
      Top = 467
      Width = 795
      ExplicitTop = 467
      ExplicitWidth = 795
      inherited pnlButtonRight: TPanel
        Left = 610
        ExplicitLeft = 610
      end
      inherited pnlButtonLeft: TPanel
        Width = 610
        ExplicitWidth = 610
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 509
    Width = 791
    ExplicitTop = 509
    ExplicitWidth = 791
    inherited btnAccept: TButton
      Left = 585
      ExplicitLeft = 585
    end
    inherited btnClose: TButton
      Left = 689
      ExplicitLeft = 689
    end
  end
  inherited stbBase: TStatusBar
    Top = 539
    Width = 795
    ExplicitTop = 539
    ExplicitWidth = 795
  end
end
