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

import ballerina/io;
import ballerina/lang.regexp;
import ballerina/log;

public function main() returns error? {
    log:printInfo("============================================================");
    log:printInfo("WSO2 MI Connector Dashboard Updater");
    log:printInfo("============================================================");
    
    // Fetch MI connectors
    MIConnector[] miConnectors = check fetchMIConnectors();
    
    // Sort connectors by name
    MIConnector[] sortedConnectors = sortConnectorsByName(miConnectors);
    
    // Generate dashboard content
    string dashboardContent = check generateDashboard(sortedConnectors);
    
    // Update README
    check updateReadme(dashboardContent);
    
    // Save connector list
    check saveConnectorList(sortedConnectors);
    
    log:printInfo("============================================================");
    log:printInfo("Dashboard update completed!");
    log:printInfo("============================================================");
}

# Generates the complete dashboard content
#
# + connectors - Array of MI connectors
# + return - Dashboard markdown content or error
function generateDashboard(MIConnector[] connectors) returns string|error {
    string[] lines = [
        "### WSO2 MI Connectors",
        "",
        "These connectors enable WSO2 Micro Integrator to connect with various external services and systems.",
        "",
        "| Name | Latest Version | Pull Requests |",
        "|:---:|:---:|:---:|"
    ];
    
    foreach MIConnector connector in connectors {
        string row = check getDashboardRow(connector);
        lines.push(row);
    }
    
    return string:'join("\n", ...lines);
}

# Updates the README.md file with the new dashboard content
#
# + dashboardContent - New dashboard content
# + return - Error if update fails
function updateReadme(string dashboardContent) returns error? {
    string readme = check io:fileReadString(README_FILE);
    
    // Pattern to match content between dashboard markers
    string pattern = string `${DASHBOARD_START_MARKER}[\s\S]*${DASHBOARD_END_MARKER}`;
    string replacement = string `${DASHBOARD_START_MARKER}
${dashboardContent}
${DASHBOARD_END_MARKER}`;
    
    regexp:RegExp regex = check regexp:fromString(pattern);
    string updatedReadme = regex.replace(readme, replacement);
    
    check io:fileWriteString(README_FILE, updatedReadme);
    log:printInfo("README.md updated successfully!");
}
