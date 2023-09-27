inherited frmSysDatabaseMonitor: TfrmSysDatabaseMonitor
  Caption = 'Database Monitor'
  ClientHeight = 515
  ClientWidth = 789
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 789
    Height = 465
    inherited splLeft: TSplitter
      ExplicitHeight = 288
    end
    inherited splHeader: TSplitter
      ExplicitWidth = 797
    end
    inherited pnlHeader: TPanel
      BevelOuter = bvNone
      inherited lblFilterHelper: TLabel
        Left = 3
        Top = 3
        Height = 24
      end
      inherited edtFilterHelper: TEdit
        Left = 189
        Top = 3
        Width = 593
        Height = 24
        TabOrder = 1
        ExplicitLeft = 190
        ExplicitWidth = 589
      end
      object cbbrefresh_period: TComboBox
        AlignWithMargins = True
        Left = 38
        Top = 3
        Width = 145
        Height = 21
        Align = alLeft
        Style = csDropDownList
        TabOrder = 0
        OnChange = cbbrefresh_periodChange
        Items.Strings = (
          'Yenileme'
          '1 saniye'
          '5 saniye'
          '10 saniye')
        ExplicitLeft = 39
        ExplicitTop = 4
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 467
    Width = 785
  end
  inherited stbBase: TStatusBar
    Top = 497
    Width = 789
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
