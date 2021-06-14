inherited frmSysDbStatus: TfrmSysDbStatus
  Caption = 'Database Monitor'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited splLeft: TSplitter
      ExplicitHeight = 288
    end
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Left = 248
        Width = 559
        TabOrder = 1
        ExplicitLeft = 248
        ExplicitWidth = 559
      end
      object cbbrefresh_period: TComboBox
        AlignWithMargins = True
        Left = 97
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
  end
  inherited pmDB: TPopupMenu
    object mnikill_process_by_id: TMenuItem
      Caption = 'Kill Process By ID'
      OnClick = mnikill_process_by_idClick
    end
  end
  inherited frxrprtBase: TfrxReport
    ScriptText.Strings = ()
  end
  object tmrrefresh: TTimer
    OnTimer = tmrrefreshTimer
    Left = 136
    Top = 88
  end
end
