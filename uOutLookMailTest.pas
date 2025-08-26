unit uOutLookMailTest;

interface

uses
  System.IniFiles, System.SysUtils, System.Classes, System.JSON,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, // Standard VCL units
  VCL.TMSFNCCustomComponent, VCL.TMSFNCCloudBase, VCL.TMSFNCCloudOAuth,
  VCL.TMSFNCCloudMicrosoft, VCL.TMSFNCCloudMicrosoftOutlookMail, // TMS CloudPack
  System.JSON.Writers,    // Required for TJSONFormat
  System.Net.HttpClient,  // For THTTPClient (defines THTTPClient and IHTTPResponse)
  System.Net.URLClient,   // Used by THTTPClient for URI handling
  System.Net.Mime;        // For TMediaType or general MIME types

type
  TOutLookAzureTest = class(TForm)
    OutlookMail1: TTMSFNCCloudMicrosoftOutlookMail;
    MemoLog: TMemo;
    lblFrom: TLabel;
    lblTo: TLabel;
    txtFrom: TEdit;
    txtTo: TEdit;
    btnSendWithGraphAPI: TButton;
    btnSendCloudPack: TButton;
    lblSharedMail: TLabel;
    txtSharedMail: TEdit;
    procedure FormDestroy(Sender: TObject);
    procedure AuthenticateClick(Sender: TObject);
    procedure btnSendCloudPackClick(Sender: TObject);
    procedure btnSendWithGraphAPIClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OutlookMail1Error(Sender: TObject; AError: Exception);
    procedure OutlookMail1Authenticated(Sender: TObject; var ATestTokens: Boolean);
    procedure OutlookMail1RequestComplete(Sender: TObject; const ARequestResult: TTMSFNCCloudBaseRequestResult);
    procedure OutlookMail1SendMessage(Sender: TObject; const ARequestResult:
        TTMSFNCCloudBaseRequestResult);
  private
    fInifile: TInifile;
    FCurrentAccessToken: string; // Store access token here
  end;

var
  OutLookAzureTest: TOutLookAzureTest;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  System.NetConsts;

procedure TOutLookAzureTest.FormDestroy(Sender: TObject);
begin
  fInifile.Free;
end;

procedure TOutLookAzureTest.FormCreate(Sender: TObject);
begin
  fInifile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.INI'));
  txtFrom.Text := fInifile.ReadString('Mail', 'Sender', '');
  txtSharedMail.Text := fInifile.ReadString('Mail', 'SharedMB', '');
  txtTo.Text := fInifile.ReadString('Mail', 'Receiver', '');
  OutlookMail1.Authentication.ClientID := fInifile.ReadString('Mail', 'ClientID', '');
  OutlookMail1.Authentication.Secret := fInifile.ReadString('Mail', 'Secret', '');
end;

procedure TOutLookAzureTest.AuthenticateClick(Sender: TObject);
begin
  MemoLog.Lines.Add('Attempting to authenticate...');
  OutlookMail1.Authenticate;
end;

procedure TOutLookAzureTest.btnSendCloudPackClick(Sender: TObject);
const
  MaxFileSize = 3 * 1024 * 1024; // 3 MB
var
  sRecipients, AttachmentList: TStringList;
  oAttachmentFileList: TTMSFNCCloudMicrosoftOutlookMailFiles;
begin
  sRecipients := TStringList.Create;
  AttachmentList := TStringList.Create;
  oAttachmentFileList := TTMSFNCCloudMicrosoftOutlookMailFiles.Create(nil);
  try
    sRecipients.Add(txtFrom.Text);
    var oAttachmentFile: TTMSFNCCloudMicrosoftOutlookMailFile;
    var sFilePath: string;

    AttachmentList.CommaText := 'C:\Attracs\BPL\AttracsComponentsXE12Athens.drc';
    for sFilePath in AttachmentList do
    begin
      if not FileExists(sFilePath) then
        raise Exception.Create('Attachment file not found: ' + sFilePath);

      if TFile.GetSize(sFilePath) > MaxFileSize then
        raise Exception.Create('Attachment exceeds 3 MB: ' + sFilePath);

      oAttachmentFile := oAttachmentFileList.Add;
      oAttachmentFile.&File := sFilePath;
    end;

    OutlookMail1.SendMessage('Test Email from Delphi App (personal Mailbox)',
                             '<h1>Hello!</h1><p>This email was sent from <b>' + txtFrom.Text + '</b> using FNC CloudPack.</p><p>Sent at ' + DateTimeToStr(Now) + '</p>',
                             sRecipients, nil, nil, mtHTML, oAttachmentFileList);
  finally
    FreeAndNil(oAttachmentFileList);
    FreeAndNil(AttachmentList);
    FreeAndNil(sRecipients);
  end;
end;

procedure TOutLookAzureTest.btnSendWithGraphAPIClick(Sender: TObject);
var
  HttpClient: THTTPClient;
  MessagePayload: TJSONObject;
  MessageObject: TJSONObject;
  FromObject: TJSONObject;
  ToRecipients: TJSONArray;
  ToRecipient: TJSONObject;
  EmailAddress: TJSONObject;
  BodyObject: TJSONObject;
  HttpResponse: IHTTPResponse;
  ResponseText: string;
  GraphFullURL: string;
  HttpStatus: Integer;
  StringStream: TStringStream; // Variable for the stream
