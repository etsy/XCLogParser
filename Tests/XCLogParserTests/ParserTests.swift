// Copyright (c) 2019 Spotify AB.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import XCTest
@testable import XCLogParser

class ParserTests: XCTestCase {

    let parser = ParserBuildSteps()

    func testDateFormatterUsesJSONFormat() {
        let jsonDateString = "2014-09-27T12:30:00.450000Z"
        let date = parser.dateFormatter.date(from: jsonDateString)
        XCTAssertNotNil(date)
        if let date = date {
            let formattedDate = parser.dateFormatter.string(from: date)
            XCTAssertEqual(jsonDateString, formattedDate)
        }
    }

    func testBuildIdentifierShouldUseMachineName() throws {
        let machineName = UUID.init().uuidString
        let uniqueIdentifier = "uniqueIdentifier"
        let timestamp = Date().timeIntervalSinceNow
        let parser = ParserBuildSteps(machineName: machineName)
        let fakeMainSection = IDEActivityLogSection(sectionType: 1,
                                                    domainType: "",
                                                    title: "Main",
                                                    signature: "",
                                                    timeStartedRecording: timestamp,
                                                    timeStoppedRecording: timestamp,
                                                    subSections: [],
                                                    text: "",
                                                    messages: [],
                                                    wasCancelled: false,
                                                    isQuiet: false,
                                                    wasFetchedFromCache: false,
                                                    subtitle: "",
                                                    location: DVTDocumentLocation(documentURLString: "",
                                                                                  timestamp: timestamp),
                                                    commandDetailDesc: "",
                                                    uniqueIdentifier: uniqueIdentifier,
                                                    localizedResultString: "",
                                                    xcbuildSignature: "",
                                                    unknown: 0)
        let fakeActivityLog = IDEActivityLog(version: 10, mainSection: fakeMainSection)
        let buildStep = try parser.parse(activityLog: fakeActivityLog)
        XCTAssertEqual("\(machineName)_\(uniqueIdentifier)", buildStep.buildIdentifier)

        if let hostName = Host.current().localizedName {
            let parserNoMachineName = ParserBuildSteps(machineName: nil)
            let buildStepNoMachineName = try parserNoMachineName.parse(activityLog: fakeActivityLog)
            XCTAssertEqual("\(hostName)_\(uniqueIdentifier)", buildStepNoMachineName.buildIdentifier)
        }
    }

}
