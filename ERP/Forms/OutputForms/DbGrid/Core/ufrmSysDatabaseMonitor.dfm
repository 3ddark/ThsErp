inherited frmSysDatabaseMonitor: TfrmSysDatabaseMonitor
  Caption = 'Database Monitor'
  ExplicitWidth = 807
  ExplicitHeight = 556
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitWidth = 791
    ExplicitHeight = 467
    inherited splLeft: TSplitter
      Height = 343
      ExplicitHeight = 288
    end
    inherited splHeader: TSplitter
      Width = 793
      ExplicitWidth = 797
    end
    inherited pnlLeft: TPanel
      Height = 343
      ExplicitHeight = 339
    end
    inherited pnlHeader: TPanel
      Width = 789
      ExplicitWidth = 787
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Left = 190
        Width = 595
        TabOrder = 1
        ExplicitLeft = 190
        ExplicitWidth = 593
      end
      object cbbrefresh_period: TComboBox
        AlignWithMargins = True
        Left = 39
        Top = 4
        Width = 145
        Height = 21
        Align = alLeft
        Style = csDropDownList
        TabOrder = 0
        OnChange = cbbrefresh_periodChange
        Items.Strings = (
          'Dont refresh'
          '1 second'
          '5 seconds'
          '10 seconds')
      end
    end
    inherited pnlContent: TPanel
      Width = 690
      Height = 343
      ExplicitWidth = 688
      ExplicitHeight = 339
      inherited grd: TDBGrid
        Width = 690
        Height = 343
      end
    end
    inherited pnlButtons: TPanel
      Top = 379
      Width = 793
      ExplicitTop = 375
      ExplicitWidth = 791
      inherited pnlButtonRight: TPanel
        Left = 608
        ExplicitLeft = 606
      end
      inherited pnlButtonLeft: TPanel
        Width = 608
        ExplicitWidth = 606
      end
    end
  end
  inherited pnlBottom: TPanel
    ExplicitTop = 469
    ExplicitWidth = 787
    inherited btnAccept: TButton
      Left = 583
      ExplicitLeft = 581
    end
    inherited btnClose: TButton
      Left = 687
      ExplicitLeft = 685
    end
  end
  inherited stbBase: TStatusBar
    ExplicitTop = 499
    ExplicitWidth = 791
  end
  inherited pmDB: TPopupMenu
    object mnikill_process_by_id: TMenuItem
      Caption = 'Se'#231'ili '#304#351'lemi Sonland'#305'r'
      OnClick = mnikill_process_by_idClick
    end
  end
  object tmrrefresh: TTimer
    OnTimer = tmrrefreshTimer
    Left = 136
    Top = 88
  end
end
