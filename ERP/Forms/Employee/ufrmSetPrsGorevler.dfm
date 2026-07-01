inherited frmSetPrsGorevler: TfrmSetPrsGorevler
  Caption = 'Personel G'#246'revler'
  ClientHeight = 463
  ClientWidth = 793
  ExplicitWidth = 809
  ExplicitHeight = 502
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 793
    Height = 413
    ExplicitWidth = 791
    ExplicitHeight = 410
    inherited splLeft: TSplitter
      Height = 337
      ExplicitHeight = 337
    end
    inherited splHeader: TSplitter
      Width = 793
      ExplicitWidth = 793
    end
    inherited pnlLeft: TPanel
      Height = 337
      ExplicitHeight = 334
    end
    inherited pnlHeader: TPanel
      Width = 789
      ExplicitWidth = 787
      inherited edtFilterHelper: TEdit
        Width = 746
        ExplicitWidth = 744
      end
    end
    inherited pnlContent: TPanel
      Width = 690
      Height = 337
      ExplicitWidth = 688
      ExplicitHeight = 334
      inherited grd: TDBGrid
        Width = 690
        Height = 337
      end
    end
    inherited pnlButtons: TPanel
      Top = 373
      Width = 793
      ExplicitTop = 370
      ExplicitWidth = 793
      inherited pnlButtonRight: TPanel
        Left = 608
        ExplicitLeft = 606
      end
      inherited pnlButtonLeft: TPanel
        Width = 608
        ExplicitWidth = 606
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 415
    Width = 789
    ExplicitTop = 412
    ExplicitWidth = 787
    inherited btnAccept: TButton
      Left = 583
      ExplicitLeft = 581
    end
    inherited btnClose: TButton
      Left = 687
      ExplicitLeft = 685
    end
  end
  inherited stbBase: TStatusBar
    Top = 445
    Width = 793
    ExplicitTop = 442
    ExplicitWidth = 791
  end
end
