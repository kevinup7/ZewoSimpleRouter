//Allow.swift
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

extension MessageType {
	
	/**
		The `Allow` header field lists the set of methods advertised as
		supported by the target resource.  The purpose of this field is
		strictly to inform the recipient of valid request methods associated
		with the resource.
		
		The actual set of allowed methods is defined by the origin server at
		the time of each request.  An origin server MUST generate an `Allow`
		field in a `405 (Method Not Allowed)` response and MAY do so in any
		other response.  An empty Allow field value indicates that the
		resource allows no methods, which might occur in a 405 response if
		the resource has been temporarily disabled by configuration.
		
		## Example Headers
		`Allow: GET, HEAD, PUT`
		
		`Allow: GET`
		
		
		## Examples
			var response =  Response(status: .MethodNotAllowed)
			response.allow = [.GET, .HEAD, .PUT]
		
			var response =  Response(status: .MethodNotAllowed)
			response.allow = [.GET]
		
		- seealso: [RFC7231](https://tools.ietf.org/html/rfc7231#section-7.4.1)
	*/
	public var allow: Set<Method>? {
		get {
			if let rawValue = headers["Allow"] {
				if let methodArray = Method.arrayFromHeaderString(rawValue) {
					return Set<Method>(methodArray)
				}
				return nil
			}
			return nil
		}
		set {
			headers["Allow"] = newValue?.headerValue
		}
	}
}
