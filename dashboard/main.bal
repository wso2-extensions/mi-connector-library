// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.org).
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
    MIConnector[] handwritten = connectors.filter(c => !c.isGenerated);
    MIConnector[] generated = connectors.filter(c => c.isGenerated && !c.isManuallyModified);
    MIConnector[] generatedModified = connectors.filter(c => c.isGenerated && c.isManuallyModified);

    string[] lines = [
        "### Handwritten Connectors",
        "",
        "These connectors are fully handwritten and manually maintained.",
        "",
        "| Name | Latest Version | Build | Pull Requests |",
        "| --- | --- | --- | --- |"
    ];

    foreach MIConnector connector in handwritten {
        lines.push(check getHandwrittenRow(connector));
    }

    lines.push("");
    lines.push("---");
    lines.push("");
    lines.push("### Generated from Ballerina Connectors");
    lines.push("");
    lines.push("These connectors are derived from the [Ballerina connector library](https://github.com/ballerina-platform/ballerina-library). They are generated using tooling and may optionally include manual modifications to better fit the WSO2 MI connector model.");
    lines.push("");
    lines.push("#### Generated");
    lines.push("");
    lines.push("These connectors are **purely generated** from their corresponding Ballerina connector packages with no manual modifications.");
    lines.push("");
    lines.push("| Name | Ballerina Source | Latest Version | Build | Pull Requests |");
    lines.push("| --- | --- | --- | --- | --- |");

    foreach MIConnector connector in generated {
        lines.push(check getGeneratedRow(connector));
    }

    lines.push("");
    lines.push("#### Generated & Modified");
    lines.push("");
    lines.push("These connectors were initially generated from their corresponding Ballerina connector packages and have been **manually modified** to extend or adapt functionality for WSO2 MI.");
    lines.push("");
    lines.push("| Name | Ballerina Source | Latest Version | Build | Pull Requests |");
    lines.push("| --- | --- | --- | --- | --- |");

    foreach MIConnector connector in generatedModified {
        lines.push(check getGeneratedRow(connector));
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
