<%--
  -- footer-home.jsp
  --
  -- Version: $Revision: 1778 $
  --
  -- Date: $Date: 2007-04-09 07:03:14 -0500 (Mon, 09 Apr 2007) $
  --
  -- Copyright (c) 2002, Hewlett-Packard Company and Massachusetts
  -- Institute of Technology.  All rights reserved.
  --
  -- Redistribution and use in source and binary forms, with or without
  -- modification, are permitted provided that the following conditions are
  -- met:
  --
  -- - Redistributions of source code must retain the above copyright
  -- notice, this list of conditions and the following disclaimer.
  --
  -- - Redistributions in binary form must reproduce the above copyright
  -- notice, this list of conditions and the following disclaimer in the
  -- documentation and/or other materials provided with the distribution.
  --
  -- - Neither the name of the Hewlett-Packard Company nor the name of the
  -- Massachusetts Institute of Technology nor the names of their
  -- contributors may be used to endorse or promote products derived from
  -- this software without specific prior written permission.
  --
  -- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  -- ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  -- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  -- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  -- HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  -- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  -- BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
  -- OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  -- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  -- TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
  -- USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  -- DAMAGE.1
  --%>

<%--
  - Footer for home page
  --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>

<%
    String sidebar = (String) request.getAttribute("dspace.layout.sidebar");
    int overallColSpan = 3;
    if (sidebar == null)
    {
        overallColSpan = 2;
    }
%>
                    <%-- End of page content --%>
                    <p>&nbsp;</p>
                </td>

            <%-- Right-hand side bar if appropriate --%>
<%
    if (sidebar != null)
    {
%>
                <td class="sidebar">
                    <%= sidebar %>
                </td>
<%
    }
%>
            </tr>

            <%-- Page footer --%>
             <tr class="pageFooterBar">
                <td colspan="<%= overallColSpan %>" class="pageFootnote">
                    <table class="pageFooterBar" width="100%">
                        <tr>
                            <td>
                                <a href="http://validator.w3.org/check?uri=referer"><img
                                    src="<%= request.getContextPath() %>/image/valid-xhtml10.png"
                                    alt="Valid XHTML 1.0!" height="31" width="88" /></a>
                            </td>
                            <td class="pageFootnote">
                                <fmt:message key="jsp.layout.footer-default.text"/>&nbsp;-
                				<fmt:message key="jsp.layout.footer-default.text-dspace-dlll"/>&nbsp;-
                                <a target="_blank" href="<%= request.getContextPath() %>/feedback"><fmt:message key="jsp.layout.footer-default.feedback"/></a>
                                <a href="<%= request.getContextPath() %>/htmlmap"></a>
                            </td>
                            <td nowrap="nowrap" valign="middle"> <%-- nowrap, valign for broken NS 4.x --%>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        
        <%--
          - 20110604 by Pudding Chen
          - Please keep #dspace_no_exception_flag tag for exception detection.
          --%>
        <span id="dspace_no_exception_flag" />
    </body>
</html>