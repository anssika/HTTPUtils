/// A process that queries updates in SourceSystem and, if updates found, sends them to TargetSystem
Class HTTPUtils.Training.Process.Update Extends Ens.BusinessProcess
{

/// Name of the operation to connect to the SourceSystem (business host name)
Property SourceSystemName As Ens.DataType.ConfigName [ InitialExpression = "To_SourceSystem" ];

/// Name of the operation to connect to the SourceSystem (business host name)
Property TargetSystemName As Ens.DataType.ConfigName [ InitialExpression = "To_TargetSystem" ];

/// Number of seconds to wait for the response from business operations
Property Timeout As %Integer [ InitialExpression = 3 ];

Parameter SETTINGS = "SourceSystemName:Basic,TargetSystemName:Basic";

Method OnRequest(pRequest As HTTPUtils.Message.HTTPRequestJSON, Output pResponse As HTTPUtils.Message.HTTPResponse) As %Status
{
	#Dim tStatus As %Status = $$$OK

	#Dim tRequest As HTTPUtils.Message.HTTPRequest;
	#Dim tResponse As HTTPUtils.Message.HTTPResponse;

	/* ********************************************************************************
	**	Query any updates from the SourceSystem
	*/

	#Dim tStart As %String = $Get(^HTTPUtils.Training.Process.Update.Start, $ZDateTime(($Horolog-5) _ ",0", "3"))
	Set tRequest = ##class(HTTPUtils.Message.HTTPRequestJSON).%New()

	Set tRequest.Method = "GET"
	Set tRequest.URL = "/GetUpdates?start=" _ $ZConvert(tStart, "O", "URL")
	//Set tRequest.URL = "/GetUpdates?start=x"
	Set tRequest.Body = ""

	Set tStatus = ..SendRequestSync(..SourceSystemName, tRequest, .tResponse, ..Timeout)

	// Error?
	If ($$$ISERR(tStatus)) Return tStatus

	// Timeout?
	If ('$IsObject(tResponse)) {
		Return $$$ERROR($$$GeneralError, "Timeout when waiting for response from " _ ..TargetSystemName)
	}

	/* ********************************************************************************
	**	Process the response
	**
	**	Save the time of latest updates
	**	Send updates, if any, to the target system
	*/

	#Dim tJSON As %DynamicAbstractObject = ##class(%DynamicAbstractObject).%FromJSON(tResponse.Body)

	// Save the time of the latest updates for the next invocation
	Set ^HTTPUtils.Training.Process.Update.Start = tJSON.end

	// Updates?
	If (tJSON.updates = "") Return tStatus

	// Send the updates to the target system
	Set tRequest = ##class(HTTPUtils.Message.HTTPRequestJSON).%New()

	Set tRequest.Method = "POST"
	Set tRequest.URL = "/Updates"
	Set tRequest.Body = tJSON.updates

	Set tStatus = ..SendRequestSync(..TargetSystemName, tRequest, .pResponse, ..Timeout)

	// Error?
	If ($$$ISERR(tStatus)) Return tStatus

	// Timeout?
	If ('$IsObject(pResponse)) {
		Return $$$ERROR($$$GeneralError, "Timeout when waiting for response from " _ ..SourceSystemName)
	}

	Return tStatus
}

Storage Default
{
<Data name="UpdateDefaultData">
<Subscript>"Update"</Subscript>
<Value name="1">
<Value>SourceSystemName</Value>
</Value>
<Value name="2">
<Value>TargetSystemName</Value>
</Value>
<Value name="3">
<Value>Timeout</Value>
</Value>
</Data>
<DefaultData>UpdateDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
