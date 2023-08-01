inherited frmSysSehirler: TfrmSysSehirler
  Caption = 'Sehirler'
  ExplicitWidth = 811
  ExplicitHeight = 564
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited splLeft: TSplitter
      Height = 351
      ExplicitHeight = 351
    end
    inherited splHeader: TSplitter
      Width = 797
      ExplicitWidth = 797
    end
    inherited pnlLeft: TPanel
      Height = 351
      ExplicitHeight = 351
    end
    inherited pnlHeader: TPanel
      Width = 793
      ExplicitWidth = 793
      inherited edtFilterHelper: TEdit
        Width = 730
        ExplicitWidth = 728
      end
    end
    inherited pnlContent: TPanel
      Width = 694
      Height = 351
      ExplicitWidth = 694
      ExplicitHeight = 351
      inherited grd: TDBGrid
        Width = 694
        Height = 351
      end
    end
    inherited pnlButtons: TPanel
      Top = 387
      Width = 797
      ExplicitTop = 387
      ExplicitWidth = 797
    end
  end
  inherited pnlBottom: TPanel
    inherited btnAccept: TButton
      Left = 587
      ExplicitLeft = 587
    end
    inherited btnClose: TButton
      Left = 691
      ExplicitLeft = 691
    end
  end
end
