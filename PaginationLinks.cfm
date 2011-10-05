<cffunction name="paginationLinks" returntype="string" access="public" output="false" hint="Builds and returns a string containing links to pages based on a paginated query. Uses @linkTo internally to build the link, so you need to pass in a `route` name or a `controller`/`action`/`key` combination. All other @linkTo arguments can be supplied as well, in which case they are passed through directly to @linkTo. If you have paginated more than one query in the controller, you can use the `handle` argument to reference them. (Don't forget to pass in a `handle` to the @findAll function in your controller first.)">
	<cfargument name="totalRecords" type="numeric" required="true" hint="total numeric of records">
	<cfargument name="perPage" type="numeric" required="false" default="50" hint="number of records on each page">
	<cfargument name="windowSize" type="numeric" required="false" default="2" hint="The number of page links to show around the current page.">
	<cfargument name="alwaysShowAnchors" type="boolean" required="false" default="true" hint="Whether or not links to the first and last page should always be displayed.">
	<cfargument name="anchorDivider" type="string" required="false" default=" ... " hint="String to place next to the anchors on either side of the list.">
	<cfargument name="linkToCurrentPage" type="boolean" required="false" default="false" hint="Whether or not the current page should be linked to.">
	<cfargument name="prepend" type="string" required="false" default="" hint="String or HTML to be prepended before result.">
	<cfargument name="append" type="string" required="false" default="" hint="String or HTML to be appended after result.">
	<cfargument name="prependToPage" type="string" required="false" default="" hint="String or HTML to be prepended before each page number.">
	<cfargument name="prependOnFirst" type="boolean" required="false" default="true" hint="Whether or not to prepend the `prependToPage` string on the first page in the list.">
	<cfargument name="prependOnAnchor" type="boolean" required="false" default="true" hint="Whether or not to prepend the `prependToPage` string on the anchors.">
	<cfargument name="appendToPage" type="string" required="false" default="" hint="String or HTML to be appended after each page number.">
	<cfargument name="appendOnLast" type="boolean" required="false" default="true" hint="Whether or not to append the `appendToPage` string on the last page in the list.">
	<cfargument name="appendOnAnchor" type="boolean" required="false" default="true" hint="Whether or not to append the `appendToPage` string on the anchors.">
	<cfargument name="classForCurrent" type="string" required="false" default="pagination-current-page" hint="Class name for the current page number (if `linkToCurrentPage` is `true`, the class name will go on the `a` element. If not, a `span` element will be used).">
	<cfargument name="classForDivider" type="string" required="false" default="pagination-divider" hint="Class name for the anchorDivider">
	<cfargument name="classForContainer" type="string" required="false" default="pagination-links" hint="Class name for the container.">
	<cfargument name="param" type="string" required="false" default="page" hint="The name of the param that holds the current page number.">
	<cfargument name="showSinglePage" type="boolean" required="false" default="false" hint="Will show a single page when set to `true`. (The default behavior is to return an empty string when there is only one page in the pagination).">
	<cfargument name="pageNumberAsParam" type="boolean" required="false" default="true" hint="Decides whether to link the page number as a param or as part of a route. (The default behavior is `true`).">
	<cfargument name="anchor" type="string" required="false" default="#cgi.SCRIPT_NAME#" hint="the page to link to">
	<cfset var loc = {}>
	<cfset loc.returnValue = "">
		
	<!--- current page that we are on --->
	<cfset loc.currentPage = 1>
	
	<!--- number of pages total --->
	<cfset loc.totalPages = ceiling(arguments.totalRecords / arguments.perPage)>
	
	<cfif not arguments.showSinglePage and loc.totalPages eq 1>
		<cfreturn loc.returnValue>
	</cfif>
	
	<!--- need to remove the params from the query_string --->
	<cfset loc.queryString = cgi.QUERY_STRING>
	<cfset loc.queryString = ListToArray(loc.queryString, "&")>
	<cfset loc.iEnd = ArrayLen(loc.queryString)>
	<cfloop from="#loc.iEnd#" to="1" step="-1" index="loc.i">
		<cfif ListFirst(loc.queryString[loc.i], "=") eq arguments.param>
			<cfset ArrayDeleteAt(loc.queryString, loc.i)>
		</cfif>
	</cfloop>

	<cfset loc.queryString = ArrayToList(loc.queryString, "&")>
	
	<!--- divider --->
	<cfset arguments.anchorDivider = '<span class="#arguments.classForDivider#">#arguments.anchorDivider#</span>'>
	
	<cfset loc.scope = duplicate(form)>
	<cfset StructAppend(loc.scope, url, true)>
	
	<cfif StructKeyExists(loc.scope, arguments.param)>
		<cfset loc.currentPage = loc.scope[arguments.param]>
		<cfif loc.currentPage lt 1>
			<cfset loc.currentPage = 1>
		<cfelseif loc.currentpage gt loc.totalPages>
			<cfset loc.currentPage = loc.totalPages>
		</cfif>
	</cfif>	

	<cfset loc.holder = []>
	
	<!--- determine the radius --->
	<cfset loc.radius = fix(arguments.windowSize / 2)>
	<cfset loc.startPos = loc.currentPage - loc.radius>
	<cfset loc.endPos = loc.currentPage + loc.radius>

	<cfif loc.startPos lte 1>
		<cfset loc.overage = 1 - loc.startPos>
		<cfset loc.startPos = loc.startPos + loc.overage>
		<cfset loc.endPos = loc.endPos + (loc.overage - 1)>
	</cfif>

	<cfif loc.endPos gt loc.totalPages>
		<cfset loc.overage = loc.endPos - loc.totalPages>
		<cfset loc.startPos = loc.startPos - (loc.overage - 1)>
		<cfset loc.endPos = loc.endPos - loc.overage>
	</cfif>

	<cfif loc.startPos lte 1>
		<cfset loc.startPos = 1>
	</cfif>

	<cfif loc.endPos gt loc.totalPages>
		<cfset loc.endPos = loc.totalPages>
	</cfif>

	<cfif loc.startPos eq loc.endPos>
		<cfreturn loc.returnValue>
	</cfif>

	<cfloop from="#loc.startPos#" to="#loc.endPos#" index="loc.i">
		<cfset arguments.windowSize-->
		<cfif arguments.windowSize lt 0>
			<cfbreak>
		</cfif>
		<cfset ArrayAppend(loc.holder, loc.i)>
	</cfloop>

	<cfif arguments.alwaysShowAnchors>
		<cfif loc.holder[1] neq 1>
			<cfset ArrayDeleteAt(loc.holder, 1)>
			<cfset ArrayPrepend(loc.holder, arguments.anchorDivider)>
			<cfset ArrayPrepend(loc.holder, "1")>
		</cfif>
		<cfif loc.holder[ArrayLen(loc.holder)] neq loc.totalPages>
			<cfset ArrayDeleteAt(loc.holder, ArrayLen(loc.holder))>
			<cfset ArrayAppend(loc.holder, arguments.anchorDivider)>
			<cfset ArrayAppend(loc.holder, loc.totalPages)>
		</cfif>
	</cfif>
	
	<cfset loc.counter = ArrayLen(loc.holder)>
	<cfloop from="1" to="#loc.counter#" index="loc.i">
		<cfif IsNumeric(loc.holder[loc.i])>
			<cfset loc.str = ["<span"]>
			<cfif loc.currentPage eq loc.holder[loc.i] AND Len(arguments.classForCurrent)>
				<cfset arrayAppend(loc.str, ' class="#arguments.classForCurrent#"')>
			</cfif>
			<cfset arrayAppend(loc.str, '>#loc.holder[loc.i]#</span>')>
			<cfif loc.currentPage neq loc.holder[loc.i] OR arguments.linkToCurrentPage>
				<cfset arrayPrepend(loc.str, '<a href="#arguments.anchor#?#arguments.param#=#loc.holder[loc.i]#&#loc.queryString#">')>
				<cfset arrayAppend(loc.str, '</a>')>
			</cfif>
			<cfif Len(arguments.prependToPage)>
				<cfset arrayPrepend(loc.str, arguments.prependToPage)>
			</cfif>
			<cfif (Len(arguments.appendToPage))>
				<cfset arrayAppend(loc.str, arguments.appendToPage)>
			</cfif>
			<cfset loc.holder[loc.i] = ArrayToList(loc.str, "")>
		</cfif>
	</cfloop>
	
 	<cfset arrayPrepend(loc.holder, '<span')>
	<cfif len(arguments.classForContainer)>
		<cfset loc.holder[1] &= ' class="#arguments.classForContainer#"'>
	</cfif>
	<cfset loc.holder[1] &= '>'>
	<cfset arrayAppend(loc.holder, '</span>')>
	<cfset loc.returnValue = ArrayToList(loc.holder, "")>
	<cfreturn loc.returnValue>
</cffunction>