object frmFinPosTerminal: TfrmFinPosTerminal
  Left = 0
  Top = 0
  Caption = 'POS Tan'#305'm'#305
  ClientHeight = 210
  ClientWidth = 811
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 14
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 811
    Height = 210
    Align = alClient
    TabOrder = 0
    object lblPosName: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'POS Ad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPosName: TEdit
      Left = 132
      Top = 2
      Width = 260
      Height = 22
      MaxLength = 64
      TabOrder = 0
    end
    object lblAccBankId: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Banka'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccBankId: TEdit
      Left = 132
      Top = 25
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
    object lblTerminalNo: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Terminal No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTerminalNo: TEdit
      Left = 132
      Top = 48
      Width = 260
      Height = 22
      MaxLength = 32
      TabOrder = 2
    end
    object lblIsActive: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Aktif'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkIsActive: TCheckBox
      Left = 132
      Top = 74
      Width = 260
      Height = 17
      TabOrder = 3
    end
    object lblCommissionRate: TLabel
      Left = 408
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Komisyon Oran'#305' (%)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCommissionRate: TEdit
      Left = 536
      Top = 2
      Width = 260
      Height = 22
      TabOrder = 4
    end
    object lblBlockedDays: TLabel
      Left = 408
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Bloke G'#252'n'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBlockedDays: TEdit
      Left = 536
      Top = 25
      Width = 260
      Height = 22
      TabOrder = 5
    end
    object lblCurrency: TLabel
      Left = 408
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Para Birimi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCurrency: TEdit
      Left = 536
      Top = 48
      Width = 260
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 6
    end
    object lblAccAccountCode: TLabel
      Left = 408
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Muhasebe Hesab'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccAccountCode: TEdit
      Left = 536
      Top = 71
      Width = 260
      Height = 22
      MaxLength = 16
      ReadOnly = True
      TabOrder = 7
    end
    object lblNotes: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Notlar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object mmoNotes: TMemo
      Left = 132
      Top = 94
      Width = 260
      Height = 48
      MaxLength = 512
      ScrollBars = ssVertical
      TabOrder = 8
    end
  end
end
