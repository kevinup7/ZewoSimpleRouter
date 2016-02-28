//SimpleRouterBuilder.swift
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

public final class SimpleRouterBuilder {
	let basePath: String
	var routes: [SimpleRoute] = []
	
	public var fallback: ResponderType = Responder { _ in
		return Response(status: .NotFound)
	}
	
	init(basePath: String) {
		self.basePath = basePath
	}
}

extension SimpleRouterBuilder {
	public func router(path: String, middleware: MiddlewareType..., router: SimpleRouter) {
		
		let prefix = basePath + path
		let prefixPathComponents = router.matcher.splitPathIntoComponents(prefix)
		
		let newRoutes = router.matcher.allRoutes.map { route in
			return SimpleRoute(
				methods: route.supportedMethods,
				path: prefix + route.path,
				middleware: middleware,
				responder: Responder { request in
					var request = request
					
					guard let path = request.path else {
						return Response(status: .BadRequest)
					}
					
					let requestPathComponents = router.matcher.splitPathIntoComponents(path)
					
					let shortenedRequestPathComponents = requestPathComponents.dropFirst(prefixPathComponents.count)
					
					let shortenedPath = router.matcher.mergePathComponents(Array(shortenedRequestPathComponents))
					
					request.uri.path = shortenedPath
					return try router.respond(request)
				}
			)
		}
		
		routes.appendContentsOf(newRoutes)
	}
}

extension SimpleRouterBuilder {
	public func fallback(middleware middleware: MiddlewareType..., respond: Respond) {
		fallback(middleware, responder: Responder(respond: respond))
	}
	
	public func fallback(middleware middleware: MiddlewareType..., responder: ResponderType) {
		fallback(middleware, responder: responder)
	}
	
	private func fallback(middleware: [MiddlewareType], responder: ResponderType) {
		fallback = middleware.intercept(responder)
	}
}

extension SimpleRouterBuilder {
	public func any(path: String, middleware: MiddlewareType..., respond: Respond) {
		any(path, middleware: middleware, responder: Responder(respond: respond))
	}
	
	public func any(path: String, middleware: MiddlewareType..., responder: ResponderType) {
		any(path, middleware: middleware, responder: responder)
	}
	
	private func any(path: String, middleware: [MiddlewareType], responder: ResponderType) {
		methods(Method.commonMethods, path: path, middleware: middleware, responder: responder)
	}
}

extension SimpleRouterBuilder {
	public func get(path: String, middleware: MiddlewareType..., respond: Respond) {
		get(path, middleware: middleware, responder: Responder(respond: respond))
	}
	
	public func get(path: String, middleware: MiddlewareType..., responder: ResponderType) {
		get(path, middleware: middleware, responder: responder)
	}
	
	private func get(path: String, middleware: [MiddlewareType], responder: ResponderType) {
		methods([.GET], path: path, middleware: middleware, responder: responder)
	}
}

extension SimpleRouterBuilder {
	public func post(path: String, middleware: MiddlewareType..., respond: Respond) {
		post(path, middleware: middleware, responder: Responder(respond: respond))
	}
	
	public func post(path: String, middleware: MiddlewareType..., responder: ResponderType) {
		post(path, middleware: middleware, responder: responder)
	}
	
	private func post(path: String, middleware: [MiddlewareType], responder: ResponderType) {
		methods([.POST], path: path, middleware: middleware, responder: responder)
	}
}

extension SimpleRouterBuilder {
	public func put(path: String, middleware: MiddlewareType..., respond: Respond) {
		put(path, middleware: middleware, responder: Responder(respond: respond))
	}
	
	public func put(path: String, middleware: MiddlewareType..., responder: ResponderType) {
		put(path, middleware: middleware, responder: responder)
	}
	
	private func put(path: String, middleware: [MiddlewareType], responder: ResponderType) {
		methods([.PUT], path: path, middleware: middleware, responder: responder)
	}
}

extension SimpleRouterBuilder {
	public func patch(path: String, middleware: MiddlewareType..., respond: Respond) {
		patch(path, middleware: middleware, responder: Responder(respond: respond))
	}
	
	public func patch(path: String, middleware: MiddlewareType..., responder: ResponderType) {
		patch(path, middleware: middleware, responder: responder)
	}
	
	private func patch(path: String, middleware: [MiddlewareType], responder: ResponderType) {
		methods([.PATCH], path: path, middleware: middleware, responder: responder)
	}
}

extension SimpleRouterBuilder {
	public func delete(path: String, middleware: MiddlewareType..., respond: Respond) {
		delete(path, middleware: middleware, responder: Responder(respond: respond))
	}
	
	public func delete(path: String, middleware: MiddlewareType..., responder: ResponderType) {
		delete(path, middleware: middleware, responder: responder)
	}
	
	private func delete(path: String, middleware: [MiddlewareType], responder: ResponderType) {
		methods([.DELETE], path: path, middleware: middleware, responder: responder)
	}
}

extension SimpleRouterBuilder {
	public func methods(m: Set<Method>, path: String, middleware: MiddlewareType..., respond: Respond) {
		methods(m, path: path, middleware: middleware, responder: Responder(respond: respond))
	}
	
	public func methods(m: Set<Method>, path: String, middleware: MiddlewareType..., responder: ResponderType) {
		methods(m, path: path, middleware: middleware, responder: responder)
	}
	
	private func methods(m: Set<Method>, path: String, middleware: [MiddlewareType], responder: ResponderType) {
		let route = SimpleRoute(
			methods: m,
			path: basePath + path,
			middleware: middleware,
			responder: responder
		)
		
		if let index = routes.indexOf(route) {
			var matchingRoute = routes[index]
			if matchingRoute.exactMatch(route) {
				matchingRoute.addResponder(responder, forMethods: m)
				routes[index] = matchingRoute
			} else {
				preconditionFailure("Route parameter name error: Routes with the same path structure must use identical parameter names (e.g. get '/posts/:id' and put '/posts/:id').")
			}
		} else {
			routes.append(route)
		}
	}
}
