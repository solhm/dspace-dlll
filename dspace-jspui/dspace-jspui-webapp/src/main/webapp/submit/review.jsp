<%--
  - review.jsp
  -
  - Version: $Revision: 2218 $
  -
  - Date: $Date: 2007-09-28 08:17:04 -0500 (Fri, 28 Sep 2007) $
  -
  - Copyright (c) 2002, Hewlett-Packard Company and Massachusetts
  - Institute of Technology.  All rights reserved.
  -
  - Redistribution and use in source and binary forms, with or without
  - modification, are permitted provided that the following conditions are
  - met:
  -
  - - Redistributions of source code must retain the above copyright
  - notice, this list of conditions and the following disclaimer.
  -
  - - Redistributions in binary form must reproduce the above copyright
  - notice, this list of conditions and the following disclaimer in the
  - documentation and/or other materials provided with the distribution.
  -
  - - Neither the name of the Hewlett-Packard Company nor the name of the
  - Massachusetts Institute of Technology nor the names of their
  - contributors may be used to endorse or promote products derived from
  - this software without specific prior written permission.
  -
  - THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  - ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  - LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  - A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  - HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  - INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  - BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
  - OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  - ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  - TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
  - USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  - DAMAGE.
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.io.IOException" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="javax.servlet.jsp.PageContext" %>

<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>

<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>
<%@ page import="org.dspace.app.util.DCInputSet" %>
<%@ page import="org.dspace.app.util.DCInput" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Bitstream" %>
<%@ page import="org.dspace.content.BitstreamFormat" %>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="org.dspace.content.DCLanguage" %>
<%@ page import="org.dspace.content.DCValue" %>
<%@ page import="org.dspace.content.InProgressSubmission" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.content.Collection"%>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.app.webui.util.SubmissionUtil" %>
	
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    request.setAttribute("LanguageSwitch", "hide");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);    

	//get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);
    
	//get list of review JSPs from VerifyServlet
	HashMap reviewJSPs = (HashMap) request.getAttribute("submission.review");

	//get an iterator to loop through the review JSPs to load
	Iterator reviewIterator = reviewJSPs.keySet().iterator();
	
	//get step heading
	ArrayList<String> headings = new ArrayList<String>();	
	
	//get progress bar info, used to build progress bar
	HashMap progressBarInfo = (HashMap) subInfo.getProgressBarInfo();	
	String collectionHandle = subInfo.getSubmissionItem().getCollection().getHandle();
	String pageLabels[] = SubmissionUtil.getPageLabels(pageContext, collectionHandle);
	
	boolean hideSubmissionOriginal = ConfigurationManager.getBooleanProperty("submit-progress-bar.hide-orginal", true);
	
	if((progressBarInfo!=null) && (progressBarInfo.keySet()!=null))
    {
	   //get iterator
	   Set keys = progressBarInfo.keySet();
	   Iterator barIterator = keys.iterator();

	   //loop through all steps & print out info     
       while(barIterator.hasNext())
        {
		  //this is a string of the form: stepNum.pageNum
	      String stepAndPage = (String) barIterator.next();
		
		  try
		  {
		  	int stepNum = Integer.parseInt(stepAndPage.substring(0, stepAndPage.indexOf(".")));
		  	boolean isSkip = subInfo.getSubmissionConfig().getStep(stepNum).isSkip();
		  	
		  	if (isSkip)
		  		continue;
		  }
		  catch (Exception e) {}
		
		  //get heading from hashmap
		  String heading = (String) progressBarInfo.get(stepAndPage);
		  
		   //split into stepNum and pageNum
		  String[] fields = stepAndPage.split("\\.");  //split on period
          int stepNum = Integer.parseInt(fields[0]);
		  int pageNum = Integer.parseInt(fields[1]);
		  
		  String hideClass = "";
		  
		  //if the heading contains a period (.), then assume
          //it is referencing a key in Messages.properties
          if(heading.indexOf(".") >= 0)
          {
		  	 if(heading.equals("submit.progressbar.describe") == true)
			 {
			 	if ( pageLabels[pageNum-1].equals("") == false )
				{
					//這邊會從input-forms.xml去讀每一頁label的資料
			 		heading = pageLabels[pageNum-1];
				}
				else
				{
					heading = LocaleSupport.getLocalizedMessage(pageContext, "jsp." + heading);
				}
			 }
			 else
			 {
			 	if (heading.equals("submit.progressbar.initial-questions") == true || heading.equals("submit.progressbar.upload") == true)
				 {
				 	if (hideSubmissionOriginal == true)
				 		hideClass = "classHide";
			  	 }
			  	 
			  	if (hideClass.equals("classHide") == false)
             		heading = LocaleSupport.getLocalizedMessage(pageContext, "jsp." + heading);
             	else
             		heading = "";
          	 }
             //prepend the existing key with "jsp." since we are using JSP-UI
             //heading = LocaleSupport.getLocalizedMessage(pageContext, "jsp." + heading + stepAndPage);
             
             headings.add(heading);
          }
	   }	//while(barIterator.hasNext())
	}	//if((progressBarInfo!=null) && (progressBarInfo.keySet()!=null))
		 
