inherited frmSysErisimHaklari: TfrmSysErisimHaklari
  Caption = 'Eri'#351'im Haklar'#305
  ClientWidth = 813
  ExplicitWidth = 829
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 813
    ExplicitWidth = 813
    inherited splLeft: TSplitter
      ExplicitHeight = 355
    end
    inherited splHeader: TSplitter
      Width = 813
      ExplicitWidth = 813
    end
    inherited pnlHeader: TPanel
      Width = 809
      ExplicitWidth = 809
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 766
        ExplicitWidth = 766
      end
    end
    inherited pnlContent: TPanel
      Width = 710
      ExplicitWidth = 710
      inherited grd: TDBGrid
        Width = 710
      end
    end
    inherited pnlButtons: TPanel
      Width = 813
      ExplicitWidth = 813
      inherited pnlButtonRight: TPanel
        Left = 628
        ExplicitLeft = 628
      end
      inherited pnlButtonLeft: TPanel
        Width = 628
        ExplicitWidth = 628
      end
    end
  end
  inherited pnlBottom: TPanel
    Width = 809
    ExplicitWidth = 809
    inherited btnAccept: TButton
      Left = 603
      ExplicitLeft = 603
    end
    inherited btnClose: TButton
      Left = 707
      ExplicitLeft = 707
    end
  end
  inherited stbBase: TStatusBar
    Width = 813
    ExplicitWidth = 813
  end
end
