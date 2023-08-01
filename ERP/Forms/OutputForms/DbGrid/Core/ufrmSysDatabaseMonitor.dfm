inherited frmSysDbStatus: TfrmSysDbStatus
  Caption = 'Database Monitor'
  ExplicitWidth = 811
  ExplicitHeight = 564
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited splLeft: TSplitter
      Height = 351
      ExplicitHeight = 288
    end
    inherited splHeader: TSplitter
      Width = 797
    end
    inherited pnlLeft: TPanel
      Height = 351
    end
    inherited pnlHeader: TPanel
      Width = 793
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Left = 210
        Width = 579
        TabOrder = 1
        ExplicitLeft = 210
        ExplicitWidth = 577
      end
      object cbbrefresh_period: TComboBox
        AlignWithMargins = True
        Left = 59
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
      Width = 694
      Height = 351
      inherited grd: TDBGrid
        Width = 694
        Height = 351
      end
    end
    inherited pnlButtons: TPanel
      Top = 387
      Width = 797
      inherited pnlButtonRight: TPanel
        Left = 612
      end
      inherited pnlButtonLeft: TPanel
        Width = 612
      end
    end
  end
  inherited pnlBottom: TPanel
    inherited btnAccept: TButton
      Left = 587
    end
    inherited btnClose: TButton
      Left = 691
    end
  end
  inherited pmDB: TPopupMenu
    object mnikill_process_by_id: TMenuItem
      Caption = 'Kill Process By ID'
      OnClick = mnikill_process_by_idClick
    end
  end
  object tmrrefresh: TTimer
    OnTimer = tmrrefreshTimer
    Left = 136
    Top = 88
  end
end
