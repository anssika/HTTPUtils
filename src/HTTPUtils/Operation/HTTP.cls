Class HTTPUtils.Operation.HTTP Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method HTTPRequest(pRequest As HTTPUtils.Message.HTTPRequest, Output pResponse As HTTPUtils.Message.HTTPResponse) As %Status
{
	#Dim tStatus As %Status

	#Dim tURL As %String = ..Adapter.URL _ "/" _ pRequest.URL
	Set tURL = $Replace(tURL, "//", "/")
	$$$LOGINFO("About to invoke " _ pRequest.Method _ " " _ tURL)

	#Dim tHTTPRequest As %Net.HttpRequest = ##class(%Net.HttpRequest).%New()
	#Dim i As %Integer
	For i=1:1:3 {
		#Dim tHeaderName As %String = $Property(pRequest, "Header" _ i _ "Name")
		#Dim tHeaderValue As %String = $Property(pRequest, "Header" _ i _ "Value")
		If (tHeaderName = "Content-Type") {
			Set tHTTPRequest.ContentType = tHeaderValue
		}
		ElseIf (tHeaderName '= "") {
			$$$LOGINFO("Header " _ tHeaderName _ " with value " _ tHeaderValue _ " ignored") 
		}
	}

	#Dim tHTTPResponse As %Net.HttpResponse
	If (pRequest.Method = "GET") {
		Set tStatus = ..InvokeHTTP(tHTTPRequest, pRequest.Method, tURL, .tHTTPResponse)
	}
	ElseIf ((pRequest.Method = "POST") || (pRequest.Method = "PUT") || (pRequest.Method = "DELETE")) {
		Set tStatus = ..InvokeHTTP(tHTTPRequest, pRequest.Method, tURL, .tHTTPResponse,, pRequest.HTTPBody)
	}
	Else {
		Set tStatus = $$$ERROR($$$GeneralError, "Unexpected HTTPMethod " _ pRequest.Method)
	}

	If ($$$ISERR(tStatus)) {
		If ($IsObject($Get(tHTTPResponse))) {
			// To return more information about the error (the HTTP body),
			// return an interoperability message instead of a %Status
			// But (additionally) log the status
			$$$LOGSTATUS(tStatus)
		}
		Else {
			Return tStatus
		}
	}

	Set pResponse = ##class(HTTPUtils.Message.HTTPResponse).%New()
	Set pResponse.StatusLine = tHTTPResponse.StatusLine
	Set pResponse.MessageBody = tHTTPResponse.Data
	If ($IsObject(tHTTPResponse.Data)) {
 $$$LOGINFO("tHTTPResponse.Data.Size = " _ tHTTPResponse.Data.Size)
 $$$LOGINFO("tHTTPResponse.Data.Read() = " _ tHTTPResponse.Data.Read())
 Do tHTTPResponse.Data.Rewind()
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
