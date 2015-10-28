	<cffunction name="RGBToHex" hint="I convert the RGB values passed to hex" output="false" returntype="string" access="public">
		<cfargument name="intRed">
		<cfargument name="intGreen">
		<cfargument name="intBlue">
		<cfset strRed = FormatBaseN( intRed, 16 ) />
		<cfset strGreen = FormatBaseN( intGreen, 16 ) />
		<cfset strBlue = FormatBaseN( intBlue, 16 ) />
		 
		<!--- Now, make sure they have two digits. --->
		<cfif (Len( strRed ) EQ 1)>
			<cfset strRed = ("0" & strRed) />
		</cfif>
		<cfif (Len( strGreen ) EQ 1)>
			<cfset strGreen = ("0" & strGreen) />
		</cfif>
		<cfif (Len( strBlue ) EQ 1)>
			<cfset strBlue = ("0" & strBlue) />
		</cfif>
		 
		<!--- Combine the RGB HEX values to get the color HEX. --->
		<cfset strHEX = UCase(
			strRed &
			strGreen &
			strBlue
			) />
		<!--- Return HEX value. --->
		<cfreturn strHEX>
	</cffunction>
	<cffunction name="textColorForBackGround" hint="I return the correct value to use for text color for the background HEX color passed" access="remote">
		<cfargument name="hexColor">
		<cfset var threshHold = 105>
		<cfset var rgb=HexToRGB(hexColor)>
		<cfset var bgDelta=int((rgb[1]*.299) + (rgb[2]*.587) + (rgb[3]*.114))>
		<cfif 255-bgDelta lt threshHold>
			<cfreturn "##000000">
		<cfelse>
			<cfreturn "##FFFFFF">	
		</cfif>
	</cffunction>
	<cffunction name="HextoRGB">
		<cfargument name="strHex">
		<cfset var result="">
		<cfset var strRed = ""/>
		<cfset var strGreen = ""/>
		<cfset var strBlue = ""/>
		<cfif asc(left(strHex,1)) eq 35>
			<cfset strHex=mid(strHex,2,1000)>		
		</cfif>
		<cfset strRed = Mid( strHEX, 1, 2 ) />
		<cfset strGreen = Mid( strHEX, 3, 2 ) />
		<cfset strBlue = Mid( strHEX, 5, 2 ) />
		<cfset strRed = InputBaseN( strRed, 16 ) />
		<cfset strGreen = InputBaseN( strGreen, 16 ) />
		<cfset strBlue = InputBaseN( strBlue, 16 ) />
		<cfset result=[strRed,strGreen,strBlue]>
		<cfreturn result>
	</cffunction>