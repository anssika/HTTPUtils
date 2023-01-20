Class HTTPUtils.Operation.FHIR Extends HTTPUtils.Operation.HTTPJSON
{

/// The value of the HTTP header Content-Type of the HTTP request
Parameter HEADERCONTENTTYPE = "application/fhir+json";

/// The value of the HTTP header Accept of the HTTP request
Parameter HEADERACCEPT = "application/fhir+json";

XData MessageMap
{
<MapItems>
	<MapItem MessageType="HTTPUtils.Message.HTTPRequestFHIR"> 
		<Method>HTTPRequest</Method>
	</MapItem>
</MapItems>
}

}
