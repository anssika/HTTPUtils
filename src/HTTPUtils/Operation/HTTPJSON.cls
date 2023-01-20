Class HTTPUtils.Operation.HTTPJSON Extends Ens.BusinessOperation
{

/// Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";
Parameter ADAPTER = "HTTPUtils.HTTP.OutboundAdapter";

/// Property Adapter As EnsLib.HTTP.OutboundAdapter;
Property Adapter As HTTPUtils.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// The value of the HTTP header Content-Type of the HTTP request
Parameter HEADERCONTENTTYPE = "application/json";

/// The value of the HTTP header Accept of the HTTP request
Parameter HEADERACCEPT = "application/json";

Method HTTPRequest(pRequest As HTTPUtils.Message.HTTPRequestFHIR, Output pResponse As HTTPUtils.Message.HTTPResponse) As %Status
{
	#Dim tStatus As %Status

	#Dim tHTTPRequest As %Net.HttpRequest = ##class(%Net.HttpRequest).%New()

	// HTTP Body
	Do tHTTPRequest.EntityBody.Write(pRequest.Body)

	// URL
	#Dim tURL As %String = ..Adapter.URL _ "/" _ pRequest.URL
	Set tURL = $Replace(tURL, "//", "/")
	$$$LOGINFO("About to invoke " _ pRequest.Method _ " " _ tURL)

	// HTTP Headers
	Set tHTTPRequest.ContentType = ..#HEADERCONTENTTYPE
	Do tHTTPRequest.SetHeader("Accept", ..#HEADERACCEPT)

	// Invoke HTTP
	#Dim tHTTPResponse As %Net.HttpResponse
	If (pRequest.Method = "GET") {
		Set tStatus = ..InvokeHTTP(tHTTPRequest, pRequest.Method, tURL, .tHTTPResponse)
	}
	ElseIf ((pRequest.Method = "POST") || (pRequest.Method = "PUT") || (pRequest.Method = "DELETE")) {
		Set tStatus = ..InvokeHTTP(tHTTPRequest, pRequest.Method, tURL, .tHTTPResponse)
	}
	Else {
		Set tStatus = $$$ERROR($$$GeneralError, "Unexpected HTTPMethod " _ pRequest.Method)
	}

	// Error?
	If ($$$ISERR(tStatus)) Return tStatus

	// Create return message
	Set pResponse = ##class(HTTPUtils.Message.HTTPResponse).%New()
	Set pResponse.StatusLine = tHTTPResponse.StatusLine
	Set pResponse.Body = tHTTPResponse.Data
	If ($IsObject(tHTTPResponse.Data)) {
		Set pResponse.Body = ""
		While ('tHTTPResponse.Data.AtEnd) {
			Set pResponse.Body = pResponse.Body _ tHTTPResponse.Data.Read()
		}
	}

	Return $$$OK
}

Method InvokeHTTP(pHTTPRequest As %Net.HttpRequest, pOp As %String, pURL As %String, Output pHttpResponse As %Net.HttpResponse, pFormVarNames As %String, pData...) As %Status [ CodeMode = expression ]
{
..Adapter.SendFormDataArray(.pHttpResponse, pOp, pHTTPRequest,.pFormVarNames,.pData,pURL)
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="HTTPUtils.Message.HTTPRequestJSON"> 
		<Method>HTTPRequest</Method>
	</MapItem>
</MapItems>
}

}
