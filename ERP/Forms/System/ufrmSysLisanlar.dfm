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
      Height = 208
      ExplicitHeight = 164
    end
    inherited splHeader: TSplitter
      Width = 553
      ExplicitWidth = 557
    end
    inherited pnlLeft: TPanel
      Height = 208
      ExplicitHeight = 208
    end
    inherited pnlHeader: TPanel
      Width = 549
      ExplicitWidth = 549
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 506
        ExplicitWidth = 506
      end
    end
    inherited pnlContent: TPanel
      Width = 450
      Height = 208
      ExplicitWidth = 450
      ExplicitHeight = 208
      inherited grd: TDBGrid
        Width = 450
        Height = 208
      end
    end
    inherited pnlButtons: TPanel
      Top = 244
      Width = 553
      ExplicitTop = 244
      ExplicitWidth = 553
      inherited pnlButtonRight: TPanel
        Left = 368
        ExplicitLeft = 368
      end
      inherited pnlButtonLeft: TPanel
        Width = 368
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
      Left = 343
      ExplicitLeft = 343
    end
    inherited btnClose: TButton
      Left = 447
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
