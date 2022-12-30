Class HTTPUtils.Service.HTTP Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.HTTP.InboundAdapter";

Method OnProcessInput(pInput As %Stream.Object, Output pOutput As %Stream.Object) As %Status
{
	#Dim tStatus As %Status = $$$OK

	#Dim tJSONResponse As %DynamicObject = ..InspectRequest(pInput)

	Set pOutput = ##class(%Library.GlobalBinaryStream).%New()
	Set tStatus = ##class(%JSON.Formatter).%New().FormatToStream(tJSONResponse, .pOutput)
 $$$LOGINFO("pOutput.Size = " _ pOutput.Size)
 $$$LOGINFO("pOutput.Read() = " _ pOutput.Read())

	Return tStatus
}

Method InspectRequest(pInputStream As %Stream.Object) As %DynamicObject
{
	#Dim tJSONReport As %DynamicObject = {}

	// What is this all about
	Set tJSONReport.about = "This report about an HTTP request received by a business service " _ ..%ConfigName _ "." _
								" Please refer to the source code class HTTPUtils.Service.HTTP for the details."

	// URL = an Attribute
	Set tJSONReport.aboutURL = $ZConvert("pInputStream.Attributes(URL)", "O", "JSON")
	Set tJSONReport.URL = pInputStream.Attributes("URL")

	// Attributes = HTTP headers & more
	Set tJSONReport.aboutAttributes = "pInputStream.Attributes(*) for each *"
	Set tJSONReport.Attributes = []
	#Dim tKey, tValue As %String = ""
	Set tKey = $Order(pInputStream.Attributes(""), 1, tValue)
	While (tKey '= "") {
		Do tJSONReport.Attributes.%Push({ "Key" : (tKey), "Value" : (tValue)})
		Set tKey = $Order(pInputStream.Attributes(tKey), 1, tValue)
	}

	// Attributes("Params") = HTTP form variables
	Set tJSONReport.AttributeParams = []
	//Set tKey = $Order(pInputStream.Attributes("Params", "", 1),1,tValue)
 	Set tKey = $Order(pInputStream.Attributes("Params", ""), 1, tValue)
 $$$LOGINFO("tKey = " _ tKey _ ", tValue = " _ tValue)
 	//Set tKey = $Order(pInputStream.Attributes("Params", "", 1),1,tValue)
	While (tKey '= "") {
 $$$LOGINFO("Subscript 1 = " _ $Get(pInputStream.Attributes("Params", tKey, 1)))
		Set tValue = $Get(pInputStream.Attributes("Params", tKey, 1))
		Do tJSONReport.Params.%Push({ "Key" : (tKey), "Value" : (tValue)})
		Set tKey = $Order(pInputStream.Attributes("Params", tKey),1,tValue)
 $$$LOGINFO("tKey = " _ tKey _ ", tValue = " _ tValue)
		//Set tKey = $Order(pInputStream.Attributes("Params", tKey, 1),1,tValue)
 	}
	Set tJSONReport.aboutAttributeParams = $ZConvert("pInputStream.Attribute(Params, <Param>, 1) for each  <Param>", "O", "JSON")

	Return tJSONReport
}

}
