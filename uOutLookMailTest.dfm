object OutLookAzureTest: TOutLookAzureTest
  Left = 0
  Top = 0
  Caption = 'Test email with OutLook Azure'
  ClientHeight = 272
  ClientWidth = 852
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object lblFrom: TLabel
    Left = 8
    Top = 16
    Width = 28
    Height = 15
    Caption = 'From'
  end
  object lblTo: TLabel
    Left = 8
    Top = 48
    Width = 12
    Height = 15
    Caption = 'To'
  end
  object Authenticate: TButton
    Left = 8
    Top = 84
    Width = 121
    Height = 25
    Caption = 'Authenticate'
    TabOrder = 0
    OnClick = AuthenticateClick
  end
  object MemoLog: TMemo
    Left = 304
    Top = 0
    Width = 548
    Height = 272
    Align = alRight
    Lines.Strings = (
      '')
    TabOrder = 1
  end
  object OutlookMail1: TTMSFNCCloudMicrosoftOutlookMail
    Left = 167
    Top = 224
    Width = 26
    Height = 26
    Visible = True
    Logging = True
    Authentication.CallBackURL = 'http://localhost:8000'
    OnAuthenticated = OutlookMail1Authenticated
    Mails = <>
    Folders = <>
  end
  object ATSend: TButton
    Left = 8
    Top = 239
    Width = 108
    Height = 25
    Caption = 'Attracs Send'
    TabOrder = 4
    OnClick = ATSendClick
  end
  object txtFrom: TEdit
    Left = 42
    Top = 13
    Width = 247
    Height = 23
    TabOrder = 5
  end
  object txtTo: TEdit
    Left = 42
    Top = 42
    Width = 247
    Height = 23
    TabOrder = 6
  end
  object grpSend: TGroupBox
    Left = 135
    Top = 84
    Width = 154
    Height = 95
    Caption = 'Send'
    TabOrder = 7
    object btnSendWithGraphApi: TButton
      Left = 10
      Top = 24
      Width = 137
      Height = 25
      Caption = 'Send with Graph Api'
      TabOrder = 0
      OnClick = btnSendWithGraphApiClick
    end
    object btnSendCloudPack: TButton
      Left = 10
      Top = 55
      Width = 137
      Height = 25
      Caption = 'Send with Cloudpack'
      TabOrder = 1
      OnClick = btnSendCloudPackClick
    end
  end
end
