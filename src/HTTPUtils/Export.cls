/// Exports specified items to files.
/// 
/// <p>Call (class)method <METHOD>Export</METHOD> to do the export.
/// 
/// <p>To specify the items to export, edit parameters
/// <PARAMETER>PACKAGES</PARAMETER>, <PARAMETER>EXCLUDECLASSES</PARAMETER>,
/// <PARAMETER>RULES</PARAMETER>, <PARAMETER>HL7SCHEMAS</PARAMETER>,
/// <PARAMETER>GLOBALS</PARAMETER> and <PARAMETER>CSPFILES</PARAMETER>.
/// 
/// To specify file name(s) to export to and the folder to create the file(s),
/// edit parameters
/// <PARAMETER>FILENAME</PARAMETER>, <PARAMETER>WINDOWSFOLDER</PARAMETER> and
/// <PARAMETER>UNIXFOLDER</PARAMETER>.
/// You also have the option to override method <METHOD>GetFileName</METHOD>.
/// 
/// Version History:
/// 		2018.08.21	Anssi Kauppi
/// 			Some minor code changes
/// 		2017.11.16	Anssi Kauppi
/// 			Parameter DEEPSEEFOLDERS and exporting of dashboards and pivot tables
/// 		2015.07.05	Anssi Kauppi
/// 			Parameter INCLUDES and exporting of include files
/// 
Class HTTPUtils.Export Extends %RegisteredObject
{

/*
Do ##class(HTTPUtils.Export).Export()
 *
 */

/*
https://opensource.org/licenses/MIT

Copyright 2018 InterSystems Corporation in Finland / AnssiK

Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
and associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or 
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
/// Base name of the file name to use.
/// By default, this base name is appended with a string
/// describing the content of the file (classes, CSP pages, business rules etc.)
/// and extension ".xml"
Parameter FILENAME As %String = "HTTPUtils_2023_01_20";

/// Folder to create the export files in, when running this program in Windows.
/// Specify an absolute path and end it with "\"
/// Parameter WINDOWSFOLDER As %String = "C:\Temp\CacheExports\";
Parameter WINDOWSFOLDER As %String = "Z:\akauppi On My Mac\CacheExports";

/// Parameter WINDOWSFOLDER As %String = "C:\Temp\";
/// Folder to create the export files in, when running this program in Unix/Linux.
/// Specify an absolute path and end it with "/"
/// Parameter UNIXFOLDER As %String = "/Users/anssikauppi/CacheExports/";
Parameter UNIXFOLDER As %String = "/durable/export";

/// Comma separated list of beginnings of package names.
/// All classes that start with any of these strings will be exported.
Parameter PACKAGES As %String = "HTTPUtils.";

/// Comma separated list of class names that will be excluded from export.
Parameter EXCLUDECLASSES As %String;

/// Comma separated list of include file names to be exported with the classes
Parameter INCLUDES As %String;

/// Comma separated list of rules to be exported e.g. "KantaCP.RuleSet.TargetConfigName.rul"
Parameter RULES As %String;

/// Comma separated list of HL7 schemas to be exported e.g. "2.3.1.FI.hl7"
Parameter HL7SCHEMAS As %String;

/// Comma separated list of beginnings of global names.
/// All globals that start with any of these strings will be exported.
/// Parameter GLOBALS As %String = "FiEns.Stat.";
Parameter GLOBALS As %String;

/// Comma separated list of beginnings of CSP file names.
/// All files that start with any of these begining-of-a-file-names under the CSP application root folder will be exported.
Parameter CSPFILES As %String;

/// Comma separated list of beginnings of DeepSee folder names.
/// All dashboards and pivot tables that start with any of these strings will be exported.
/// Parameter DEEPSEEFOLDERS As %String = "MySec";
Parameter DEEPSEEFOLDERS As %String;

/// Name of the container class that contains the exported DeepSee items
/// Prior 2016.2 version of Caché: 
/// Parameter DEEPSEECONTAINERCLASSNAME As %String = "MyEq.Analytics.Container";
Parameter DEEPSEECONTAINERCLASSNAME As %String;

/// Export items to files as specified by the values of parameters.
ClassMethod Export(pVerbose As %Boolean = 1) As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tExport As KantaCP.Export = ..%New()

	Set tStatus = tExport.ExportClassesAndIncludes(pVerbose)
	If ($$$ISERR(tStatus)) {
		Do:pVerbose ##class(%SYSTEM.OBJ).DisplayError(tStatus)
		Quit tStatus
	}

	Set tStatus = tExport.ExportDeepSeeFolders(pVerbose)
	If ($$$ISERR(tStatus)) {
		Do:pVerbose ##class(%SYSTEM.OBJ).DisplayError(tStatus)
		Quit tStatus
	}

	Set tStatus = tExport.ExportRules(pVerbose)
	If ($$$ISERR(tStatus)) {
		Do:pVerbose ##class(%SYSTEM.OBJ).DisplayError(tStatus)
		Quit tStatus
	}

	Set tStatus = tExport.ExportHL7Schemas(pVerbose)
	If ($$$ISERR(tStatus)) {
		Do:pVerbose ##class(%SYSTEM.OBJ).DisplayError(tStatus)
		Quit tStatus
	}

	Set tStatus = tExport.ExportCSP(pVerbose)
	If ($$$ISERR(tStatus)) {
		Do:pVerbose ##class(%SYSTEM.OBJ).DisplayError(tStatus)
		Quit tStatus
	}

	Set tStatus = tExport.ExportGlobals(pVerbose)
	If ($$$ISERR(tStatus)) {
		Do:pVerbose ##class(%SYSTEM.OBJ).DisplayError(tStatus)
		Quit tStatus
	}

	Quit tStatus
}

Method ExportDeepSeeFolders(pVerbose As %Boolean = 1) As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim iPattern As %Integer
	#Dim tPattern As %String
	#Dim iItem As %Integer
	#Dim tItemsToExport As %String

	If (..#DEEPSEEFOLDERS = "") Quit tStatus

	#Dim tListOfDashboards As %ListOfObjects = ..GetDashboardDefinitions()
	#Dim tListOfPivots As %ListOfObjects = ..GetPivotDefinitions()
	For iPattern = 1:1:$Length(..#DEEPSEEFOLDERS, ",") {
		Set tPattern = $Piece(..#DEEPSEEFOLDERS, ",", iPattern)
		For iItem = 1:1:tListOfDashboards.Count() {
			If ($Extract(tListOfDashboards.GetAt(iItem).folder.fullName, 1, $Length(tPattern)) = tPattern) {
				Set tItemsToExport(tListOfDashboards.GetAt(iItem).fullName) = "" 
				//Write "  Match: " _ tListOfDashboards.GetAt(iItem).fullName _ "     of " _ tListOfDashboards.GetAt(iItem).folder.fullName, !
			}
		}
		For iItem = 1:1:tListOfPivots.Count() {
			If ($Extract(tListOfPivots.GetAt(iItem).folder.fullName, 1, $Length(tPattern)) = tPattern) {
				Set tItemsToExport(tListOfPivots.GetAt(iItem).fullName) = "" 
				//Write "  Match: " _ tListOfPivots.GetAt(iItem).fullName _ "     of " _ tListOfPivots.GetAt(iItem).folder.fullName, !
			}
		}
	}

	#Dim tFileName As %String = ..GetFileName("_DeepSee")
	Set tStatus = ##class(%DeepSee.UserLibrary.Utils).%ExportContainer(.tItemsToExport, tFileName, ..#DEEPSEECONTAINERCLASSNAME)
	Write:$$$ISOK(tStatus) "Export saved in: " _ tFileName, !

	Quit tStatus
}

Method ExportClassesAndIncludes(pVerbose As %Boolean = 1) As %Status
{
	#Dim tStatus As %Status;
	#Dim tFiles, tFile As %String;
	#Dim tPackage As %String;
	#Dim tFileName As %String;
	#Dim i As %Integer;

	Set tFiles = ""
	Set tStatus = $$$OK

	If (..#PACKAGES '= "") {
		Set tRS = ##class(%ResultSet).%New("%Dictionary.ClassDefinition:Summary")
		Do tRS.Execute()
		While (tRS.Next()) {
			Set tFile = ""

			If ($FIND(tRS.Data("Name"), ".Context") ||
				$FIND(tRS.Data("Name"), ".Thread1")) {
					Continue
			}
			For i=1:1:$Length(..#PACKAGES, ",") {
				Set tPackage = $Piece(..#PACKAGES, ",", i)
				If ($Extract(tRS.Data("Name"), 1, $Length(tPackage)) = tPackage) {
					Set tFile = "," _ tRS.Data("Name") _ ".cls"
					Quit
				}
			}
			If ((tFile '= "") && (..#EXCLUDECLASSES '= "")) {
				For i=1:1:$Length(..#EXCLUDECLASSES, ",") {
					Set tPackage = $Piece(..#EXCLUDECLASSES, ",", i)
					If ($FIND(tRS.Data("Name"), tPackage)) {
						Set tFile = ""
					}
				}
			}
			Set tFiles = tFiles _ tFile
		}
	}
	If (..#INCLUDES '= "") {
		For i=1:1:$Length(..#INCLUDES, ",") {
			Set tFile = $Piece(..#INCLUDES, ",", i)
			If ($Length(tFile, ".") = 1) {
				Set tFile = tFile _ ".inc"
			}
			Set tFiles = tFiles _ "," _ tFile
		}
	}

	If ($Extract(tFiles, 1, 1) = ",") {
		Set tFiles = $Extract(tFiles, 2, 32000)
	}

	Quit ..ExportToFile(tFiles, ..GetFileName("_Classes"))
}

Method ExportRules(pVerbose As %Boolean = 1) As %Status
{
	If (..#RULES '= "") {
		Quit ..ExportToFile(..#RULES, ..GetFileName("_Rules"))
	}
	Quit $$$OK
}

Method ExportHL7Schemas(pVerbose As %Boolean = 1) As %Status
{
	If (..#HL7SCHEMAS '= "") {
		Quit ..ExportToFile(..#HL7SCHEMAS, ..GetFileName("_HL7"))
	}
	Quit $$$OK
}

Method ExportCSP(pVerbose As %Boolean = 1) As %Status
{
	#Dim tStatus As %Status = $$$OK
 	#Dim tFiles As %String = ""
	#Dim tSeparator As %String = "/"
	If $$$isWINDOWS {
	 	Set tSeparator = "\"
	}

	Set tFolder = ##class(%SYSTEM.Util).InstallDirectory()
	Set tLength = $Length(tFolder, tSeparator)
	Set tFolder = tFolder _ $Extract(##class(%SYSTEM.CSP).GetDefaultApp($Namespace), 2, 32000)
	// If windows
	Set tFolder = $Replace(tFolder, "/", tSeparator)

	If (..#CSPFILES '= "") {
		Set tResultSet = ##class(%ResultSet).%New("%File:FileSet")
		Do tResultSet.Execute(tFolder, "*.csp")
		While (tResultSet.Next()) {
	 		Set tFile = tResultSet.Data("Name")
			Set tFileName = $Piece(tFile, tSeparator, $Length(tResultSet.Data("Name"), tSeparator))
			For i=1:1:$Length(..#CSPFILES, ",") {
				Set tBeginning = $Piece(..#CSPFILES, ",", i)
				If ($Extract(tFileName, 1, $Length(tBeginning)) = tBeginning) {
					Set tFile = $Replace($Piece(tFile, tSeparator, tLength, 100), "\", "/")
					Set tFiles = tFiles _ "," _ tFile
					Quit
				}
			}
		}
	}

	If (tFiles '= "") {
		Quit ..ExportToFile($EXTRACT(tFiles, 2, 32000), ..GetFileName("_CSP"))
	}
	Quit $$$OK
}

Method ExportGlobals(pVerbose As %Boolean = 1) As %Status
{
	#Dim tStatus As %Status = $$$OK
 	#Dim tFiles As %String = ""

	If (..#GLOBALS '= "") {
		Set tRS = ##class(%ResultSet).%New("%SYS.GlobalQuery:DirectoryList")
		Set tDatabase = $Piece(##class(%SYS.Namespace).GetGlobalDest(), "^", 2)
		Do tRS.Execute(tDatabase)
		While (tRS.Next()) {
			For i=1:1:$Length(..#GLOBALS, ",") {
				Set tPackage = $Piece(..#GLOBALS, ",", i)
				If ($Extract(tRS.Data("Name"), 1, $Length(tPackage)) = tPackage) {
					Set tFiles = tFiles _ "," _ tRS.Data("Name") _ ".gbl"
					Quit
				}
			}
		}
	}

	If (tFiles '= "") {
		Quit ..ExportToFile($EXTRACT(tFiles, 2, 32000), ..GetFileName("_Globals"))
	}
	Quit $$$OK
}

/*	********************************************************************************
	**	Misc
	******************************************************************************** */
/// Assembles and returns a full path name for a file to export classes/CSP pages/business rules/Hl7 schemas to.
/// 
/// <p>The value of argument pExtension is used in the filename just before ".xml".
Method GetFileName(pExtension As %String = "") As %String
{
	#Dim tFolder As %String
	If $$$isWINDOWS {
		Set tFolder = ..#WINDOWSFOLDER
		If $extract(tFolder,$length(tFolder))'="\" Set tFolder=tFolder_"\"
	} ElseIf $$$isUNIX {
		Set tFolder = ..#UNIXFOLDER
		If $extract(tFolder,$length(tFolder))'="/" Set tFolder=tFolder_"/"
	}

	#Dim tFileName As %String = tFolder _ ..#FILENAME _ pExtension _ ".xml"
	Quit tFileName
}

/// Esports the comma separated list of items (argument pListOfItems) to file (pFileName).
Method ExportToFile(pListOfItems As %String, pFileName As %String)
{
	#Dim tStatus As %Status = ##class(%SYSTEM.OBJ).Export(pListOfItems, pFileName)
	Write:$$$ISOK(tStatus) "Export saved in: " _ pFileName, !
	Quit tStatus
}

/// Do ##class(HS.Local.HSFI.Util.DeepSee).GetDashboardDefinitions()
ClassMethod GetDashboardDefinitions(pIncludeTrash As %Boolean = 0) As %ListOfObjects
{
	#Dim tListOfDashboards As %ListOfObjects = ##class(%ListOfObjects).%New()

	#Dim tException As %Exception.AbstractException
	#Dim tStatus As %Status


	Try {
		#Dim tDashboardId as %Integer
		#Dim tDashboard As %DeepSee.Dashboard.Definition

		&sql(DECLARE DBD1 CURSOR FOR SELECT ID INTO :tDashboardId
				FROM %DeepSee_Dashboard.Definition
				Order By ID ASC)
		&sql(OPEN DBD1)

		For {
			&sql(FETCH DBD1)
			Quit:SQLCODE'=0

			Set tDashboard = ##Class(%DeepSee.Dashboard.Definition).%OpenId(tDashboardId,,.tStatus)
			If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)

			If (pIncludeTrash || ($Find(tDashboard.folder.fullName, "$TRASH") < 4)) {
				Do tListOfDashboards.Insert(tDashboard)
			}
		}
		&sql(CLOSE DBD1)
	}
	Catch tException {
		&sql(CLOSE DBD1)
        Throw tException
	}
	Quit tListOfDashboards
}

