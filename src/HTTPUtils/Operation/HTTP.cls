Class HTTPUtils.Operation.HTTP Extends Ens.BusinessOperation
{

/// Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";
Parameter ADAPTER = "HTTPUtils.HTTP.OutboundAdapter";

/// Property Adapter As EnsLib.HTTP.OutboundAdapter;
Property Adapter As HTTPUtils.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method HTTPRequest(pRequest As HTTPUtils.Message.HTTPRequest, Output pResponse As HTTPUtils.Message.HTTPResponse) As %Status
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
	#Dim i As %Integer
	For i=1:1:3 {
		#Dim tHeaderName As %String = $Property(pRequest, "Header" _ i _ "Name")
		#Dim tHeaderValue As %String = $Property(pRequest, "Header" _ i _ "Value")
		If ($ZConvert(tHeaderName, "U") = "CONTENT-TYPE") {
			$$$LOGINFO("Setting tHTTPRequest.ContentType = " _ tHeaderValue) 
			Set tHTTPRequest.ContentType = tHeaderValue
		}
		ElseIf (tHeaderName '= "") {
			$$$LOGINFO("Setting header " _ tHeaderName _ " with value " _ tHeaderValue _ " of tHTTPRequest")
			Do tHTTPRequest.SetHeader(tHeaderName, tHeaderValue)
		}
	}

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

	// HTTP headers returned
	#Dim tValue As %String = ""
	#Dim tHeader As %String = $Order(tHTTPResponse.Headers(""), 1, tValue)
	While (tHeader '= "") {
		$$$LOGINFO("HTTP Header received: name = " _ tHeader _ ", value = " _ tValue)
		Set tHeader = $Order(tHTTPResponse.Headers(tHeader), 1, tValue)
	}

	// Create return message
	Set pResponse = ##class(HTTPUtils.Message.HTTPResponse).%New()
	Set pResponse.StatusLine = tHTTPResponse.StatusLine
	Set pResponse.MessageBody = tHTTPResponse.Data
	If ($IsObject(tHTTPResponse.Data)) {
		Set pResponse.MessageBody = ""
		While ('tHTTPResponse.Data.AtEnd) {
			Set pResponse.MessageBody = pResponse.MessageBody _ tHTTPResponse.Data.Read()
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
	<MapItem MessageType="HTTPUtils.Message.HTTPRequest"> 
		<Method>HTTPRequest</Method>
	</MapItem>
</MapItems>
}

}
