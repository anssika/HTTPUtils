Class HTTPUtils.Message.HTTPResponse Extends Ens.Response
{

/// HTTP Status Line
Property StatusLine As %String;

Property Body As %String(MAXLEN = "");

Storage Default
{
<Data name="HTTPResponseDefaultData">
<Subscript>"HTTPResponse"</Subscript>
<Value name="1">
<Value>StatusLine</Value>
</Value>
<Value name="2">
<Value>Body</Value>
</Value>
</Data>
<DefaultData>HTTPResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
