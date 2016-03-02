//SimpleRouteMatcher.swift
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

public struct SimpleRouteMatcher: RouteMatcherType {
	public let routes: [RouteType]
	
	let staticRoutes: [String: SimpleRoute]
	let fixedLengthRoutes: [SimpleRoute]
	let wildcardRoutes: [SimpleRoute]
	
	public init(routes: [RouteType]) {
        self.routes = routes
        
        let simpleRoutes = routes.map { (route) -> SimpleRoute in
            return SimpleRoute(path: route.path, actions: route.actions)
        }
        
		var tempStatic: [String: SimpleRoute] = [:]
		var tempFixed: [SimpleRoute] = []
		var tempWildcard: [SimpleRoute] = []
		
		for route in simpleRoutes {
			if route.staticPath {
				tempStatic[route.path] = route
			} else if route.fixedLength {
				tempFixed.append(route)
			} else {
				tempWildcard.append(route)
			}
		}
		
		self.staticRoutes = tempStatic
		self.fixedLengthRoutes = tempFixed
		self.wildcardRoutes = tempWildcard
		
	}
	
    public func match(request: Request) -> RouteType? {
        guard let path = request.path else {
            return nil
        }
        
		// Try static routes
		if let route = staticRoutes[path] {
			return route
		}
		
		let pathComponents = path.split("/")
		
		// Try fixed length routes
		for route in fixedLengthRoutes {
			if let params = route.matchesFixedLengthPath(pathComponents) {
				return MatchedParamsRoute(path: path, actions: route.actions, fallback: route.fallback, params: params)
			}
		}
		
		// Try wildcard routes
		for route in wildcardRoutes {
			if let params = route.matchesVariableLengthPath(pathComponents) {
				return MatchedParamsRoute(path: path, actions: route.actions, fallback: route.fallback, params: params)
			}
		}
		
		return nil
	}
	
	public func splitPathIntoComponents(path: String) -> [String] {
		return path.split("/")
	}
	
	public func mergePathComponents(components: [String]) -> String {
		return components.joinWithSeparator("/")
	}
}

struct MatchedParamsRoute: RouteType {
    let path: String
    let actions: [Method : Action]
    let fallback: Action
    
    let params: [String: String]?
    
    init(path: String, actions: [Method: Action], fallback: Action, params: [String: String]) {
        self.path = path
        self.actions = actions
        self.fallback = fallback
        self.params = params
    }
    
    func respond(request: Request) throws -> Response {
        guard let action = actions[request.method] else {
            return try fallback.respond(request)
        }
        
        var request = request
        
        if let params = params {
            for (key, value) in params {
                request.pathParameters[key] = value
            }
        }
        
        return try action.respond(request)
    }
}
