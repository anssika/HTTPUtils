Class HTTPUtils.Process.Simple Extends Ens.BusinessProcess
{

/// The beody return in response message
Property ResponseBody As %String(MAXLEN = "") [ InitialExpression = "{""status"":""OK""}" ];

Parameter SETTINGS = "ResponseBody:Basic";

Method OnRequest(pRequest As HTTPUtils.Message.HTTPRequest, Output pResponse As HTTPUtils.Message.HTTPResponse) As %Status
{
	#Dim tStatus As %Status = $$$OK

	/* ********************************************************************************
	**	Process the request
	**
	**	Process the request.
	*/

	Set pResponse = ##class(HTTPUtils.Message.HTTPResponse).%New()
	Set pResponse.Body = ..ResponseBody

	Return tStatus
}

Storage Default
{
<Data name="HTTPDefaultData">
<Subscript>"HTTP"</Subscript>
<Value name="1">
<Value>ResponseBody</Value>
</Value>
</Data>
<DefaultData>HTTPDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
