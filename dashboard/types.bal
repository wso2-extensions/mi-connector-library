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

# Represents the connector store metadata from .connector-store/meta.json
#
# + name - The connector name
# + displayName - The display name shown in UI
# + product - The product type (e.g., "MI")
# + description - The connector description
# + category - The connector category
# + version - The connector version
type ConnectorMeta record {|
    string name?;
    string displayName?;
    string product?;
    string description?;
    string category?;
    string version?;
    json...;
|};

# Represents an MI Connector repository
#
# + name - The repository name
# + fullName - The full repository name (org/repo)
# + htmlUrl - The GitHub URL of the repository
# + description - The repository description
# + defaultBranch - The default branch name
# + archived - Whether the repository is archived
# + meta - The connector metadata from meta.json
type MIConnector record {|
    string name;
    string fullName;
    string htmlUrl;
    string description;
    string defaultBranch;
    boolean archived;
    ConnectorMeta? meta;
|};

# Represents a list of connectors
#
# + mi_connectors - Array of MI connectors
type ConnectorList record {|
    MIConnector[] mi_connectors;
|};

# Represents a workflow badge
#
# + name - The badge name/label
# + badgeUrl - The shields.io badge URL
# + htmlUrl - The link URL when badge is clicked
type WorkflowBadge record {|
    string name;
    string badgeUrl = NA_BADGE;
    string htmlUrl = "";
|};

# Represents all badges for a repository
#
# + release - The release version badge
# + pullRequests - The pull requests badge
type RepoBadges record {|
    WorkflowBadge release?;
    WorkflowBadge pullRequests?;
|};

# Represents a GitHub repository from API
#
# + name - The repository name
# + full_name - The full repository name (org/repo)
# + html_url - The GitHub URL of the repository
# + description - The repository description
# + default_branch - The default branch name
# + archived - Whether the repository is archived
type GitHubRepo record {|
    string name;
    string full_name;
    string html_url;
    string? description;
    string default_branch;
    boolean archived;
    json...;
|};

# Represents the connector list JSON output
#
# + mi_connectors - Array of connector outputs
type ConnectorListOutput record {|
    ConnectorOutput[] mi_connectors;
|};

# Represents a connector in the output JSON
#
# + name - The connector name
# + displayName - The display name shown in UI
# + repository - The repository name
# + description - The connector description
# + url - The GitHub URL of the repository
# + meta - The connector metadata
type ConnectorOutput record {|
    string name;
    string displayName;
    string repository;
    string description;
    string url;
    ConnectorMeta? meta;
|};