/// Do ##class(HS.Local.HSFI.Util.DeepSee).GetPivotDefinitions()
ClassMethod GetPivotDefinitions(pIncludeLocal As %Boolean = 0) As %ListOfObjects
{
	#Dim tListOfPivots As %ListOfObjects = ##class(%ListOfObjects).%New()

	#Dim tException As %Exception.AbstractException
	#Dim tStatus As %Status

	Try {
		#Dim tPivotId as %Integer
		#Dim tPivot As %DeepSee.Dashboard.Pivot

		&sql(DECLARE DBP1 CURSOR FOR SELECT ID INTO :tPivotId
				FROM %DeepSee_Dashboard.Pivot
				Order By ID ASC)
		&sql(OPEN DBP1)

		For {
			&sql(FETCH DBP1)
			Quit:SQLCODE'=0

			Set tPivot = ##Class(%DeepSee.Dashboard.Pivot).%OpenId(tPivotId,,.tStatus)
			If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)

			If (pIncludeLocal || ($Find(tPivot.folder.fullName, "$LOCAL") < 4)) {
				Do tListOfPivots.Insert(tPivot)
			}
		}
		&sql(CLOSE DBP1)
	}
	Catch tException {
		&sql(CLOSE DBP1)
        Throw tException
	}
	Quit tListOfPivots
}

}
