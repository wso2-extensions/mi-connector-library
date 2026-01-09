// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.org).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.array;

# Gets the display name for a connector
#
# + connector - MI Connector
# + return - Display name
isolated function getConnectorDisplayName(MIConnector connector) returns string {
    if connector.meta is ConnectorMeta {
        ConnectorMeta meta = <ConnectorMeta>connector.meta;
        if meta.displayName is string {
            return <string>meta.displayName;
        }
        if meta.name is string {
            return <string>meta.name;
        }
    }
    return connector.name;
}

# Gets a formatted badge markdown
#
# + badge - Workflow badge
# + return - Markdown formatted badge
isolated function getBadge(WorkflowBadge? badge) returns string {
    if badge is () {
        return string `[![N/A](${NA_BADGE})]("")`;
    }
    return string `[![${badge.name}](${badge.badgeUrl})](${badge.htmlUrl})`;
}

# Gets the repository link markdown
#
# + connector - MI Connector
# + return - Markdown formatted link
isolated function getRepoLink(MIConnector connector) returns string {
    string displayName = getConnectorDisplayName(connector);
    return string `[${displayName}](${connector.htmlUrl})`;
}

# Generates a dashboard row for a connector
#
# + connector - MI Connector
# + return - Markdown table row or error
function getDashboardRow(MIConnector connector) returns string|error {
    RepoBadges badges = check getRepoBadges(connector);
    
    string repoLink = getRepoLink(connector);
    string releaseBadge = getBadge(badges.release);
    string prBadge = getBadge(badges.pullRequests);
    
    return string `|${repoLink}|${releaseBadge}|${prBadge}|`;
}

# Sorts connectors by display name
#
# + connectors - Array of MI connectors
# + return - Sorted array
function sortConnectorsByName(MIConnector[] connectors) returns MIConnector[] {
    return array:sort(connectors, array:ASCENDING, isolated function(MIConnector c) returns string {
        return getConnectorDisplayName(c).toLowerAscii();
    });
}
