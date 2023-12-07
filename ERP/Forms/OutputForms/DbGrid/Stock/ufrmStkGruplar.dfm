inherited frmStkGruplar: TfrmStkGruplar
  Caption = 'Stok Gruplar'#305
  ClientHeight = 423
  ClientWidth = 793
  ExplicitWidth = 809
  ExplicitHeight = 462
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 793
    Height = 373
    ExplicitWidth = 793
    ExplicitHeight = 373
    inherited splLeft: TSplitter
      Height = 297
      ExplicitHeight = 351
    end
    inherited splHeader: TSplitter
      Width = 793
      ExplicitWidth = 793
    end
    inherited pnlLeft: TPanel
      Height = 297
      ExplicitHeight = 297
    end
    inherited pnlHeader: TPanel
      Width = 789
      ExplicitWidth = 789
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 746
        ExplicitWidth = 746
      end
    end
    inherited pnlContent: TPanel
      Width = 690
      Height = 297
      ExplicitWidth = 690
      ExplicitHeight = 297
      inherited grd: TDBGrid
        Width = 690
        Height = 297
      end
    end
    inherited pnlButtons: TPanel
      Top = 333
      Width = 793
      ExplicitTop = 333
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
    Top = 375
    Width = 789
    ExplicitTop = 375
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
    Top = 405
    Width = 793
    ExplicitTop = 405
    ExplicitWidth = 793
  end
end
