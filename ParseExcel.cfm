<!---
 Converts an excel file to a structure of arrays
 Modded by Raymond Camden to fix incorrect col count
 added minor changes from Tony

 @param excelFile 	 Excel file to parse. (Required)
 @return Returns a struct of arrays.
 @author anthony petruzzi (tpetruzzi@gmail.com)
 @version 1, Sep 13, 2011
 http://gist.github.com/138954

 handle blank and duplicate headers
--->
<cffunction name="parseExcel" access="public" returntype="any" output="false">
	<cfargument name="excelFile" type="string" required="true">
	<cfargument name="returnType" type="string" required="false" default="">
	<cfset var loc = {}>
	<!--- structure to hold data retrieved --->
	<cfset loc.ret = {}>
	<!--- did we get headers yet --->
	<cfset loc.firstRow = true>
	<!--- create io stream for the excel file --->
	<cfset loc.io = CreateObject("java","java.io.FileInputStream").init(excelFile)>
	<!--- read the excel file --->
	<cfset loc.workbook = CreateObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init(loc.io)>
	<!--- get the first sheet of the workbook. zero indexed --->
	<cfset loc.workSheet = loc.workBook.getSheetAt(javacast("int", 0))>
	<!--- get the number of rows the sheet has. zero indexed --->
	<cfset loc.rows = loc.workSheet.getLastRowNum()>
	<!--- this is used for header that are blank --->
	<cfset loc.headerCounter = 1>

	<cfif !loc.rows>
		<cfreturn loc.ret>
	</cfif>

	<!--- array to store data --->
	<cfset loc.data = []>
	<!--- loop through the rows and get the values. --->
	<cfloop from="0" to="#loc.rows#" index="loc.atrow">
		<!--- get the row --->
		<cfset loc.row = loc.workSheet.getRow(javacast("int", loc.atrow))>
		<!--- parsing bombs on blank rows --->
		<cfif StructKeyExists(loc, "row")>
			<!--- first check to see if first cell 1 is blank, if not process, if so move to next --->
			<cfset loc.checkCell = "">
			<cfset loc.rowCheck = loc.row.getCell(0)>
			<cfif structkeyexists(loc, "rowCheck")>
				<cfif loc.rowCheck.getCellType() eq 0>
					<cfset loc.checkCell = loc.rowCheck.getNumericCellValue()>
				<cfelse>
					<cfset loc.checkCell = loc.rowCheck.getStringCellValue()>
				</cfif>
			<cfelse>
				<!--- since it is blank, we will use a CHR(7) to indicate null --->
				<cfset loc.checkCell = chr(7)>
			</cfif>
			<!--- if the first cell isn't blank, proceed --->
			<!--- <cfif len(trim(loc.checkCell))> --->
				<!--- the first row will tell us the number of columns to process --->
				<cfif loc.firstRow>
					<cfset loc.cols = loc.row.getLastCellNum() - 1>
					<cfset loc.firstrow = false>
				</cfif>
				<cfset loc.values = []>
				<!--- loop through the columns (cells) of the row and get the values --->
				<cfloop from="0" to="#loc.cols#" index="loc.col">
					<cfset loc.value = "">
					<cfset loc.cellType = loc.row.getCell(javacast("int", loc.col))>
					<cfif structkeyexists(loc, "celltype")>
						<cfif loc.cellType.getCellType() eq 0>
							<cfset loc.value = loc.cellType.getNumericCellValue()>
						<cfelse>
							<cfset loc.value = loc.cellType.getStringCellValue()>
						</cfif>
					</cfif>
					<cfset arrayappend(loc.values, loc.value)>
				</cfloop>

				<!--- store the data --->
				<cfset arrayappend(loc.data, loc.values)>
			<!--- </cfif> --->
		</cfif>
	</cfloop>

	<cfif !arraylen(loc.data)>
		<cfreturn loc.ret>
	</cfif>

	<!--- create a struct of arrays to return --->
	<cfset loc.numDown = arraylen(loc.data)>
	<cfset loc.numAcross = ++loc.cols>
	<cfloop from="1" to="#loc.numAcross#" index="loc.across">
		<cfloop from="1" to="#loc.numDown#" index="loc.down">
		<!--- header --->
		<cfif loc.down eq 1>
			<cfset loc.key = loc.data[loc.down][loc.across]>
			<!---
			header can only have alphanumeric values.
			trim it
			make sure that the header is unique
			replace spaces with underscores
			upper case them so they look pretty ;)
			--->
			<cfset loc.key = ReReplaceNoCase(loc.key, "[^A-Za-z0-9 ]", "", "ALL")>
			<cfset loc.key = trim(loc.key)>
			<cfset loc.key = Replace(loc.key, " ", "_", "ALL")>
			<cfif !len(loc.key)>
				<cfset loc.key = "BLANK_HEADER_#loc.headerCounter#">
				<cfset loc.headerCounter++>
			</cfif>
			<cfif ListFindNoCase(StructKeyList(loc.ret), loc.key)>
				<cfset loc.key = "#loc.key#_#loc.headerCounter#">
				<cfset loc.headerCounter++>
			</cfif>
			<cfset loc.key = ucase(loc.key)>
			
			<cfset loc.ret[loc.key] = []>
		<cfelse>
			<cfset arrayappend(loc.ret[loc.key], loc.data[loc.down][loc.across])>
		</cfif>
		</cfloop>
	</cfloop>
	
	<!--- remove the rows that don't have anything in them --->
	<cfset loc.numCols = ArrayLen(loc.ret[ListFirst(StructKeyList(loc.ret))])>
	<cfloop from="#loc.numCols#" to="1" index="loc.i" step="-1">
		<cfset loc.blankRow = true>
		<cfloop collection="#loc.ret#" item="loc.a">
			<cfif len(trim(loc.ret[loc.a][loc.i]))>
				<cfset loc.blankRow = false>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfif loc.blankRow>
			<cfloop collection="#loc.ret#" item="loc.a">
				<cfset ArrayDeleteAt(loc.ret[loc.a], loc.i)>
			</cfloop>
		</cfif>
	</cfloop>
	
	<!--- convert to query if desired --->
	<cfif arguments.returnType eq "query">
		<cfset loc.q = QueryNew("")>
		<cfloop collection="#loc.ret#" item="loc.i">
			<cfset QueryAddColumn(loc.q, loc.i, "varchar", loc.ret[loc.i])>
		</cfloop>
		<cfset loc.ret = loc.q>
	</cfif>

	<cfreturn loc.ret>
</cffunction>