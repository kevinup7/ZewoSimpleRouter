//HeaderProtocols.swift
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

public protocol StringInitializableType {
	init?(rawValue: String)
}

extension StringInitializableType {
	static func arrayFromHeaderString(headerString: String) -> [Self]? {
		var values: [Self] = []
		
		let valueStrings = headerString.split(",")
		for valueString in valueStrings {
			let trimmed = valueString.trim()
			if let value = Self.init(rawValue: trimmed) {
				values.append(value)
			}
		}
		
		if values.count > 0 {
			return values
		}
		return nil
	}
}


public protocol HeaderValueRepresentableType {
	var headerValue: String { get }
}

extension SequenceType where Generator.Element: HeaderValueRepresentableType {
	var headerValue: String {
		let valueStrings = self.map({ $0.headerValue })
		return valueStrings.joinWithSeparator(", ")
	}
}

public typealias HeaderType = protocol<StringInitializableType, HeaderValueRepresentableType>
