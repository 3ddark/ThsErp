inherited frmSysLisanlar: TfrmSysLisanlar
  Caption = 'Languages'
  ClientHeight = 334
  ClientWidth = 553
  ExplicitWidth = 569
  ExplicitHeight = 373
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 553
    Height = 284
    ExplicitWidth = 553
    ExplicitHeight = 284
    inherited splLeft: TSplitter
      Height = 160
      ExplicitHeight = 164
    end
    inherited splHeader: TSplitter
      Width = 555
      ExplicitWidth = 557
    end
    inherited pnlLeft: TPanel
      Height = 160
      ExplicitHeight = 156
    end
    inherited pnlHeader: TPanel
      Width = 551
      ExplicitWidth = 549
      inherited edtFilterHelper: TEdit
        Width = 488
        ExplicitWidth = 486
      end
    end
    inherited pnlContent: TPanel
      Width = 452
      Height = 160
      ExplicitWidth = 450
      ExplicitHeight = 156
      inherited grd: TDBGrid
        Width = 452
        Height = 160
      end
    end
    inherited pnlButtons: TPanel
      Top = 196
      Width = 555
      ExplicitTop = 192
      ExplicitWidth = 553
      inherited pnlButtonRight: TPanel
        Left = 370
        ExplicitLeft = 368
      end
      inherited pnlButtonLeft: TPanel
        Width = 370
        ExplicitWidth = 368
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 286
    Width = 549
    ExplicitTop = 286
    ExplicitWidth = 549
    inherited btnAccept: TButton
      Left = 345
      ExplicitLeft = 343
    end
    inherited btnClose: TButton
      Left = 449
      ExplicitLeft = 447
    end
  end
  inherited stbBase: TStatusBar
    Top = 316
    Width = 553
    ExplicitTop = 316
    ExplicitWidth = 553
  end
end
