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

public struct SimpleRouter: ResponderType {
	public let middleware: [MiddlewareType]
	public let matcher: SimpleRouteMatcher
	public let fallback: ResponderType
	
	public init(_ basePath: String = "", middleware: MiddlewareType..., build: (route: SimpleRouterBuilder) -> Void) {
		let builder = SimpleRouterBuilder(basePath: basePath)
		build(route: builder)
		self.middleware = middleware
		self.matcher = SimpleRouteMatcher(routes: builder.routes)
		self.fallback = builder.fallback
	}
	
	public func respond(request: Request) throws -> Response {
		if let (route, params) = matcher.match(request) {
			if let responder = route.responders[request.method] {
				var request = request
				
				if let params = params {
					for (key, value) in params {
						request.pathParameters[key] = value
					}
				}
				
				return try middleware.intercept(responder).respond(request)
			} else {
				var response = Response(status: .MethodNotAllowed)
				response.allow = route.supportedMethods
				return response
			}
			
		} else {
			return try middleware.intercept(fallback).respond(request)
		}
	}
}
