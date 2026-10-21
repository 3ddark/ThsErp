object frmEInvDocumentSetting: TfrmEInvDocumentSetting
  Left = 0
  Top = 0
  Caption = 'e-Belge Ayar'#305
  ClientHeight = 184
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
    Height = 184
    Align = alClient
    TabOrder = 0
    object lblSeriesScope: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Belge T'#252'r'#252
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbSeriesScope: TComboBox
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      Style = csDropDownList
      TabOrder = 0
    end
    object lblEinvSeriesId: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Seri'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEinvSeriesId: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
    object lblSysApiServiceId: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'API Servisi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysApiServiceId: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 2
    end
    object lblSenderAlias: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'G'#246'nderici Etiketi (GB)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSenderAlias: TEdit
      Left = 132
      Top = 71
      Width = 333
      Height = 22
      MaxLength = 256
      TabOrder = 3
    end
    object lblReceiverAlias: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Al'#305'c'#305' Etiketi (PK)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtReceiverAlias: TEdit
      Left = 132
      Top = 94
      Width = 333
      Height = 22
      MaxLength = 256
      TabOrder = 4
    end
  end
end
