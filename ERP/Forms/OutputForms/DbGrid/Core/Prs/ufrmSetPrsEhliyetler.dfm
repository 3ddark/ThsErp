inherited frmSetPrsEhliyetler: TfrmSetPrsEhliyetler
  Caption = 'Personel Ehliyet Tipleri'
  ClientHeight = 454
  ClientWidth = 791
  ExplicitWidth = 807
  ExplicitHeight = 493
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 791
    Height = 404
    ExplicitWidth = 791
    ExplicitHeight = 404
    inherited splLeft: TSplitter
      Height = 328
      ExplicitHeight = 355
    end
    inherited splHeader: TSplitter
      Width = 791
      ExplicitWidth = 791
    end
    inherited pnlLeft: TPanel
      Height = 328
      ExplicitHeight = 328
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
      Height = 328
      ExplicitWidth = 688
      ExplicitHeight = 328
      inherited grd: TDBGrid
        Height = 328
      end
    end
    inherited pnlButtons: TPanel
      Top = 364
      Width = 791
      ExplicitTop = 364
      ExplicitWidth = 791
    end
  end
  inherited pnlBottom: TPanel
    Top = 406
    Width = 787
    ExplicitTop = 406
    ExplicitWidth = 787
    inherited btnAccept: TButton
      Left = 581
      ExplicitLeft = 581
    end
    inherited btnClose: TButton
      Left = 685
      ExplicitLeft = 685
    end
  end
  inherited stbBase: TStatusBar
    Top = 436
    Width = 791
    ExplicitTop = 436
    ExplicitWidth = 791
  end
end
