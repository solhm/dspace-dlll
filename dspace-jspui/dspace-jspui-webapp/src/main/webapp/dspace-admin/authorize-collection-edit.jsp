<%--
  - authorize_collection_edit.jsp
  -
  - $Id: authorize-collection-edit.jsp 1947 2007-05-18 13:50:29Z cjuergen $
  -
  - Version: $Revision: 1947 $
  -
  - Date: $Date: 2007-05-18 08:50:29 -0500 (Fri, 18 May 2007) $
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


<%--
  - Show policies for a collection, allowing you to modify, delete
  -  or add to them
  -
  - Attributes:
  -  collection - Collection being modified
  -  policies - ResourcePolicy [] of policies for the collection
  - Returns:
  -  submit value collection_addpolicy    to add a policy
  -  submit value collection_editpolicy   to edit policy
  -  submit value collection_deletepolicy to delete policy
  -
  -  policy_id - ID of policy to edit, delete
  -
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>


<%@ page import="java.util.List"     %>
<%@ page import="java.util.Iterator" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.authorize.ResourcePolicy" %>
<%@ page import="org.dspace.content.Collection"       %>
<%@ page import="org.dspace.core.Constants"           %>
<%@ page import="org.dspace.eperson.EPerson"          %>
<%@ page import="org.dspace.eperson.Group"            %>

<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="org.dspace.core.Context"   %>

<%
    Collection collection = (Collection) request.getAttribute("collection");
    List policies =
        (List) request.getAttribute("policies");
    
    String parenttitlekey = "jsp.administer";
    String parentlink = "/dspace-admin";
    if (collection != null)
    {
    	parenttitlekey = "jsp.tools.edit-collection.title";
    	parentlink = "/tools/edit-communities?collection_id=" + collection.getID();
    }
    
    if (request.getParameter("authorize_admin") != null)
    {
    	parenttitlekey = "jsp.dspace-admin.collection-select.title";
    	parentlink = "/dspace-admin/authorize?submit_type=submit_collection";
    }
    
    String collectionName = collection.getName();
    if (collectionName.equals(""))
    	collectionName = LocaleSupport.getLocalizedMessage(pageContext, 
							"org.dspace.content.Collection.untitled");
    
    String collectionURL = request.getContextPath() + "/handle/" + collection.getHandle();
    Context context = UIUtil.obtainContext(request);
    
    boolean inAuthorizeAdmin = (request.getParameter("authorize_admin") != null);
    
    
%>

<dspace:layout titlekey="jsp.dspace-admin.authorize-collection-edit.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="<%= parenttitlekey %>"
               parentlink="<%= parentlink %>"
               nocache="true">
  <table width="95%">
    <tr>
      <td align="left">
            <h1><fmt:message key="jsp.dspace-admin.authorize-collection-edit.policies">
	            <fmt:param><%= "<a href=\""+collectionURL+"\" target=\"_blank\">" + collectionName + "</a>" %></fmt:param>
	            <fmt:param><%= "<a href=\""+collectionURL+"\" target=\"_blank\">" + collection.getHandle() + "</a>" %></fmt:param>
	            <fmt:param><%= collection.getID() %></fmt:param>
        	</fmt:message></h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\") + \"#collectionpolicies\"%>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

 <form action="<%= request.getContextPath() %>/dspace-admin/authorize" method="post"> 
 	<%
		if (inAuthorizeAdmin)
		{
			%>
			<input type="hidden" name="authorize_admin" value="true" />
			<%
		}
  	%>
    <p align="center" style="display:none;">
            <input type="hidden" name="collection_id" value="<%=collection.getID()%>" />
            <input type="submit" name="submit_collection_add_policy" value="<fmt:message key="jsp.dspace-admin.general.addpolicy"/>"
        		id="submit_collection_add_policy" />
    </p>
 </form>

<form action="<%= request.getContextPath() %>/dspace-admin/authorize" method="post">
  	<%
		if (inAuthorizeAdmin)
		{
			%>
			<input type="hidden" name="authorize_admin" value="true" />
			<%
		}
  	%>
        <table class="miscTable" align="center" summary="Collection Policy Edit Form">
            <tr>
               <th class="oddRowOddCol"><strong><fmt:message key="jsp.general.id" /></strong></th>
               <th class="oddRowEvenCol"><strong><fmt:message key="jsp.dspace-admin.general.action"/></strong></th>
               <th class="oddRowOddCol"><strong><fmt:message key="jsp.dspace-admin.general.group"/></strong></th>
               <th class="oddRowEvenCol">&nbsp;</th>
               <th class="oddRowOddCol">&nbsp;</th>
            </tr>

<%
    String row = "even";
    Iterator i = policies.iterator();

    while( i.hasNext() )
    {
        ResourcePolicy rp = (ResourcePolicy) i.next();
%>
      
            <tr>
               <td class="<%= row %>RowOddCol"><%= rp.getID() %></td>
               <td class="<%= row %>RowEvenCol" align="center">
                    <%//= rp.getActionText() %>
    				<%= UIUtil.getAuthorizeActionLocalizeMessage(pageContext, rp.getActionText()) %>
               </td>
               <td class="<%= row %>RowOddCol">
                    <%//= (rp.getGroup()   == null ? "..." : rp.getGroup().getName() ) %>
                	<%= (rp.getGroup()   == null ? "..." : 
                			UIUtil.getGroupLocalizeName(context, pageContext, rp.getGroup()) ) %>
               </td>
               <td class="<%= row %>RowEvenCol">
                    <input type="hidden" name="policy_id" value="<%= rp.getID() %>" />
                    <input type="hidden" name="collection_id" value="<%= collection.getID() %>" />
                    <input type="submit" name="submit_collection_edit_policy" value="<fmt:message key="jsp.dspace-admin.general.edit"/>" />
               </td>
               <td class="<%= row %>RowOddCol">
                    <input type="submit" name="submit_collection_delete_policy" value="<fmt:message key="jsp.dspace-admin.general.delete"/>" />
               </td>
            </tr>
<%
        row = (row.equals("odd") ? "even" : "odd");
    }
%>
       </table>
     </form>


    	<p align="center">
            <table width="70%" align="center">
                <tr>
                    <td align="left">
                        <input type="button" onclick="document.getElementById('submit_collection_add_policy').click();" 
        					value="<fmt:message key="jsp.dspace-admin.general.addpolicy"/>" />
                    </td>
                    <td align="right">
            			<%
            			if (inAuthorizeAdmin)
        				{
        					%>
        				<form method="post" action="<%= request.getContextPath() %>/dspace-admin/authorize">
        					<input type="submit" name="submit_collection" value="<fmt:message key="jsp.tools.general.return"/>"/>
        				</form>
        					
        					<%
        				}
        				else
        				{
        					%>
        				<form method="post" action="<%= request.getContextPath() %>/tools/edit-communities">
            				<input type="hidden" name="collection_id" value="<%= collection.getID() %>" />
                        	<input type="submit" name="submit_cancel" value="<fmt:message key="jsp.tools.general.return"/>"/>
            			</form>
        					<%
        				}
        				%>
            			
                    </td>
                </tr>
            </table>
        </p>
</dspace:layout>
