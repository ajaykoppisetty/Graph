/*
 * Copyright (C) 2015 - 2016, CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
@testable import Graph

class EntityTests: XCTestCase, GraphDelegate {
    var saveException: XCTestExpectation?
    var delegateException: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDefaultGraph() {
        let graph = Graph()
        graph.delegate = self
        graph.watchForEntity(types: ["T"])
        graph.clear()
        
        let entity = Entity(type: "T")
        entity["p"] = "v"
        entity.addToGroup("g")
        
        XCTAssertTrue("v" == entity["p"] as? String)
        
        saveException = expectationWithDescription("[EntityTests Error: Save Entity test failed.]")
        delegateException = expectationWithDescription("[EntityTests Error: Delegate Entity test failed.]")
        
        graph.save { [weak self] (success: Bool, error: NSError?) in
            self?.saveException?.fulfill()
            XCTAssertTrue(success)
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testNamedGraphSave() {
        let graph = Graph(name: "EntityTests-testNamedGraphSave")
        graph.clear()
        
        graph.watchForEntity(types: ["T"])
        graph.delegate = self
        
        let entity = Entity(type: "T", graph: "EntityTests-testNamedGraphSave")
        entity["p"] = "v"
        entity.addToGroup("g")
        
        XCTAssertTrue("v" == entity["p"] as? String)
        
        saveException = expectationWithDescription("[EntityTests Error: Save Entity test failed.]")
        delegateException = expectationWithDescription("[EntityTests Error: Delegate Entity test failed.]")
        
        graph.save { [weak self] (success: Bool, error: NSError?) in
            self?.saveException?.fulfill()
            XCTAssertTrue(success)
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testReferenceGraphSave() {
        let graph = Graph(name: "EntityTests-testReferenceGraphSave")
        graph.clear()
        
        graph.watchForEntity(types: ["T"])
        graph.delegate = self
        
        let entity = Entity(type: "T", graph: graph)
        entity["p"] = "v"
        entity.addToGroup("g")
        
        XCTAssertTrue("v" == entity["p"] as? String)
        
        saveException = expectationWithDescription("[EntityTests Error: Save Entity test failed.]")
        delegateException = expectationWithDescription("[EntityTests Error: Delegate Entity test failed.]")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
            graph.save { [weak self] (success: Bool, error: NSError?) in
                self?.saveException?.fulfill()
                XCTAssertTrue(success)
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testAsyncGraphSave() {
        saveException = expectationWithDescription("[EntityTests Error: Save Entity test failed.]")
        delegateException = expectationWithDescription("[EntityTests Error: Delegate Entity test failed.]")
        
        var graph: Graph!
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
            graph = Graph(name: "EntityTests-testAsyncGraphSave")
            graph.clear()
            
            graph.watchForEntity(types: ["T"])
            graph.delegate = self
            
            let entity = Entity(type: "T", graph: graph)
            entity["p"] = "v"
            entity.addToGroup("g3")
            
            XCTAssertTrue("v" == entity["p"] as? String)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
                graph.save { [weak self] (success: Bool, error: NSError?) in
                    self?.saveException?.fulfill()
                    XCTAssertTrue(success)
                }
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func graphDidInsertEntity(graph: Graph, entity: Entity) {
        delegateException?.fulfill()
    }
}