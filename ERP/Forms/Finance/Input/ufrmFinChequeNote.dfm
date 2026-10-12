object frmFinChequeNote: TfrmFinChequeNote
  Left = 0
  Top = 0
  Caption = #199'ek / Senet'
  ClientHeight = 299
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
    Height = 299
    Align = alClient
    TabOrder = 0
    object lblDocKind: TLabel
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
    object cbbDocKind: TComboBox
      Left = 132
      Top = 2
      Width = 260
      Height = 22
      Style = csDropDownList
      TabOrder = 0
    end
    object lblDirection: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Y'#246'n'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbDirection: TComboBox
      Left = 132
      Top = 25
      Width = 260
      Height = 22
      Style = csDropDownList
      TabOrder = 1
    end
    object lblPortfolioNo: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Portf'#246'y No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPortfolioNo: TEdit
      Left = 132
      Top = 48
      Width = 260
      Height = 22
      MaxLength = 16
      TabOrder = 2
    end
    object lblSerialNo: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #199'ek / Senet No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSerialNo: TEdit
      Left = 132
      Top = 71
      Width = 260
      Height = 22
      MaxLength = 32
      TabOrder = 3
    end
    object lblIssueDate: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ke'#351'ide Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtIssueDate: TEdit
      Left = 132
      Top = 94
      Width = 260
      Height = 22
      TabOrder = 4
    end
    object lblDueDate: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Vade Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDueDate: TEdit
      Left = 132
      Top = 117
      Width = 260
      Height = 22
      TabOrder = 5
    end
    object lblAmount: TLabel
      Left = 4
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tutar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAmount: TEdit
      Left = 132
      Top = 140
      Width = 260
      Height = 22
      TabOrder = 6
    end
    object lblCurrency: TLabel
      Left = 4
      Top = 167
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
      Left = 132
      Top = 163
      Width = 260
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 7
    end
    object lblAccAccountId: TLabel
      Left = 4
      Top = 190
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Cari (Al'#305'nan / Verilen)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccAccountId: TEdit
      Left = 132
      Top = 186
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 8
    end
    object lblStatusText: TLabel
      Left = 4
      Top = 213
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Durum'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtStatusText: TEdit
      Left = 132
      Top = 209
      Width = 260
      Height = 22
      ReadOnly = True
      TabStop = False
      TabOrder = 9
    end
    object lblDrawerName: TLabel
      Left = 408
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ke'#351'ideci / Bor'#231'lu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDrawerName: TEdit
      Left = 536
      Top = 2
      Width = 260
      Height = 22
      MaxLength = 128
      TabOrder = 10
    end
    object lblDrawerTaxNo: TLabel
      Left = 408
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ke'#351'ideci VKN / TCKN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDrawerTaxNo: TEdit
      Left = 536
      Top = 25
      Width = 260
      Height = 22
      MaxLength = 16
      TabOrder = 11
    end
    object lblIssuePlace: TLabel
      Left = 408
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ke'#351'ide Yeri'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtIssuePlace: TEdit
      Left = 536
      Top = 48
      Width = 260
      Height = 22
      MaxLength = 64
      TabOrder = 12
    end
    object lblAccBankId: TLabel
      Left = 408
      Top = 75
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
      Left = 536
      Top = 71
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 13
    end
    object lblAccBankBranchId: TLabel
      Left = 408
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Banka '#350'ubesi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccBankBranchId: TEdit
      Left = 536
      Top = 94
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 14
    end
    object lblBankAccountNo: TLabel
      Left = 408
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Hesap No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBankAccountNo: TEdit
      Left = 536
      Top = 117
      Width = 260
      Height = 22
      MaxLength = 32
      TabOrder = 15
    end
    object lblGuarantorName: TLabel
      Left = 408
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kefil'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtGuarantorName: TEdit
      Left = 536
      Top = 140
      Width = 260
      Height = 22
      MaxLength = 128
      TabOrder = 16
    end
    object lblNotes: TLabel
      Left = 408
      Top = 167
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
      Left = 536
      Top = 163
      Width = 260
      Height = 68
      MaxLength = 512
      ScrollBars = ssVertical
      TabOrder = 17
    end
  end
end
