inherited frmChGruplar: TfrmChGruplar
  Caption = 'Hesap Gruplar'#305
  ExplicitWidth = 809
  ExplicitHeight = 560
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited splLeft: TSplitter
      Height = 347
      ExplicitHeight = 347
    end
    inherited splHeader: TSplitter
      Width = 795
      ExplicitWidth = 795
    end
    inherited pnlLeft: TPanel
      Height = 347
    end
    inherited pnlHeader: TPanel
      Width = 791
      inherited edtFilterHelper: TEdit
        Width = 748
      end
    end
    inherited pnlContent: TPanel
      Width = 692
      Height = 347
      inherited grd: TDBGrid
        Width = 692
        Height = 347
      end
    end
    inherited pnlButtons: TPanel
      Top = 383
      Width = 795
      inherited pnlButtonRight: TPanel
        Left = 610
      end
      inherited pnlButtonLeft: TPanel
        Width = 610
      end
    end
  end
  inherited pnlBottom: TPanel
    inherited btnAccept: TButton
      Left = 585
    end
    inherited btnClose: TButton
      Left = 689
    end
  end
end
