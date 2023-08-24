inherited frmSetPrsPersonelTipleri: TfrmSetPrsPersonelTipleri
  Caption = 'Personel Tipleri'
  ClientWidth = 795
  ExplicitWidth = 809
  ExplicitHeight = 551
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 795
    ExplicitWidth = 793
    ExplicitHeight = 462
    inherited splLeft: TSplitter
      Height = 389
    end
    inherited splHeader: TSplitter
      Width = 795
    end
    inherited pnlLeft: TPanel
      Height = 389
      ExplicitHeight = 386
    end
    inherited pnlHeader: TPanel
      Width = 791
      ExplicitWidth = 789
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 748
        ExplicitWidth = 746
      end
    end
    inherited pnlContent: TPanel
      Width = 692
      Height = 389
      ExplicitWidth = 690
      ExplicitHeight = 386
      inherited grd: TDBGrid
        Width = 692
        Height = 389
      end
    end
    inherited pnlButtons: TPanel
      Top = 425
      Width = 795
      ExplicitTop = 422
      ExplicitWidth = 793
      inherited pnlButtonRight: TPanel
        Left = 610
        ExplicitLeft = 608
        ExplicitHeight = 40
      end
      inherited pnlButtonLeft: TPanel
        Width = 610
        ExplicitWidth = 608
        ExplicitHeight = 40
      end
    end
  end
  inherited pnlBottom: TPanel
    Width = 791
    ExplicitTop = 464
    ExplicitWidth = 789
    inherited btnAccept: TButton
      Left = 585
      ExplicitLeft = 583
    end
    inherited btnClose: TButton
      Left = 689
      ExplicitLeft = 687
    end
  end
  inherited stbBase: TStatusBar
    Width = 795
    ExplicitTop = 494
    ExplicitWidth = 793
  end
end
