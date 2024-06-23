inherited frmPrsEhliyetler: TfrmPrsEhliyetler
  Caption = 'Personel Ehliyetleri'
  ClientWidth = 793
  ExplicitWidth = 809
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 793
    ExplicitWidth = 793
    inherited splLeft: TSplitter
      ExplicitHeight = 340
    end
    inherited splHeader: TSplitter
      Width = 793
      ExplicitWidth = 793
    end
    inherited pnlHeader: TPanel
      Width = 789
      ExplicitWidth = 789
      inherited edtFilterHelper: TEdit
        Width = 746
        ExplicitWidth = 746
      end
    end
    inherited pnlContent: TPanel
      Width = 690
      ExplicitWidth = 690
      inherited grd: TDBGrid
        Width = 690
      end
    end
    inherited pnlButtons: TPanel
      Width = 793
      ExplicitWidth = 793
      inherited pnlButtonRight: TPanel
        Left = 608
        ExplicitLeft = 608
      end
      inherited pnlButtonLeft: TPanel
        Width = 608
        ExplicitWidth = 608
      end
    end
  end
  inherited pnlBottom: TPanel
    Width = 789
    ExplicitWidth = 789
    inherited btnAccept: TButton
      Left = 583
      ExplicitLeft = 583
    end
    inherited btnClose: TButton
      Left = 687
      ExplicitLeft = 687
    end
  end
  inherited stbBase: TStatusBar
    Width = 793
    ExplicitWidth = 793
  end
end
