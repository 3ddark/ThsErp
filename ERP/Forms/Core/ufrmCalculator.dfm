object frmCalculator: TfrmCalculator
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Calculator'
  ClientHeight = 326
  ClientWidth = 284
  Color = clBtnFace
  Constraints.MinHeight = 365
  Constraints.MinWidth = 300
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  TextHeight = 13
  object edtLCD: TEdit
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 278
    Height = 55
    Align = alTop
    Alignment = taRightJustify
    AutoSelect = False
    Enabled = False
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -40
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    HideSelection = False
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    Text = '0'
  end
  object grdpnlCalculator: TGridPanel
    AlignWithMargins = True
    Left = 3
    Top = 64
    Width = 278
    Height = 259
    Align = alClient
    BevelOuter = bvNone
    ColumnCollection = <
      item
        Value = 24.999999999999990000
      end
      item
        Value = 24.999999999999990000
      end
      item
        Value = 25.000000000000020000
      end
      item
        Value = 25.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 1
        Control = btn0
        Row = 4
      end
      item
        Column = 0
        Control = btn1
        Row = 3
      end
      item
        Column = 1
        Control = btn2
        Row = 3
      end
      item
        Column = 2
        Control = btn3
        Row = 3
      end
      item
        Column = 0
        Control = btn4
        Row = 2
      end
      item
        Column = 1
        Control = btn5
        Row = 2
      end
      item
        Column = 2
        Control = btn6
        Row = 2
      end
      item
        Column = 0
        Control = btn7
        Row = 1
      end
      item
        Column = 1
        Control = btn8
        Row = 1
      end
      item
        Column = 2
        Control = btn9
        Row = 1
      end
      item
        Column = 3
        Control = btnAddition
        Row = 3
      end
      item
        Column = 3
        Control = btnSubtract
        Row = 2
      end
      item
        Column = 3
        Control = btnMultiply
        Row = 0
      end
      item
        Column = 3
        Control = btnDivide
        Row = 1
      end
      item
        Column = 2
        Control = btnErase
        Row = 0
      end
      item
        Column = 1
        Control = btnSquare
        Row = 0
      end
      item
        Column = 0
        Control = btnC
        Row = 0
      end
      item
        Column = 3
        Control = btnCalculate
        Row = 4
      end
      item
        Column = 2
        Control = btnSeperate
        Row = 4
      end
      item
        Column = 0
        Control = btnArtiEksi
        Row = 4
      end>
    RowCollection = <
      item
        Value = 19.999999764044880000
      end
      item
        Value = 20.000000656360610000
      end
      item
        Value = 20.000000222995330000
      end
      item
        Value = 19.999999644801760000
      end
      item
        Value = 19.999999711797430000
      end
      item
        SizeStyle = ssAuto
      end>
    TabOrder = 1
    object btn0: TButton
      AlignWithMargins = True
      Left = 70
      Top = 208
      Width = 68
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      TabStop = False
    end
    object btn1: TButton
      AlignWithMargins = True
      Left = 1
      Top = 156
      Width = 67
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '1'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      TabStop = False
    end
    object btn2: TButton
      AlignWithMargins = True
      Left = 70
      Top = 156
      Width = 68
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '2'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      TabStop = False
    end
    object btn3: TButton
      AlignWithMargins = True
      Left = 140
      Top = 156
      Width = 68
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '3'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      TabStop = False
    end
    object btn4: TButton
      AlignWithMargins = True
      Left = 1
      Top = 105
      Width = 67
      Height = 49
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '4'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      TabStop = False
    end
    object btn5: TButton
      AlignWithMargins = True
      Left = 70
      Top = 105
      Width = 68
      Height = 49
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '5'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      TabStop = False
    end
    object btn6: TButton
      AlignWithMargins = True
      Left = 140
      Top = 105
      Width = 68
      Height = 49
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '6'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      TabStop = False
    end
    object btn7: TButton
      AlignWithMargins = True
      Left = 1
      Top = 53
      Width = 67
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '7'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
      TabStop = False
    end
    object btn8: TButton
      AlignWithMargins = True
      Left = 70
      Top = 53
      Width = 68
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '8'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      TabStop = False
    end
    object btn9: TButton
      AlignWithMargins = True
      Left = 140
      Top = 53
      Width = 68
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '9'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 9
      TabStop = False
    end
    object btnAddition: TButton
      AlignWithMargins = True
      Left = 210
      Top = 156
      Width = 67
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '+'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 10
      TabStop = False
    end
    object btnSubtract: TButton
      AlignWithMargins = True
      Left = 210
      Top = 105
      Width = 67
      Height = 49
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '-'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 11
      TabStop = False
    end
    object btnMultiply: TButton
      AlignWithMargins = True
      Left = 210
      Top = 1
      Width = 67
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = 'x'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 12
      TabStop = False
    end
    object btnDivide: TButton
      AlignWithMargins = True
      Left = 210
      Top = 53
      Width = 67
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = #247
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 13
      TabStop = False
    end
    object btnErase: TButton
      AlignWithMargins = True
      Left = 140
      Top = 1
      Width = 68
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '<<'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 14
      TabStop = False
      OnClick = btnEraseClick
    end
    object btnSquare: TButton
      AlignWithMargins = True
      Left = 70
      Top = 1
      Width = 68
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = 'm'#178
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 15
      TabStop = False
    end
    object btnC: TButton
      AlignWithMargins = True
      Left = 1
      Top = 1
      Width = 67
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = 'C'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 16
      TabStop = False
      OnClick = btnCClick
    end
    object btnCalculate: TButton
      AlignWithMargins = True
      Left = 210
      Top = 208
      Width = 67
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 17
      TabStop = False
      OnClick = btnCalculateClick
    end
    object btnSeperate: TButton
      AlignWithMargins = True
      Left = 140
      Top = 208
      Width = 68
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = ','
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 18
      TabStop = False
    end
    object btnArtiEksi: TButton
      AlignWithMargins = True
      Left = 1
      Top = 208
      Width = 67
      Height = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = '+/-'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 19
      TabStop = False
      OnClick = btnArtiEksiClick
    end
  end
end
