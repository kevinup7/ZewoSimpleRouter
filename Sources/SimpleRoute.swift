//SimpleRoute.swift
//
//The MIT License (MIT)
//
//Copyright (c) 2016 Kevin Sullivan
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import HTTP

public struct SimpleRoute: RouteType, Equatable {
	public var actions: [Method: Action]
	public let path: String
    
	let segments: [SimpleRouteSegment]
	let staticPath: Bool
	let fixedLength: Bool
	
	public init(methods: Set<Method>, path: String, middleware: [MiddlewareType], responder: ResponderType) {
		self.actions = [:]
		self.path = path
		let segments = path.simpleRouteSegments()
		
		self.fixedLength = !segments.contains { (segment) -> Bool in
			return !segment.isFixedLength
		}
		
		self.staticPath = !segments.contains({ (segment) -> Bool in
			return !segment.isStatic
		})
		
		self.segments = segments
		addResponder(responder, forMethods: methods)
	}
    
    public init(path: String, actions: [Method: Action]) {
        self.path = path
        self.actions = actions
        
        let segments = path.simpleRouteSegments()
        
        self.fixedLength = !segments.contains { (segment) -> Bool in
            return !segment.isFixedLength
        }
        
        self.staticPath = !segments.contains({ (segment) -> Bool in
            return !segment.isStatic
        })
        
        self.segments = segments
    }
	
	public mutating func addResponder(handler: ResponderType, forMethods methods: Set<Method>) {
		for method in methods {
			actions[method] = Action(middleware: [], responder: handler)
		}
	}
}

extension SimpleRoute {
    func matchesFixedLengthPath(path: [String]) -> [String: String]? {
        guard segments.count == path.count else {
            return nil
        }
        
        var parameters = [String : String]()
        
        for (pathComponent, segment) in zip(path, segments) {
            if case .Static(let segmentValue) = segment {
                if segmentValue != pathComponent {
                    return nil
                }
            } else if case .Parameter(let parameter) = segment {
                parameters[parameter] = pathComponent
            }
        }
        
        return parameters
    }
    
    func matchesVariableLengthPath(path: [String]) -> [String: String]? {
        guard segments.count <= path.count else {
            return nil
        }
        
        var parameters = [String : String]()
        
        var segmentIndex = 0
        while segmentIndex < segments.count {
            let segment = segments[segmentIndex]
            
            switch segment {
            case .Static(let segmentValue):
                if segmentValue != path[segmentIndex] {
                    return nil
                }
            case .Parameter(let paramName):
                parameters[paramName] = path[segmentIndex]
            case .Wildcard:
                let wildcardPath = path[segmentIndex ..< path.count]
                let pathString = wildcardPath.joinWithSeparator("/")
                parameters["*"] = pathString
                
                return parameters
            }
            
            segmentIndex += 1
        }
        
        return parameters
    }
}

extension SimpleRoute {
	func exactMatch(route: SimpleRoute) -> Bool {
		for (lhsSegment, rhsSegment) in zip(self.segments, route.segments) {
			if !lhsSegment.exactMatch(rhsSegment) {
				return false
			}
		}
		return true
	}
}

public func ==(lhs: SimpleRoute, rhs: SimpleRoute) -> Bool {
	return lhs.segments == rhs.segments
}

extension String {
	func simpleRouteSegments() -> [SimpleRouteSegment] {
		let pathSegments = self.split("/")
		var routeSegments: [SimpleRouteSegment] = []
		
		guard pathSegments.count > 0 else {
			return routeSegments
		}
		
		for pathSegment in pathSegments {
			if pathSegment.startsWith(":") {
				let paramName = pathSegment[pathSegment.startIndex.advancedBy(1) ..< pathSegment.endIndex]
				routeSegments.append(.Parameter(paramName))
			} else if pathSegment.startsWith("*") {
				guard pathSegments.last == pathSegment else {
					preconditionFailure("Wildcard path segments must be the last segment in the path")
				}
				routeSegments.append(.Wildcard)
			} else {
				routeSegments.append(.Static(pathSegment))
			}
		}
		
		return routeSegments
	}
}
