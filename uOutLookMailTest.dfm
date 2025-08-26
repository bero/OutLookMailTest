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
    Top = 72
    Width = 12
    Height = 15
    Caption = 'To'
  end
  object lblSharedMail: TLabel
    Left = 8
    Top = 40
    Width = 62
    Height = 15
    Caption = 'Shared mail'
  end
  object Authenticate: TButton
    Left = 8
    Top = 116
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
    ScrollBars = ssBoth
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
    OnSendMessage = OutlookMail1SendMessage
    Mails = <>
    Folders = <>
  end
  object txtFrom: TEdit
    Left = 80
    Top = 13
    Width = 200
    Height = 23
    TabOrder = 4
  end
  object txtTo: TEdit
    Left = 80
    Top = 66
    Width = 200
    Height = 23
    TabOrder = 5
  end
  object btnSendWithGraphAPI: TButton
    Left = 8
    Top = 179
    Width = 217
    Height = 25
    Caption = 'Send with Graph Api shared mailbox'
    Enabled = False
    TabOrder = 6
    OnClick = btnSendWithGraphAPIClick
  end
  object btnSendCloudPack: TButton
    Left = 8
    Top = 148
    Width = 241
    Height = 25
    Caption = 'Send with personal mail and  CloudPack'
    Enabled = False
    TabOrder = 7
    OnClick = btnSendCloudPackClick
  end
  object txtSharedMail: TEdit
    Left = 80
    Top = 37
    Width = 200
    Height = 23
    TabOrder = 8
  end
end
