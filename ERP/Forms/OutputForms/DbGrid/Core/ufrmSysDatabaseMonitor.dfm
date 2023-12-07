inherited frmSysDatabaseMonitor: TfrmSysDatabaseMonitor
  Caption = 'Database Monitor'
  TextHeight = 13
  inherited pnlMain: TPanel
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
        ExplicitLeft = 3
        ExplicitTop = 3
      end
      inherited edtFilterHelper: TEdit
        Left = 189
        Top = 3
        Width = 593
        Height = 24
        TabOrder = 1
        ExplicitLeft = 189
        ExplicitTop = 3
        ExplicitWidth = 593
        ExplicitHeight = 24
      end
      object cbbrefresh_period: TComboBox
        AlignWithMargins = True
        Left = 38
        Top = 3
        Width = 145
        Height = 24
        Align = alLeft
        Style = csDropDownList
        TabOrder = 0
        OnChange = cbbrefresh_periodChange
        Items.Strings = (
          'Yenileme'
          '1 saniye'
          '5 saniye'
          '10 saniye')
      end
    end
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
