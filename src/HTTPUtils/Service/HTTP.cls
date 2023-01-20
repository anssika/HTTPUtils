Class HTTPUtils.Service.HTTP Extends Ens.BusinessService
{

/// Parameter ADAPTER = "EnsLib.HTTP.InboundAdapter";
Parameter ADAPTER = "HTTPUtils.HTTP.InboundAdapter";

/// Name of the business host to send messages to
Property TargetConfigName As Ens.DataType.ConfigName;

/// Number of seconds to wait for the response from <property>TargetConfigName</property>
Property Timeout As %Integer [ InitialExpression = 2 ];

Parameter SETTINGS = "TargetConfigName:Basic,Timeout:Basic";

Method OnProcessInput(pInput As %Stream.Object, Output pOutput As %Stream.Object) As %Status
{
	#Dim tStatus As %Status = $$$OK

	$$$LOGINFO("pInput = " _ pInput)

	#Dim tRequest As HTTPUtils.Message.HTTPRequest = ##class(HTTPUtils.Message.HTTPRequest).%New()
	Set tRequest.Method = pInput.Attributes("HttpRequest")
	Set tRequest.URL = pInput.Attributes("URL") _ "?" _ pInput.Attributes("RawParams")
	Set tRequest.Body = pInput.Read()

	#Dim tResponse As HTTPUtils.Message.HTTPResponse
	Set tStatus = ..SendRequestSync(..TargetConfigName, tRequest, .tResponse, ..Timeout)

	If ($$$ISERR(tStatus)) Return tStatus

	// Timeout?
	If ('$IsObject(tResponse)) {
		Return $$$ERROR($$$GeneralError, "Timeout when waiting for response from " _ ..TargetConfigName)
	}

	If (pInput.%IsA("%Library.GlobalBinaryStream")) {
		Set pOutput = ##class(%GlobalBinaryStream).%New()
	}
	Else {
		Set pOutput = ##class(%GlobalCharacterStream).%New()
	}
	Do pOutput.Write(tResponse.Body)
	$$$LOGINFO("pOutput = " _ pOutput)

	If (pInput.GetAttribute("Accept") '= "") {
		Set pOutput.Attributes("Content-Type") = pInput.GetAttribute("Accept")
	}
	ElseIf (pInput.GetAttribute("Content-Type") '= "") {
		Set pOutput.Attributes("Content-Type") = pInput.GetAttribute("Content-Type")
	}
	Else {
		Set pOutput.Attributes("Content-Type") = "application/json"
	}

	Return tStatus
}

}
