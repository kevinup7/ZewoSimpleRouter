//MessageExtension.swift
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

extension Method: StringInitializableType {
	public init?(rawValue: String) {
		switch rawValue {
		case "DELETE":
			self = .DELETE
		case "GET":
			self = .GET
		case "HEAD":
			self = .HEAD
		case "POST":
			self = .POST
		case "PUT":
			self = .PUT
		case "CONNECT":
			self = .CONNECT
		case "OPTIONS":
			self = .OPTIONS
		case "TRACE":
			self = .TRACE
		// WebDAV
		case "COPY":
			self = .COPY
		case "LOCK":
			self = .LOCK
		case "MKCOL":
			self = .MKCOL
		case "MOVE":
			self = .MOVE
		case "PROPFIND":
			self = .PROPFIND
		case "PROPPATCH":
			self = .PROPPATCH
		case "SEARCH":
			self = .SEARCH
		case "UNLOCK":
			self = .UNLOCK
		case "BIND":
			self = .BIND
		case "REBIND":
			self = .REBIND
		case "UNBIND":
			self = .UNBIND
		case "ACL":
			self = .ACL
		// Subversion
		case "REPORT":
			self = .REPORT
		case "MKACTIVITY":
			self = .MKACTIVITY
		case "CHECKOUT":
			self = .CHECKOUT
		case "MERGE":
			self = .MERGE
		// UPNP
		case "MSEARCH":
			self = .MSEARCH
		case "NOTIFY":
			self = .NOTIFY
		case "SUBSCRIBE":
			self = .SUBSCRIBE
		case "UNSUBSCRIBE":
			self = .UNSUBSCRIBE
		// RFC-5789
		case "PATCH":
			self = .PATCH
		case "PURGE":
			self = .PURGE
		// CalDAV
		case "MKCALENDAR":
			self = .MKCALENDAR
		// RFC-2068, section 19.6.1.2
		case "LINK":
			self = .LINK
		case "UNLINK":
			self = .UNLINK
		default:
			self = .UNKNOWN
		}
	}
}

extension Method: HeaderValueRepresentableType {
	public var headerValue: String {
		return self.description
	}
}
