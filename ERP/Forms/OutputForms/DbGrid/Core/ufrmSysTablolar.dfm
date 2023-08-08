inherited frmSysTablolar: TfrmSysTablolar
  Caption = 'Tablolar'
  ExplicitWidth = 811
  ExplicitHeight = 564
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited splLeft: TSplitter
      Height = 351
    end
    inherited splHeader: TSplitter
      Width = 797
    end
    inherited pnlLeft: TPanel
      Height = 351
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
      Height = 351
      inherited grd: TDBGrid
        Width = 694
        Height = 351
      end
    end
    inherited pnlButtons: TPanel
      Top = 387
      Width = 797
    end
  end
  inherited pnlBottom: TPanel
    inherited btnAccept: TButton
      Left = 587
    end
    inherited btnClose: TButton
      Left = 691
    end
  end
end
