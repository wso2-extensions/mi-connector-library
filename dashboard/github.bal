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

import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/os;
import ballerinax/github;

configurable string token = os:getEnv(GITHUB_TOKEN_ENV);

final github:Client github = check new ({
    retryConfig: {
        count: 3,
        interval: 1,
        backOffFactor: 2.0,
        maxWaitInterval: 3
    },
    auth: {token}
});

final http:Client rawGithubClient = check new (GITHUB_RAW_URL, {
    retryConfig: {
        count: 3,
        interval: 1,
        backOffFactor: 2.0,
        maxWaitInterval: 3
    }
});

# Fetches all repositories from the wso2-extensions organization
#
# + return - Array of GitHub repositories or error
function fetchAllRepositories() returns GitHubRepo[]|error {
    GitHubRepo[] repos = [];
    int page = 1;
    int perPage = 100;

    while true {
        github:MinimalRepository[] repoPage = check github->/orgs/[WSO2_EXTENSIONS_ORG]/repos(
            per_page = perPage,
            page = page,
            'type = "all",
            sort = "full_name"
        );

        if repoPage.length() == 0 {
            break;
        }

        foreach github:MinimalRepository repo in repoPage {
            if repo.archived is boolean && repo.archived == true {
                continue;
            }
            if EXCLUDE_REPOS.indexOf(repo.name) != () {
                continue;
            }

            repos.push({
                name: repo.name,
                full_name: repo.full_name,
                html_url: repo.html_url,
                description: repo.description,
                default_branch: repo.default_branch ?: BRANCH_MAIN,
                archived: repo.archived ?: false
            });
        }

        page += 1;
    }

    log:printInfo(string `Fetched ${repos.length()} total repositories from ${WSO2_EXTENSIONS_ORG}`);
    return repos;
}

# Fetches the connector metadata from a repository
#
# + repoFullName - Full name of the repository (org/repo)
# + defaultBranch - Default branch of the repository
# + return - Connector metadata or nil if not found
function getConnectorMeta(string repoFullName, string defaultBranch) returns ConnectorMeta? {
    string path = string `/${repoFullName}/${defaultBranch}/${CONNECTOR_META_FILE}`;
    
    ConnectorMeta|error result = rawGithubClient->get(path);
    if result is error {
        // File doesn't exist or other error - not an MI connector
        return ();
    }
    return result;
}

# Checks if a connector metadata indicates it's an MI connector
#
# + meta - Connector metadata
# + return - True if it's an MI connector
function isMIConnector(ConnectorMeta? meta) returns boolean {
    if meta is () {
        return false;
    }
    return meta.product == "MI";
}

# Fetches all MI connectors from the organization
#
# + return - Array of MI connectors or error
function fetchMIConnectors() returns MIConnector[]|error {
    log:printInfo("Fetching all repositories from organization...");
    GitHubRepo[] allRepos = check fetchAllRepositories();
    
    MIConnector[] miConnectors = [];
    
    log:printInfo("Checking repositories for MI connector meta file...");
    foreach GitHubRepo repo in allRepos {
        ConnectorMeta? meta = getConnectorMeta(repo.full_name, repo.default_branch);
        
        if isMIConnector(meta) {
            log:printInfo(string `  Found MI connector: ${repo.name}`);
            miConnectors.push({
                name: repo.name,
                fullName: repo.full_name,
                htmlUrl: repo.html_url,
                description: repo.description ?: "",
                defaultBranch: repo.default_branch,
                archived: repo.archived,
                meta: meta
            });
        }
    }
    
    log:printInfo(string `Found ${miConnectors.length()} MI connectors with product: MI`);
    return miConnectors;
}

# Gets the badges for a repository
#
# + connector - MI Connector
# + return - Repository badges or error
function getRepoBadges(MIConnector connector) returns RepoBadges|error {
    string repoName = connector.name;
    string fullName = connector.fullName;
    string defaultBranch = connector.defaultBranch;
    
    // Release badge
    WorkflowBadge releaseBadge = {
        name: "Latest Release",
        badgeUrl: string `${GITHUB_BADGE_URL}/v/release/${fullName}?color=${BADGE_COLOR_GREEN}&label=`,
        htmlUrl: string `${connector.htmlUrl}/releases`
    };
    
    // Try to get latest release
    github:Release|error release = github->/repos/[WSO2_EXTENSIONS_ORG]/[repoName]/releases/latest;
    if release is error {
        releaseBadge.badgeUrl = NA_BADGE;
    }
    
    // Pull requests badge
    WorkflowBadge prBadge = {
        name: "Pull Requests",
        badgeUrl: string `${GITHUB_BADGE_URL}/issues-pr-raw/${fullName}.svg?label=`,
        htmlUrl: string `${connector.htmlUrl}/pulls`
    };
    
    return {
        release: releaseBadge,
        pullRequests: prBadge
    };
}

# Saves the connector list to a JSON file
#
# + connectors - Array of MI connectors
# + return - Error if save fails
function saveConnectorList(MIConnector[] connectors) returns error? {
    ConnectorOutput[] outputs = [];
    
    foreach MIConnector connector in connectors {
        string displayName = connector.meta?.displayName ?: connector.name;
        string name = connector.meta?.name ?: connector.name;
        
        outputs.push({
            name: name,
            displayName: displayName,
            repository: connector.name,
            description: connector.description,
            url: connector.htmlUrl,
            meta: connector.meta
        });
    }
    
    ConnectorListOutput outputData = {
        mi_connectors: outputs
    };
    
    check io:fileWriteJson(CONNECTOR_LIST_JSON, outputData.toJson());
    log:printInfo(string `Connector list saved to ${CONNECTOR_LIST_JSON}`);
}
