inherited frmSetPrsLisanlar: TfrmSetPrsLisanlar
  Caption = 'Employee Languages'
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitHeight = 468
    inherited splLeft: TSplitter
      Height = 340
      ExplicitHeight = 340
    end
    inherited splHeader: TSplitter
      Width = 791
      ExplicitWidth = 791
    end
    inherited pnlLeft: TPanel
      Height = 340
      ExplicitHeight = 340
    end
    inherited pnlHeader: TPanel
      Width = 787
      inherited edtFilterHelper: TEdit
        Width = 744
      end
    end
    inherited pnlContent: TPanel
      Width = 688
      Height = 340
      ExplicitHeight = 340
      inherited grd: TDBGrid
        Width = 688
        Height = 340
      end
    end
    inherited pnlButtons: TPanel
      Top = 376
      Width = 791
      ExplicitTop = 376
      inherited pnlButtonRight: TPanel
        Left = 606
      end
      inherited pnlButtonLeft: TPanel
        Width = 606
      end
    end
  end
  inherited pnlBottom: TPanel
    ExplicitTop = 470
    inherited btnAccept: TButton
      Left = 581
    end
    inherited btnClose: TButton
      Left = 685
    end
  end
  inherited stbBase: TStatusBar
    ExplicitTop = 500
  end
end
