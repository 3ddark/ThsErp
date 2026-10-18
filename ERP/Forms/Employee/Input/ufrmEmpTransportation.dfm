object frmEmpTransportation: TfrmEmpTransportation
  Left = 0
  Top = 0
  Caption = 'Shuttle Service'
  ClientHeight = 204
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
    Height = 204
    Align = alClient
    TabOrder = 0
    object lblCarNo: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Car No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCarNo: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object lblCarName: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Car Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCarName: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 1
    end
    object lblRouteDescription: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Route / Stops'
    end
    object mmoRouteDescription: TMemo
      Left = 132
      Top = 48
      Width = 333
      Height = 88
      MaxLength = 512
      ScrollBars = ssVertical
      TabOrder = 2
    end
  end
end
