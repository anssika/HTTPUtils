Class HTTPUtils.Message.HTTPRequestHeaders Extends HTTPUtils.Message.HTTPRequest
{

Property Header1Name As %String;

Property Header1Value As %String;

Property Header2Name As %String;

Property Header2Value As %String;

Property Header3Name As %String;

Property Header3Value As %String;

/// Retrieve the latest values as defaults (this is handy for testing)
Method %OnNew() As %Status [ Private, ServerOnly = 1 ]
{
	#Dim tStatus As %Status = ##super()
	If ($$$ISERR(tStatus)) Return tStatus

	Set ..Header1Name = $Get(^HTTPUtils.Message.Request(..%ClassName(1), "Header1Name"), "Content-Type")
	Set ..Header1Value = $Get(^HTTPUtils.Message.Request(..%ClassName(1), "Header1Value"), "application/json")
	Set ..Header2Name = $Get(^HTTPUtils.Message.Request(..%ClassName(1), "Header2Name"), "")
	Set ..Header2Value = $Get(^HTTPUtils.Message.Request(..%ClassName(1), "Header2Value"), "")
	Set ..Header3Name = $Get(^HTTPUtils.Message.Request(..%ClassName(1), "Header3Name"), "")
	Set ..Header3Value = $Get(^HTTPUtils.Message.Request(..%ClassName(1), "Header3Value"), "")

	Quit $$$OK
}

/// Save the latest values used
ClassMethod %OnSaveFinally(oref As %ObjectHandle, status As %Status)
{
	#Dim tStatus As %Status = $$$OK
	Do ##super(oref, .status)
	If ($$$ISERR(tStatus)) Return tStatus

	Set ^HTTPUtils.Message.Request(..%ClassName(1), "Header1Name") = oref.Header1Name
	Set ^HTTPUtils.Message.Request(..%ClassName(1), "Header1Value") = oref.Header1Value
	Set ^HTTPUtils.Message.Request(..%ClassName(1), "Header2Name") = oref.Header2Name
	Set ^HTTPUtils.Message.Request(..%ClassName(1), "Header2Value") = oref.Header2Value
	Set ^HTTPUtils.Message.Request(..%ClassName(1), "Header3Name") = oref.Header3Name
	Set ^HTTPUtils.Message.Request(..%ClassName(1), "Header3Value") = oref.Header3Value
}

Storage Default
{
<Data name="HTTPRequestHeadersDefaultData">
<Subscript>"HTTPRequestHeaders"</Subscript>
<Value name="1">
<Value>Header1Name</Value>
</Value>
<Value name="2">
<Value>Header1Value</Value>
</Value>
<Value name="3">
<Value>Header2Name</Value>
</Value>
<Value name="4">
<Value>Header2Value</Value>
</Value>
<Value name="5">
<Value>Header3Name</Value>
</Value>
<Value name="6">
<Value>Header3Value</Value>
</Value>
</Data>
<DefaultData>HTTPRequestHeadersDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
