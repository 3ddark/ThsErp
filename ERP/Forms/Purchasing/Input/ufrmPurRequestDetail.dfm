object frmPurRequestDetail: TfrmPurRequestDetail
  Left = 0
  Top = 0
  Caption = 'Sat'#305'n Alma Talebi'
  ClientHeight = 600
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
    Height = 121
    Align = alTop
    TabOrder = 0
    object lblRequestNo: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Talep No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtRequestNo: TEdit
      Left = 132
      Top = 2
      Width = 260
      Height = 22
      MaxLength = 16
      TabOrder = 0
    end
    object lblRequestDate: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Talep Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtRequestDate: TEdit
      Left = 132
      Top = 25
      Width = 260
      Height = 22
      TabOrder = 1
    end
    object lblEmpEmployeeId: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Talep Eden'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmpEmployeeId: TEdit
      Left = 132
      Top = 48
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 2
    end
    object lblRequiredDate: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'htiya'#231' Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtRequiredDate: TEdit
      Left = 132
      Top = 71
      Width = 260
      Height = 22
      TabOrder = 3
    end
    object lblStatusText: TLabel
      Left = 408
      Top = 6
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
      Left = 536
      Top = 2
      Width = 260
      Height = 22
      ReadOnly = True
      TabStop = False
      TabOrder = 4
    end
    object lblDescription: TLabel
      Left = 408
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'A'#231#305'klama'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDescription: TEdit
      Left = 536
      Top = 25
      Width = 260
      Height = 22
      MaxLength = 256
      TabOrder = 5
    end
  end
end
