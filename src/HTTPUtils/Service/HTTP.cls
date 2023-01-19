Class HTTPUtils.Service.HTTP Extends Ens.BusinessService
{

/// Parameter ADAPTER = "EnsLib.HTTP.InboundAdapter";
Parameter ADAPTER = "HTTPUtils.HTTP.InboundAdapter";

Method OnProcessInput(pInput As %Stream.Object, Output pOutput As %Stream.Object) As %Status
{
	#Dim tStatus As %Status = $$$OK

	#Dim tJSONResponse As %DynamicObject = ..InspectRequest(pInput)

	Set pOutput = ##class(%Library.GlobalCharacterStream).%New()
	Set tStatus = ##class(%JSON.Formatter).%New().FormatToStream(tJSONResponse, .pOutput)
	#Dim tDidExist As %Boolean = pOutput.DeleteAttribute("LineTerminator")
	$$$LOGINFO("Call of pOutput.DeleteAttribute(""LineTerminator"") returned " _ tDidExist)
	Do pOutput.SetAttribute("Content-Type", "application/json")

	Return tStatus
}

/// This method will be called by the adapter just before returning the response to the client
Method OnAdapterHTTPResponse(pStatus As %Status, ByRef pHTTPResponseStatus, ByRef pLen, ByRef pStreamOut As %Stream.Object, ByRef pHeader, ByRef pHeaderExtra)
{
	$$$LOGINFO("OnAdapterHTTPResponse: pStatus = " _ pStatus)
	$$$LOGINFO("OnAdapterHTTPResponse: pHTTPResponseStatus = " _ pHTTPResponseStatus)
	$$$LOGINFO("OnAdapterHTTPResponse: pLen = " _ pLen)
	$$$LOGINFO("OnAdapterHTTPResponse: pStreamOut = " _ pStreamOut)
	$$$LOGINFO("OnAdapterHTTPResponse: pHeader = " _ pHeader)
	$$$LOGINFO("OnAdapterHTTPResponse: pHeaderExtra = " _ pHeaderExtra)
}

/// This method will be called by the adapter in case OnProcessInput returns a status indicating error
Method OnErrorStream(pStatus As %Status, pService As Ens.BusinessService) As %Stream.Object
{
	$$$LOGINFO("OnErrorStream invoked")
	Return $$$NULLOREF
}

Method InspectRequest(pInput As %Stream.Object) As %DynamicObject
{
	#Dim tJSONReport As %DynamicObject = {}

	// What is this all about
	Set tJSONReport.about = "This report is about an HTTP request received by a business service " _ ..%ConfigName _ "." _
								" Please refer to the source code class HTTPUtils.Service.HTTP for the details."

	// pInput
	Set tJSONReport.aboutInput = "The parameter pInput (of method OnProcessInput) has this value"
	Set tJSONReport.Input = pInput

	// pInput.Size
	Set tJSONReport.aboutInputSize = "Value of pInput.Size"
	Set tJSONReport.InputSize = pInput.Size

	// URL = an Attribute
	Set tJSONReport.aboutURL = "pInput.Attributes(URL)"
	Set tJSONReport.URL = pInput.Attributes("URL")

	// Attributes = HTTP headers & more
	Set tJSONReport.aboutAttributes = "pInput.Attributes(<Key>) for each <Key>)"
	Set tJSONReport.Attributes = []
	#Dim tKey, tValue As %String = ""
	Set tKey = $Order(pInput.Attributes(""), 1, tValue)
	While (tKey '= "") {
		Do tJSONReport.Attributes.%Push({ "Key" : (tKey), "Value" : (tValue)})
		Set tKey = $Order(pInput.Attributes(tKey), 1, tValue)
	}

	// Attributes("Params") = HTTP form variables
	//Set tJSONReport.aboutAttributeParams = $ZConvert("pInput.Attribute(Params, <Param>, 1) for each  <Param>", "O", "JSON")
	Set tJSONReport.aboutAttributeParams = "pInput.Attribute(Params, <Param>, 1) for each  <Param>"
	Set tJSONReport.AttributeParams = []
	#Dim tParam As %String = $Order(pInput.Attributes("Params", ""), 1, tValue)
 	While (tParam '= "") {
		Set tValue = $Get(pInput.Attributes("Params", tParam, 1))
		Do tJSONReport.AttributeParams.%Push({ "Param" : (tParam), "Value" : (tValue)})

		Set tParam = $Order(pInput.Attributes("Params", tParam), 1 ,tValue)
 	}

	Return tJSONReport
}

}
