Class HTTPUtils.Service.HTTP Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.HTTP.InboundAdapter";

Method OnProcessInput(pInput As %Stream.Object, Output pOutput As %Stream.Object) As %Status
{
	#Dim tStatus As %Status = $$$OK

	#Dim tJSONResponse As %DynamicObject = {}

	// URL = an Attribute
	Set tJSONResponse.URL = pInput.Attributes("URL")

	// Attributes = HTTP headers & more
	Set tJSONResponse.Attributes = []
	#Dim tKey, tValue As %String = ""
	Set tKey = $Order(pInput.Attributes(""),1,tValue)
	While (tKey '= "") {
		Do tJSONResponse.Attributes.%Push({ "Key" : (tKey), "Value" : (tValue)})
		Set tKey = $Order(pInput.Attributes(tKey),1,tValue)
	}

	// Attributes("Params") = HTTP form variables
	$$$LOGWARNING("Attribute Params not processed")
	/* ToDo
	Set tJSONResponse.Params = []
	Set tKey = $Order(pInput.Attributes("Params", "", 1),1,tValue)
	While (tKey '= "") {
		Do tJSONResponse.Params.%Push({ "Key" : (tKey), "Value" : (tValue)})
		Set tKey = $Order(pInput.Attributes("Params", tKey, 1),1,tValue)
	}
	*/

	// Return the JSON as (formatted) HTTP body
	Set pOutput = ##class(%Library.GlobalBinaryStream).%New()
	Set tStatus = ##class(%JSON.Formatter).%New().FormatToStream(tJSONResponse, .pOutput)

	Return tStatus
}

}
