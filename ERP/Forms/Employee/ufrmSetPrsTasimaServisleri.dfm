inherited frmSetPrsTasimaServisleri: TfrmSetPrsTasimaServisleri
  Caption = 'Personel Ta'#351#305'ma Servisleri'
  TextHeight = 13
  inherited pnlMain: TPanel
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
      ExplicitHeight = 337
    end
    inherited pnlHeader: TPanel
      Width = 787
      ExplicitWidth = 787
      inherited edtFilterHelper: TEdit
        Width = 744
        ExplicitWidth = 744
      end
    end
    inherited pnlContent: TPanel
      Width = 688
      Height = 340
      ExplicitWidth = 688
      ExplicitHeight = 337
      inherited grd: TDBGrid
        Width = 688
        Height = 340
      end
    end
    inherited pnlButtons: TPanel
      Top = 376
      Width = 791
      ExplicitTop = 373
      ExplicitWidth = 791
      inherited pnlButtonRight: TPanel
        Left = 606
        ExplicitLeft = 606
      end
      inherited pnlButtonLeft: TPanel
        Width = 606
        ExplicitWidth = 606
      end
    end
  end
  inherited pnlBottom: TPanel
    inherited btnAccept: TButton
      Left = 581
      ExplicitLeft = 581
    end
    inherited btnClose: TButton
      Left = 685
      ExplicitLeft = 685
    end
  end
end
