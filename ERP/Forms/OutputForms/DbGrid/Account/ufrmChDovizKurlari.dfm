inherited frmChDovizKurlari: TfrmChDovizKurlari
  Caption = 'D'#246'viz Kurlar'#305
  ExplicitWidth = 803
  ExplicitHeight = 551
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited splLeft: TSplitter
      Height = 337
    end
    inherited splHeader: TSplitter
      Width = 789
    end
    inherited pnlLeft: TPanel
      Height = 337
    end
    inherited pnlHeader: TPanel
      Width = 785
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 742
      end
    end
    inherited pnlContent: TPanel
      Width = 686
      Height = 337
      inherited grd: TDBGrid
        Width = 686
        Height = 337
      end
    end
    inherited pnlButtons: TPanel
      Top = 373
      Width = 789
    end
  end
  inherited pnlBottom: TPanel
    inherited btnAccept: TButton
      Left = 579
    end
    inherited btnClose: TButton
      Left = 683
    end
  end
end
