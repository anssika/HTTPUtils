/// A process that queries updates in SourceSystem and, if updates found, sends them to TargetSystem
Class HTTPUtils.Training.Process.SourceSystem Extends Ens.BusinessProcess
{

/// Updates to return - just string that can be serialized as JSON value. Empty value means no updates.
Property Updates As %String(MAXLEN = "");

Parameter SETTINGS = "Updates:Basic";

Method OnRequest(pRequest As HTTPUtils.Message.HTTPRequestJSON, Output pResponse As HTTPUtils.Message.HTTPResponse) As %Status
{
	#Dim tStatus As %Status = $$$OK

	/* ********************************************************************************
	**	Find out time interval
	*/

	// Start time
	#Dim tParams As %String = $Piece(pRequest.URL, "?", 2)
	$$$LOGINFO("tparams (from URL) = " _ tParams)
	#Dim tStart As %String = $ZConvert($Piece($Piece(tParams, "start=", 2), "&", 1), "I", "URL")
	$$$LOGINFO("start (from URL) = " _ tStart)
	If (tStart = "") {
		Set tStart = $ZDateTime(($Horolog-2) _ ",0", "3")
	}
	$$$LOGINFO("tStart = " _ tStart)

	// End time
	#Dim tEnd As %String = $ZDateTime($Horolog, 3)
	$$$LOGINFO("tEnd = " _ tEnd)

	/* ********************************************************************************
	**	Construct response
	*/

	#Dim tJSON As %DynamicAbstractObject = {}
	Set tJSON.start = tStart
	Set tJSON.end = tEnd
	Set tJSON.updates = ..Updates
	#Dim tResponseString As %String
	Set tStatus = ##class(%JSON.Formatter).%New().FormatToString(tJSON, .tResponseString)

	Set pResponse = ##class(HTTPUtils.Message.HTTPResponse).%New()
	Set pResponse.Body = tResponseString

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
<Value name="4">
<Value>Updates</Value>
</Value>
</Data>
<DefaultData>UpdateDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
