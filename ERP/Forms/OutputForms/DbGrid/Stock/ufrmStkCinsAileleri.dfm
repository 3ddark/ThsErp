inherited frmStkCinsAileleri: TfrmStkCinsAileleri
  Caption = 'Cins Aileleri'
  StyleElements = [seFont, seClient, seBorder]
  TextHeight = 13
  inherited pnlMain: TPanel
    StyleElements = [seFont, seClient, seBorder]
    inherited pnlLeft: TPanel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited pnlHeader: TPanel
      StyleElements = [seFont, seClient, seBorder]
      inherited lblFilterHelper: TLabel
        Height = 22
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited edtFilterHelper: TEdit
        StyleElements = [seFont, seClient, seBorder]
      end
    end
    inherited pnlContent: TPanel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited pnlButtons: TPanel
      StyleElements = [seFont, seClient, seBorder]
      inherited pnlButtonRight: TPanel
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited pnlButtonLeft: TPanel
        StyleElements = [seFont, seClient, seBorder]
      end
    end
  end
  inherited pnlBottom: TPanel
    StyleElements = [seFont, seClient, seBorder]
  end
end
