/*
 * CommunityFiliator.java
 *
 * Version: $Revision: 1545 $
 *
 * Date: $Date: 2006-07-10 13:04:02 -0700 (Mon, 10 Jul 2006) $
 *
 * Copyright (c) 2002-2005, Hewlett-Packard Company and Massachusetts
 * Institute of Technology.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the Hewlett-Packard Company nor the name of the
 * Massachusetts Institute of Technology nor the names of their
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package org.dspace.administer;

import java.io.IOException;
import java.sql.SQLException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.PosixParser;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Community;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.handle.HandleManager;
import org.dspace.storage.rdbms.DatabaseManager;

/**
 * A command-line tool for setting/removing community/sub-community
 * relationships. Takes community DB Id or handle arguments as inputs.
 * 
 * @author rrodgers
 * @version $Revision: 1545 $
 */

public class CommunityFiliator
{
    public static void main(String[] argv) throws Exception
    {
        // create an options object and populate it
        CommandLineParser parser = new PosixParser();

        Options options = new Options();

        options.addOption("s", "set", false, "set a parent/child relationship");
        options.addOption("r", "remove", false,
                "remove a parent/child relationship");
        options.addOption("p", "parent", true,
                "parent community (handle or database ID)");
        options.addOption("c", "child", true,
                "child community (handle or databaseID)");
        options.addOption("h", "help", false, "help");

        CommandLine line = parser.parse(options, argv);

        String command = null; // set or remove
        String parentID = null;
        String childID = null;

        if (line.hasOption('h'))
        {
            HelpFormatter myhelp = new HelpFormatter();
            myhelp.printHelp("CommunityFiliator\n", options);
            System.out
                    .println("\nestablish a relationship: CommunityFiliator -s -p parentID -c childID");
            System.out
                    .println("remove a relationship: CommunityFiliator -r -p parentID -c childID");

            System.exit(0);
        }

        if (line.hasOption('s'))
        {
            command = "set";
        }

        if (line.hasOption('r'))
        {
            command = "remove";
        }

        if (line.hasOption('p')) // parent
        {
            parentID = line.getOptionValue('p');
        }

        if (line.hasOption('c')) // child
        {
            childID = line.getOptionValue('c');
        }

        // now validate
        // must have a command set
        if (command == null)
        {
            System.out
                    .println("Error - must run with either set or remove (run with -h flag for details)");
            System.exit(1);
        }

        if (command.equals("set") || command.equals("remove"))
        {
            if (parentID == null)
            {
                System.out
                        .println("Error - a parentID must be specified (run with -h flag for details)");
                System.exit(1);
            }

            if (childID == null)
            {
                System.out
                        .println("Error - a childID must be specified (run with -h flag for details)");
                System.exit(1);
            }
        }

        CommunityFiliator filiator = new CommunityFiliator();
        Context c = new Context();

        // ve are superuser!
        c.setIgnoreAuthorization(true);

        try
        {
            // validate and resolve the parent and child IDs into commmunities
            Community parent = filiator.resolveCommunity(c, parentID);
            Community child = filiator.resolveCommunity(c, childID);

            if (parent == null)
            {
                System.out.println("Error, parent community cannot be found: "
                        + parentID);
                System.exit(1);
            }

            if (child == null)
            {
                System.out.println("Error, child community cannot be found: "
                        + childID);
                System.exit(1);
            }

            if (command.equals("set"))
            {
                filiator.filiate(c, parent, child);
            }
            else
            {
                filiator.defiliate(c, parent, child);
            }
        }
        catch (SQLException sqlE)
        {
            System.out.println("Error - SQL exception: " + sqlE.toString());
        }
        catch (AuthorizeException authE)
        {
            System.out.println("Error - Authorize exception: "
                    + authE.toString());
        }
        catch (IOException ioE)
        {
            System.out.println("Error - IO exception: " + ioE.toString());
        }
    }

    public void filiate(Context c, Community parent, Community child)
            throws SQLException, AuthorizeException, IOException
    {
        // check that a valid filiation would be established
        // first test - proposed child must currently be an orphan (i.e.
        // top-level)
        Community childDad = child.getParentCommunity();

        if (childDad != null)
        {
            System.out.println("Error, child community: " + child.getID()
                    + " already a child of: " + childDad.getID());
            System.exit(1);
        }

        // second test - circularity: parent's parents can't include proposed
        // child
        Community[] parentDads = parent.getAllParents();

        for (int i = 0; i < parentDads.length; i++)
        {
            if (parentDads[i].getID() == child.getID())
            {
                System.out
                        .println("Error, circular parentage - child is parent of parent");
                System.exit(1);
            }
        }

        // everthing's OK
        parent.addSubcommunity(child);

        // complete the pending transaction
        c.complete();
        System.out.println("Filiation complete. Community: '" + parent.getID()
                + "' is parent of community: '" + child.getID() + "'");
    }

    public void defiliate(Context c, Community parent, Community child)
            throws SQLException, AuthorizeException, IOException
    {
        // verify that child is indeed a child of parent
        Community[] parentKids = parent.getSubcommunities();
        boolean isChild = false;

        for (int i = 0; i < parentKids.length; i++)
        {
            if (parentKids[i].getID() == child.getID())
            {
                isChild = true;

                break;
            }
        }

        if (!isChild)
        {
            System.out
                    .println("Error, child community not a child of parent community");
            System.exit(1);
        }

        // OK remove the mappings - but leave the community, which will become
        // top-level
        DatabaseManager.updateQuery(c,
                "DELETE FROM community2community WHERE parent_comm_id= ? "+
                "AND child_comm_id= ? ", parent.getID(), child.getID());

        // complete the pending transaction
        c.complete();
        System.out.println("Defiliation complete. Community: '" + child.getID()
                + "' is no longer a child of community: '" + parent.getID()
                + "'");
    }

    private Community resolveCommunity(Context c, String communityID)
            throws SQLException
    {
        Community community = null;

        if (communityID.indexOf('/') != -1)
        {
            // has a / must be a handle
            community = (Community) HandleManager.resolveToObject(c,
                    communityID);

            // ensure it's a community
            if ((community == null)
                    || (community.getType() != Constants.COMMUNITY))
            {
                community = null;
            }
        }
        else
        {
            community = Community.find(c, Integer.parseInt(communityID));
        }

        return community;
    }
}
