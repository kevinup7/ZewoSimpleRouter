//SimpleRouter.swift
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
import Router

public struct SimpleRouter: RouterType, RouterBuildable {
	let staticRoutes: [String: SimpleRoute]
	let fixedLengthRoutes: [SimpleRoute]
	let wildcardRoutes: [SimpleRoute]
    
    public let middleware: [MiddlewareType]
    public let fallback: ResponderType
    
    public init(_ basePath: String = "", middleware: MiddlewareType..., build: (route: RouterBuilder) -> Void) {
        
        self.middleware = middleware
        
        let builder = RouterBuilder(basePath: basePath)
        build(route: builder)
        self.fallback = builder.fallback
        
        let builderRoutes = builder.routes
        var allRoutes: [SimpleRoute] = []
        
        // Check each route to see if path is already being used
        for builderRoute in builderRoutes {
            let index = allRoutes.indexOf { route in
                return route.path == builderRoute.path
            }
            
            if let index = index {
                var route = allRoutes[index]
                route.addAction(builderRoute.middleware, responder: builderRoute.responder, methods: builderRoute.methods)
                allRoutes[index] = route
            } else {
                let route = SimpleRoute(m: builderRoute.methods, path: builderRoute.path, middleware: builderRoute.middleware, responder: builderRoute.responder)
                allRoutes.append(route)
            }
        }
        
        // Once all routes are created, store based on route type
        var tempStatic: [String: SimpleRoute] = [:]
        var tempFixed: [SimpleRoute] = []
        var tempWildcard: [SimpleRoute] = []
        
        for route in allRoutes {
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
	
	public func match(request: Request) -> ResponderType? {
		guard let path = request.path else {
			return nil
		}
		
		// Try static routes
		if let route = staticRoutes[path] {
			return MatchType(responder: route, params: nil)
		}
		
		let pathComponents = path.split("/")
		
		// Try fixed length routes
		for route in fixedLengthRoutes {
			if let params = route.matchesFixedLengthPath(pathComponents) {
				return MatchType(responder: route, params: params)
			}
		}
		
		// Try wildcard routes
		for route in wildcardRoutes {
			if let params = route.matchesVariableLengthPath(pathComponents) {
				return MatchType(responder: route, params: params)
			}
		}
		
		return nil
	}
}

public struct MatchType: ResponderType {
	let responder: ResponderType
	let params: [String: String]?
	
	public init(responder: ResponderType, params: [String: String]?) {
		self.responder = responder
		self.params = params
	}
	
	public func respond(request: Request) throws -> Response {
		var request = request
		
		if let params = params {
			for (key, value) in params {
				request.pathParameters[key] = value
			}
		}
		
		return try responder.respond(request)
	}
}
