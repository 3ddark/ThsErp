inherited frmSetPrsBirimler: TfrmSetPrsBirimler
  Caption = 'Employee Units'
  ClientWidth = 789
  ExplicitWidth = 805
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 789
    ExplicitWidth = 789
    ExplicitHeight = 468
    inherited splLeft: TSplitter
      Height = 340
    end
    inherited splHeader: TSplitter
      Width = 789
    end
    inherited pnlLeft: TPanel
      Height = 340
      ExplicitHeight = 340
    end
    inherited pnlHeader: TPanel
      Width = 785
      ExplicitWidth = 785
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 742
        ExplicitWidth = 742
      end
    end
    inherited pnlContent: TPanel
      Width = 686
      Height = 340
      ExplicitWidth = 686
      ExplicitHeight = 340
      inherited grd: TDBGrid
        Width = 686
        Height = 340
      end
    end
    inherited pnlButtons: TPanel
      Top = 376
      Width = 789
      ExplicitTop = 376
      ExplicitWidth = 789
      inherited pnlButtonRight: TPanel
        Left = 604
        ExplicitLeft = 604
      end
      inherited pnlButtonLeft: TPanel
        Width = 604
        ExplicitWidth = 604
      end
    end
  end
  inherited pnlBottom: TPanel
    Width = 785
    ExplicitTop = 470
    ExplicitWidth = 785
    inherited btnAccept: TButton
      Left = 579
      ExplicitLeft = 579
    end
    inherited btnClose: TButton
      Left = 683
      ExplicitLeft = 683
    end
  end
  inherited stbBase: TStatusBar
    Width = 789
    ExplicitTop = 500
    ExplicitWidth = 789
  end
end