begin
  if FCurrentAccessToken = '' then
  begin
    MemoLog.Lines.Add('Access token is missing. Please authenticate.');
    Exit;
  end;

  MemoLog.Lines.Add('Attempting to send email from ' + txtSharedMail.Text + '...');

  HttpClient := THTTPClient.Create;
  MessagePayload := TJSONObject.Create;
  try
    // --- 1. Build the JSON Payload ---
    MessageObject := TJSONObject.Create;
    MessagePayload.AddPair('message', MessageObject);
    MessagePayload.AddPair('saveToSentItems', TJSONTrue.Create);

    FromObject := TJSONObject.Create;
    MessageObject.AddPair('from', FromObject);

    EmailAddress := TJSONObject.Create;
    FromObject.AddPair('emailAddress', EmailAddress);
    EmailAddress.AddPair('address', txtSharedMail.Text);
    EmailAddress.AddPair('name', 'Company Support');

    ToRecipients := TJSONArray.Create;
    MessageObject.AddPair('toRecipients', ToRecipients);

    ToRecipient := TJSONObject.Create;
    ToRecipients.AddElement(ToRecipient);

    EmailAddress := TJSONObject.Create;
    ToRecipient.AddPair('emailAddress', EmailAddress);
    EmailAddress.AddPair('address', txtTo.Text);
    EmailAddress.AddPair('name', 'Test Recipient');

    MessageObject.AddPair('subject', 'Test Email from Delphi App (Shared Mailbox)');

    BodyObject := TJSONObject.Create;
    MessageObject.AddPair('body', BodyObject);
    BodyObject.AddPair('contentType', 'HTML');
    BodyObject.AddPair('content', '<h1>Hello!</h1><p>This email was sent from <b>' + txtSharedMail.Text + '</b> using Microsoft Graph API.</p><p>Sent at ' + DateTimeToStr(Now) + '</p>');

    try
      GraphFullURL := 'https://graph.microsoft.com/v1.0/users/' + txtSharedMail.Text + '/sendMail';

      HttpClient.ContentType := 'application/json';
      HttpClient.CustHeaders.Add('Authorization', 'Bearer ' + FCurrentAccessToken);

      MemoLog.Lines.Add('Sending request to: ' + GraphFullURL);
      MemoLog.Lines.Add('Payload: ' + MessagePayload.ToJSON);

      StringStream := TStringStream.Create(MessagePayload.ToJSON, TEncoding.UTF8);
      try
        HttpResponse := HttpClient.Post(GraphFullURL, StringStream);
      finally
        StringStream.Free;
      end;

      // --- 3. Process the Response ---
      ResponseText := HttpResponse.ContentAsString;
      HttpStatus := HttpResponse.StatusCode;

      if (HttpStatus >= 200) and (HttpStatus <= 299) then
      begin
        MemoLog.Lines.Add('Email sent successfully! Status: ' + HttpStatus.ToString);
      end
      else
      begin
        MemoLog.Lines.Add('Failed to send email. Status Code: ' + IntToStr(HttpStatus));
        MemoLog.Lines.Add('Response: ' + ResponseText);
      end;
    except
      on E: Exception do
      begin
        MemoLog.Lines.Add('Error sending email: ' + E.ClassName + ': ' + E.Message);
        if Assigned(HttpResponse) then
          MemoLog.Lines.Add('HTTP Response during error: ' + HttpResponse.ContentAsString)
        else
          MemoLog.Lines.Add('No HTTP Response captured during error.');
      end;
    end;
  finally
    HttpClient.Free;
    MessagePayload.Free;
  end;
end;

procedure TOutLookAzureTest.OutlookMail1Authenticated(Sender: TObject; var ATestTokens: Boolean);
begin
  // Access the AccessToken via the Authentication property
  FCurrentAccessToken := OutlookMail1.Authentication.AccessToken;
  if OutlookMail1.Authentication.IsAccessTokenValid then
  begin
    btnSendCloudPack.Enabled := True;
    btnSendWithGraphAPI.Enabled := True;
    OutlookMail1.GetUserInfo;
    MemoLog.Lines.Add('Authentication successful');
  end;
end;

procedure TOutLookAzureTest.OutlookMail1Error(Sender: TObject; AError: Exception);
begin
  MemoLog.Lines.Add('Authentication Error: ' + AError.Message);
  btnSendCloudPack.Enabled := False;
  btnSendWithGraphAPI.Enabled := False;
end;

procedure TOutLookAzureTest.OutlookMail1RequestComplete(Sender: TObject; const
    ARequestResult: TTMSFNCCloudBaseRequestResult);
var
  JSONValue: TJSONValue;
  JSONObject: TJSONObject;
  mail: string;
begin
  if ARequestResult.Success then
  begin
    JSONValue := TJSONObject.ParseJSONValue(ARequestResult.ResultString);
    try
      if Assigned(JSONValue) and (JSONValue is TJSONObject) then
      begin
        JSONObject := TJSONObject(JSONValue);
        if JSONObject.TryGetValue<string>('mail', mail) then
          MemoLog.Lines.Add('User mail: ' + mail)
        else
          MemoLog.Lines.Add('mail not found');
      end
      else
        MemoLog.Lines.Add('Invalid JSON or not an object');
    finally
      JSONValue.Free;
    end;
  end;
end;

procedure TOutLookAzureTest.OutlookMail1SendMessage(Sender: TObject; const
    ARequestResult: TTMSFNCCloudBaseRequestResult);
begin
  if ARequestResult.Success then
    MemoLog.Lines.Add('Email send OK')
  else
    MemoLog.Lines.Add('Email failure: ' + ARequestResult.ToString);
end;

end.