%>
          
<dspace:layout locbar="off" navbar="off" titlekey="jsp.submit.review.title" nocache="true">

    <form action="<%= request.getContextPath() %>/submit" method="post" onkeydown="return disableEnterKey(event);">
   
        <jsp:include page="/submit/progressbar.jsp" />

        <h1><fmt:message key="jsp.submit.review.heading"/></h1>

        <p><fmt:message key="jsp.submit.review.info1"/></p>

        <div><fmt:message key="jsp.submit.review.info2"/>
        &nbsp;&nbsp;<dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.index") + "#verify"%>"><fmt:message key="jsp.morehelp"/></dspace:popup></div>

        <p><fmt:message key="jsp.submit.review.info3"/></p>

        <table align="center" class="miscTable" width="80%">
<%
			int i = 0;
		//loop through the list of review JSPs
		while(reviewIterator.hasNext())
     {
            //remember, the keys of the reviewJSPs hashmap is in the
            //format: stepNumber.pageNumber
            String stepAndPage = (String) reviewIterator.next();

			//finally get the path to the review JSP (the value)
			String reviewJSP = (String) reviewJSPs.get(stepAndPage);
			try
		  {
		  	int stepNum = Integer.parseInt(stepAndPage.substring(0, stepAndPage.indexOf(".")));
		  	boolean isSkip = subInfo.getSubmissionConfig().getStep(stepNum).isSkip();
		  	
		  	if (isSkip)
		  		continue;
		  }
		  catch (Exception e) { }
		  
			String heading = headings.get(i);
			//if (hideSubmissionOriginal == false
			//	|| (hideSubmissionOriginal == true && heading.equals("") == false))
			if (true)
			{
	%>
		    <tr>
                <td class="evenRowOddCol">
        		<%
        		if (heading.equals("") == false)
        			out.print("<h4>"+heading+"</h4>");
       			%>
        
				<%--Load the review JSP and pass it step & page info--%>
				<jsp:include page="<%=reviewJSP%>">
					<jsp:param name="submission.jump" value="<%=stepAndPage%>" />	
				</jsp:include>
                </td>
            </tr>
	<%
			}
			
    }

%>
                </table>
                                    
        <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
        <%= SubmissionController.getSubmissionParameters(context, request) %>

        <p>&nbsp;</p>
    
        <center>
            <table border="0" width="80%">
                <tr>
                    <td width="100%">&nbsp;</td>
                    <td>
                        <input type="submit" name="<%=AbstractProcessingStep.PREVIOUS_BUTTON%>" value="<fmt:message key="jsp.submit.review.button.previous"/>" />
                    </td>
                    <td>
                        <input type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.review.button.next"/>" />
                    </td>
                    <td>&nbsp;&nbsp;&nbsp;</td>

                    <td align="right">
                        <input type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.review.button.cancelsave"/>" />
                    </td>
                </tr>
            </table>
        </center>

    </form>

</dspace:layout>
