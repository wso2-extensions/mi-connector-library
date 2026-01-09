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

// Organization Names
const WSO2_EXTENSIONS_ORG = "wso2-extensions";

// Branches
const BRANCH_MAIN = "main";


// Links

const GITHUB_RAW_URL = "https://raw.githubusercontent.com";
const GITHUB_BADGE_URL = "https://img.shields.io/github";

// Colors
const BADGE_COLOR_GREEN = "30c955";


// File Paths
const README_FILE = "../README.md";
const CONNECTOR_LIST_JSON = "resources/connector_list.json";
const CONNECTOR_META_FILE = ".connector-store/meta.json";

// Env variable Names
const GITHUB_TOKEN_ENV = "GITHUB_TOKEN";

// Misc

const NA_BADGE = "https://img.shields.io/badge/-N%2FA-yellow";
// Reserved for future use to indicate disabled connectors/repositories in the dashboard.
const DISABLED_BADGE = "https://img.shields.io/badge/-disabled-red";

// README Contents
const DASHBOARD_TITLE = "## Status Dashboard";
const DASHBOARD_START_MARKER = "<!-- DASHBOARD_START -->";
const DASHBOARD_END_MARKER = "<!-- DASHBOARD_END -->";

// Repositories to exclude
final string[] EXCLUDE_REPOS = [
    "mi-connector-library",
    "mi-connector-core",
    "ballerina-module-wso2-mi",
    "ballerina-mi-module-gen-tool"
];
