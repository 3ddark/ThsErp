inherited frmSysGunler: TfrmSysGunler
  Caption = 'G'#252'nler'
  ClientHeight = 565
  ExplicitWidth = 811
  ExplicitHeight = 600
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 515
    ExplicitHeight = 511
    inherited splLeft: TSplitter
      Height = 387
    end
    inherited splHeader: TSplitter
      Width = 797
    end
    inherited pnlLeft: TPanel
      Height = 387
    end
    inherited pnlHeader: TPanel
      Width = 793
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 730
      end
    end
    inherited pnlContent: TPanel
      Width = 694
      Height = 387
      inherited grd: TDBGrid
        Width = 694
        Height = 387
      end
    end
    inherited pnlButtons: TPanel
      Top = 423
      Width = 797
    end
  end
  inherited pnlBottom: TPanel
    Top = 517
    ExplicitTop = 513
    inherited btnAccept: TButton
      Left = 587
    end
    inherited btnClose: TButton
      Left = 691
    end
  end
  inherited stbBase: TStatusBar
    Top = 547
    ExplicitTop = 543
  end
end
