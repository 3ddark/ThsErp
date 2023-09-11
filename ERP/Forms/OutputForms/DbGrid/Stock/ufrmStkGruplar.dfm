inherited frmStkGruplar: TfrmStkGruplar
  Caption = 'Stok Gruplar'#305
  ClientHeight = 423
  ClientWidth = 793
  ExplicitWidth = 807
  ExplicitHeight = 459
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 793
    Height = 373
    ExplicitWidth = 791
    ExplicitHeight = 476
    inherited splLeft: TSplitter
      Height = 297
      ExplicitHeight = 351
    end
    inherited splHeader: TSplitter
      Width = 793
    end
    inherited pnlLeft: TPanel
      Height = 297
      ExplicitHeight = 400
    end
    inherited pnlHeader: TPanel
      Width = 789
      ExplicitWidth = 787
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 746
        ExplicitWidth = 744
      end
    end
    inherited pnlContent: TPanel
      Width = 690
      Height = 297
      ExplicitWidth = 688
      ExplicitHeight = 400
      inherited grd: TDBGrid
        Width = 690
        Height = 297
      end
    end
    inherited pnlButtons: TPanel
      Top = 333
      Width = 793
      ExplicitTop = 436
      inherited pnlButtonRight: TPanel
        Left = 608
        ExplicitLeft = 606
        ExplicitHeight = 40
      end
      inherited pnlButtonLeft: TPanel
        Width = 608
        ExplicitWidth = 606
        ExplicitHeight = 40
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 375
    Width = 789
    ExplicitTop = 478
    ExplicitWidth = 787
    inherited btnAccept: TButton
      Left = 583
      TabOrder = 2
      ExplicitLeft = 581
    end
    inherited btnClose: TButton
      Left = 687
      ExplicitLeft = 685
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 405
    Width = 793
    ExplicitTop = 508
    ExplicitWidth = 791
  end
end
