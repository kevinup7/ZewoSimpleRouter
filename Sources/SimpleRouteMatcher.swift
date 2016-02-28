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

public struct SimpleRouteMatcher {
	let allRoutes: [SimpleRoute]
	
	let staticRoutes: [SimpleRoute]
	let fixedLengthRoutes: [SimpleRoute]
	let wildcardRoutes: [SimpleRoute]
	
	
	public init(routes: [SimpleRoute]) {
		var tempStatic: [SimpleRoute] = []
		var tempFixed: [SimpleRoute] = []
		var tempWildcard: [SimpleRoute] = []
		
		for route in routes {
			if route.staticPath {
				tempStatic.append(route)
			} else if route.fixedLength {
				tempFixed.append(route)
			} else {
				tempWildcard.append(route)
			}
		}
		
		self.staticRoutes = tempStatic
		self.fixedLengthRoutes = tempFixed
		self.wildcardRoutes = tempWildcard
		self.allRoutes = routes
	}
	
	public func match(request: Request) -> (SimpleRoute, [String: String]?)? {
		guard let path = request.path else {
			return nil
		}
		
		// Try static routes
		for route in staticRoutes {
			if route.matchesStaticPath(path) {
				return (route, nil)
			}
		}
		
		let pathComponents = path.split("/")
		
		// Try fixed length routes
		for route in fixedLengthRoutes {
			if let params = route.matchesFixedLengthPath(pathComponents) {
				return (route, params)
			}
		}
		
		// Try wildcard routes
		for route in wildcardRoutes {
			if let params = route.matchesVariableLengthPath(pathComponents) {
				return (route, params)
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
