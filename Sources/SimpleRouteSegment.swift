//SimpleRouteSegment.swift
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

public enum SimpleRouteSegment: Equatable {
	case Static(String)
	case Parameter(String)
	case Wildcard
	
	var isStatic: Bool {
		if case .Static = self {
			return true
		}
		return false
	}
	
	var isFixedLength: Bool {
		if case .Wildcard = self {
			return false
		}
		return true
	}
	
	func exactMatch(otherSegment: SimpleRouteSegment) -> Bool {
		switch (self, otherSegment) {
		case (.Static(let lhsPath), .Static(let rhsPath)):
			return lhsPath == rhsPath
		case (.Parameter(let lhsPath), .Parameter(let rhsPath)):
			return lhsPath == rhsPath
		case (.Wildcard, .Wildcard):
			return true
		default:
			return false
		}
	}
}

extension SimpleRouteSegment: CustomStringConvertible {
	public var description: String {
		switch self {
		case .Static(let string):
			return string
		case .Parameter(let string):
			return ":" + string
		case .Wildcard:
			return "*"
		}
	}
}

public func ==(lhs: SimpleRouteSegment, rhs: SimpleRouteSegment) -> Bool {
	switch (lhs, rhs) {
	case (.Static(let lhsPath), .Static(let rhsPath)):
		return lhsPath == rhsPath
	case (.Parameter(_), .Parameter(_)):
		return true
	case (.Wildcard, .Wildcard):
		return true
	default:
		return false
	}
}
