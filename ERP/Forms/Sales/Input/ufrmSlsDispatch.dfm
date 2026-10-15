object frmSlsDispatch: TfrmSlsDispatch
  Left = 0
  Top = 0
  Caption = 'Sevk '#304'rsaliyesi'
  ClientHeight = 161
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
    Height = 161
    Align = alClient
    TabOrder = 0
    object lblDispatchNo: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'rsaliye No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDispatchNo: TEdit
      Left = 132
      Top = 2
      Width = 260
      Height = 22
      MaxLength = 16
      TabOrder = 0
    end
    object lblDispatchDate: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'rsaliye Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDispatchDate: TEdit
      Left = 132
      Top = 25
      Width = 260
      Height = 22
      TabOrder = 1
    end
    object lblAccAccountId: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'M'#252#351'teri'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccAccountId: TEdit
      Left = 132
      Top = 48
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 2
    end
    object lblStkWarehouseId: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ambar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtStkWarehouseId: TEdit
      Left = 132
      Top = 71
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object lblSlsOrderId: TLabel
      Left = 408
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sipari'#351
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSlsOrderId: TEdit
      Left = 536
      Top = 2
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 4
    end
    object lblCurrency: TLabel
      Left = 408
      Top = 29
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
      Top = 25
      Width = 260
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 5
    end
    object lblDescription: TLabel
      Left = 408
      Top = 52
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
      Top = 48
      Width = 260
      Height = 22
      MaxLength = 256
      TabOrder = 6
    end
  end
end
