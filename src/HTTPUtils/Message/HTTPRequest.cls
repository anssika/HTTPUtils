Class HTTPUtils.Message.HTTPRequest Extends Ens.Request
{

/// HTTP Body
Property Body As %String(MAXLEN = "");

Property URL As %String(MAXLEN = 200);

Property Method As %String(VALUELIST = ",GET,POST,PUT,DELETE") [ InitialExpression = "GET" ];

/// Retrieve the latest values as defaults (this is handy for testing)
Method %OnNew() As %Status [ Private, ServerOnly = 1 ]
{
	Set ..Method = $Get(^HTTPUtils.Message.Request(..%ClassName(1), "Method"), "GET")
	Set ..URL = $Get(^HTTPUtils.Message.Request(..%ClassName(1), "URL"), "/aResource")
	Set ..Body = $Get(^HTTPUtils.Message.Request(..%ClassName(1), "Body"), "{""name"": ""value""}")

	Quit $$$OK
}

/// Save the latest values used
ClassMethod %OnSaveFinally(oref As %ObjectHandle, status As %Status)
{
	Set ^HTTPUtils.Message.Request(..%ClassName(1), "Method") = oref.Method
	Set ^HTTPUtils.Message.Request(..%ClassName(1), "URL") = oref.URL
	Set ^HTTPUtils.Message.Request(..%ClassName(1), "Body") = oref.Body
}

Storage Default
{
<Data name="HTTPRequestDefaultData">
<Subscript>"HTTPRequest"</Subscript>
<Value name="1">
<Value>Body</Value>
</Value>
<Value name="2">
<Value>URL</Value>
</Value>
<Value name="3">
<Value>Method</Value>
</Value>
</Data>
<DefaultData>HTTPRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
