inherited frmSysAylar: TfrmSysAylar
  Caption = 'Aylar'
  ClientHeight = 533
  ClientWidth = 799
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 799
    Height = 483
    ExplicitWidth = 799
    inherited splLeft: TSplitter
      Height = 351
      ExplicitHeight = 351
    end
    inherited splHeader: TSplitter
      Width = 799
      ExplicitWidth = 799
    end
    inherited pnlLeft: TPanel
      Height = 351
      ExplicitHeight = 351
    end
    inherited pnlHeader: TPanel
      Width = 795
      ExplicitWidth = 795
      inherited edtFilterHelper: TEdit
        Width = 732
        ExplicitWidth = 732
      end
    end
    inherited pnlContent: TPanel
      Width = 696
      Height = 351
      ExplicitWidth = 696
      ExplicitHeight = 351
      inherited grd: TDBGrid
        Width = 696
        Height = 351
      end
    end
    inherited pnlButtons: TPanel
      Top = 387
      Width = 799
      ExplicitTop = 387
      ExplicitWidth = 799
    end
  end
  inherited pnlBottom: TPanel
    Top = 485
    Width = 795
    ExplicitWidth = 795
    inherited btnAccept: TButton
      Left = 589
      ExplicitLeft = 589
    end
    inherited btnClose: TButton
      Left = 693
      ExplicitLeft = 693
    end
  end
  inherited stbBase: TStatusBar
    Top = 515
    Width = 799
    ExplicitWidth = 799
  end
end
