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
    ATSend: TButton;
    lblFrom: TLabel;
    lblTo: TLabel;
    txtFrom: TEdit;
    txtTo: TEdit;
    grpSend: TGroupBox;
    btnSendWithGraphApi: TButton;
    btnSendCloudPack: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure ATSendClick(Sender: TObject);
    procedure AuthenticateClick(Sender: TObject);
    procedure btnSendCloudPackClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OutlookMail1Error(Sender: TObject; AError: Exception);
    procedure btnSendWithGraphApiClick(Sender: TObject);
    procedure OutlookMail1Authenticated(Sender: TObject; var ATestTokens: Boolean);
    procedure OutlookMail1RequestComplete(Sender: TObject; const ARequestResult: TTMSFNCCloudBaseRequestResult);
  private
    fInifile: TInifile;
    FSharedMailboxAddress: string;
    FRecipientEmail: string;
    FCurrentAccessToken: string; // Store access token here
  public
  end;

var
  OutLookAzureTest: TOutLookAzureTest;

implementation

{$R *.dfm}

uses
  System.NetConsts;

procedure TOutLookAzureTest.FormDestroy(Sender: TObject);
begin
  fInifile.Free;
end;

procedure TOutLookAzureTest.FormCreate(Sender: TObject);
begin
  fInifile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.INI'));
  FSharedMailboxAddress := fInifile.ReadString('Mail', 'Sender', '');
  FRecipientEmail := fInifile.ReadString('Mail', 'Receiver', '');
  txtFrom.Text := FSharedMailboxAddress;
  txtTo.Text := FRecipientEmail;
  OutlookMail1.Authentication.ClientID := fInifile.ReadString('Mail', 'ClientID', '');
  OutlookMail1.Authentication.Secret := fInifile.ReadString('Mail', 'Secret', '');
  btnSendWithGraphApi.Enabled := False;
end;

procedure TOutLookAzureTest.AuthenticateClick(Sender: TObject);
begin
  MemoLog.Lines.Add('Attempting to authenticate...');
  OutlookMail1.Authenticate;
end;

procedure TOutLookAzureTest.OutlookMail1Authenticated(Sender: TObject; var ATestTokens: Boolean);
begin
  // Access the AccessToken via the Authentication property
  FCurrentAccessToken := OutlookMail1.Authentication.AccessToken;
  btnSendWithGraphApi.Enabled := True;

  OutlookMail1.OnRequestComplete := OutlookMail1RequestComplete;
  OutlookMail1.GetUserInfo;   // This generate a new request
end;

procedure TOutLookAzureTest.OutlookMail1Error(Sender: TObject; AError: Exception);
begin
  MemoLog.Lines.Add('Authentication Error: ' + AError.Message);
  btnSendWithGraphApi.Enabled := False;
end;

procedure TOutLookAzureTest.btnSendWithGraphApiClick(Sender: TObject);
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
  if not btnSendWithGraphApi.Enabled then
  begin
    MemoLog.Lines.Add('Please authenticate first.');
    Exit;
  end;

  if FCurrentAccessToken = '' then
  begin
    MemoLog.Lines.Add('Access token is missing. Please authenticate.');
    Exit;
  end;

  MemoLog.Lines.Add('Attempting to send email from ' + FSharedMailboxAddress + '...');

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
    EmailAddress.AddPair('address', FSharedMailboxAddress);
    EmailAddress.AddPair('name', 'Company Support');

    ToRecipients := TJSONArray.Create;
    MessageObject.AddPair('toRecipients', ToRecipients);

    ToRecipient := TJSONObject.Create;
    ToRecipients.AddElement(ToRecipient);

    EmailAddress := TJSONObject.Create;
    ToRecipient.AddPair('emailAddress', EmailAddress);
    EmailAddress.AddPair('address', FRecipientEmail);
    EmailAddress.AddPair('name', 'Test Recipient');

    MessageObject.AddPair('subject', 'Test Email from Delphi App (Shared Mailbox)');

    BodyObject := TJSONObject.Create;
    MessageObject.AddPair('body', BodyObject);
    BodyObject.AddPair('contentType', 'HTML');
    BodyObject.AddPair('content', '<h1>Hello!</h1><p>This email was sent from <b>' + FSharedMailboxAddress + '</b> using Microsoft Graph API.</p><p>Sent at ' + DateTimeToStr(Now) + '</p>');

    try
      GraphFullURL := 'https://graph.microsoft.com/v1.0/users/' + FSharedMailboxAddress + '/sendMail';

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

procedure TOutLookAzureTest.ATSendClick(Sender: TObject);
begin
//
end;

procedure TOutLookAzureTest.btnSendCloudPackClick(Sender: TObject);
begin
//
end;

procedure TOutLookAzureTest.OutlookMail1RequestComplete(Sender: TObject; const
    ARequestResult: TTMSFNCCloudBaseRequestResult);
var
  JSONValue: TJSONValue;
  JSONObject: TJSONObject;
  mail: string;
begin
  OutlookMail1.OnRequestComplete := nil;

  if ARequestResult.Success then
  begin
    JSONValue := TJSONObject.ParseJSONValue(ARequestResult.ResultString);
    try
      if Assigned(JSONValue) and (JSONValue is TJSONObject) then
      begin
        JSONObject := TJSONObject(JSONValue);
        if JSONObject.TryGetValue<string>('mail', mail) then
        begin
          MemoLog.Lines.Add('Authentication success. User mail: ' + mail);
        end
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

end.
