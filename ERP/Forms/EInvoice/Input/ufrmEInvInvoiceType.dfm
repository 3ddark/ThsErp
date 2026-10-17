object frmEInvInvoiceType: TfrmEInvInvoiceType
  Left = 0
  Top = 0
  Caption = 'e-Fatura Tipi'
  ClientHeight = 207
  ClientWidth = 480
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
    Width = 480
    Height = 207
    Align = alClient
    TabOrder = 0
    object lblCode: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Fatura Tipi Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCode: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 0
    end
    object lblName: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ad'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtName: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      MaxLength = 128
      TabOrder = 1
    end
    object lblRequiresExemption: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'stisna Kodu Zorunlu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkRequiresExemption: TCheckBox
      Left = 132
      Top = 51
      Width = 333
      Height = 17
      TabOrder = 2
    end
    object lblRequiresWithholding: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tevkifat Zorunlu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkRequiresWithholding: TCheckBox
      Left = 132
      Top = 74
      Width = 333
      Height = 17
      TabOrder = 3
    end
    object lblIsReturn: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'ade Faturas'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkIsReturn: TCheckBox
      Left = 132
      Top = 97
      Width = 333
      Height = 17
      TabOrder = 4
    end
    object lblIsActive: TLabel
      Left = 4
      Top = 121
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
      Top = 120
      Width = 333
      Height = 17
      TabOrder = 5
    end
  end
end
