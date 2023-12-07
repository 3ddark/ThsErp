inherited frmRctPaketHammaddeler: TfrmRctPaketHammaddeler
  Caption = 'Paket Hammaddeler'
  ClientWidth = 813
  ExplicitWidth = 829
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 813
    ExplicitWidth = 813
    inherited splHeader: TSplitter
      Width = 813
    end
    inherited pnlHeader: TPanel
      Width = 809
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 766
      end
    end
    inherited pnlContent: TPanel
      Width = 710
    end
    inherited pnlButtons: TPanel
      Width = 813
    end
  end
  inherited pnlBottom: TPanel
    Width = 809
    ExplicitWidth = 809
    inherited btnAccept: TButton
      Left = 603
    end
    inherited btnClose: TButton
      Left = 707
    end
  end
  inherited stbBase: TStatusBar
    Width = 813
    ExplicitWidth = 813
  end
end
