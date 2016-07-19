// Copyright (c) 2014 Nikolaj Schumacher
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CoreGraphics

// MARK: CGPoint

extension CGPoint {

    /// Creates a point with unnamed arguments.
    public init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }

    /// Returns a copy with the x value changed.
    public func with(x: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }

    /// Returns a copy with the y value changed.
    public func with(y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }

    /// Returns the distance between the receiver and the passed point
    public func distance(fromPoint b: CGPoint) -> CGFloat {
        let a = self
        return sqrt(pow(a.x-b.x, 2)+pow(a.y-b.y, 2))
    }
}

// MARK: CGSize

extension CGSize {

    /// Creates a size with unnamed arguments.
    public init(_ width: CGFloat, _ height: CGFloat) {
        self.width = width
        self.height = height
    }

    /// Returns a copy with the width value changed.
    public func with(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
    /// Returns a copy with the height value changed.
    public func with(height: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
}

// MARK: CGRect

extension CGRect {

    /// Creates a rect with unnamed arguments.
    public init(_ origin: CGPoint, _ size: CGSize) {
        self.origin = origin
        self.size = size
    }

    /// Creates a rect with unnamed arguments.
    public init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        origin = CGPoint(x: x, y: y)
        size = CGSize(width: width, height: height)
    }

    /// Creates a rect with two points, instead of an origin and a size
    public init(p1: CGPoint, p2: CGPoint) {
        origin = CGPoint(x: min(p1.x, p2.x), y: min(p1.y, p2.y))
        size = CGSize(width: abs(p1.x - p2.x), height: abs(p1.y - p2.y))
    }

    // MARK: access shortcuts

    /// Alias for origin.x.
    public var x: CGFloat {
        get {return origin.x}
        set {origin.x = newValue}
    }
    /// Alias for origin.y.
    public var y: CGFloat {
        get {return origin.y}
        set {origin.y = newValue}
    }

    /// Accesses origin.x + 0.5 * size.width.
    public var centerX: CGFloat {
        get {return x + width * 0.5}
        set {x = newValue - width * 0.5}
    }
    /// Accesses origin.y + 0.5 * size.height.
    public var centerY: CGFloat {
        get {return y + height * 0.5}
        set {y = newValue - height * 0.5}
    }

    // MARK: edges

    /// Alias for origin.x.
    public var left: CGFloat {
        get {return origin.x}
        set {origin.x = newValue}
    }
    /// Accesses origin.x + size.width.
    public var right: CGFloat {
        get {return x + width}
        set {x = newValue - width}
    }

    #if os(iOS)
    /// Alias for origin.y.
    public var top: CGFloat {
        get {return y}
        set {y = newValue}
    }
    /// Accesses origin.y + size.height.
    public var bottom: CGFloat {
        get {return y + height}
        set {y = newValue - height}
    }
    #else
    /// Accesses origin.y + size.height.
    public var top: CGFloat {
    get {return y + height}
    set {y = newValue - height}
    }
    /// Alias for origin.y.
    public var bottom: CGFloat {
    get {return y}
    set {y = newValue}
    }
    #endif

    // MARK: points

    /// Accesses the point at the top left corner.
    public var topLeft: CGPoint {
        get {return CGPoint(x: left, y: top)}
        set {left = newValue.x; top = newValue.y}
    }
    /// Accesses the point at the middle of the top edge.
    public var topCenter: CGPoint {
        get {return CGPoint(x: centerX, y: top)}
        set {centerX = newValue.x; top = newValue.y}
    }
    /// Accesses the point at the top right corner.
    public var topRight: CGPoint {
        get {return CGPoint(x: right, y: top)}
        set {right = newValue.x; top = newValue.y}
    }

    /// Accesses the point at the middle of the left edge.
    public var centerLeft: CGPoint {
        get {return CGPoint(x: left, y: centerY)}
        set {left = newValue.x; centerY = newValue.y}
    }
    /// Accesses the point at the center.
    public var center: CGPoint {
        get {return CGPoint(x: centerX, y: centerY)}
        set {centerX = newValue.x; centerY = newValue.y}
    }
    /// Accesses the point at the middle of the right edge.
    public var centerRight: CGPoint {
        get {return CGPoint(x: right, y: centerY)}
        set {right = newValue.x; centerY = newValue.y}
    }

    /// Accesses the point at the bottom left corner.
    public var bottomLeft: CGPoint {
        get {return CGPoint(x: left, y: bottom)}
        set {left = newValue.x; bottom = newValue.y}
    }
    /// Accesses the point at the middle of the bottom edge.
    public var bottomCenter: CGPoint {
        get {return CGPoint(x: centerX, y: bottom)}
        set {centerX = newValue.x; bottom = newValue.y}
    }
    /// Accesses the point at the bottom right corner.
    public var bottomRight: CGPoint {
        get {return CGPoint(x: right, y: bottom)}
        set {right = newValue.x; bottom = newValue.y}
    }

    // MARK: with

    /// Returns a copy with the origin value changed.
    public func with(origin: CGPoint) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    /// Returns a copy with the x and y values changed.
    public func with(x: CGFloat, y: CGFloat) -> CGRect {
        return with(origin: CGPoint(x: x, y: y))
    }
    /// Returns a copy with the x value changed.
    public func with(x: CGFloat) -> CGRect {
        return with(x: x, y: y)
    }
    /// Returns a copy with the y value changed.
    public func with(y: CGFloat) -> CGRect {
        return with(x: x, y: y)
    }

    /// Returns a copy with the size value changed.
    public func with(size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    /// Returns a copy with the width and height values changed.
    public func with(width: CGFloat, height: CGFloat) -> CGRect {
        return with(size: CGSize(width: width, height: height))
    }
    /// Returns a copy with the width value changed.
    public func with(width: CGFloat) -> CGRect {
        return with(width: width, height: height)
    }
    /// Returns a copy with the height value changed.
    public func with(height: CGFloat) -> CGRect {
        return with(width: width, height: height)
    }

    /// Returns a copy with the x and width values changed.
    public func with(x: CGFloat, width: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }
    /// Returns a copy with the y and height values changed.
    public func with(y: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }

    // MARK: offset

    /// Returns a copy with the x and y values offset.
    public func rectByOffsetting(dx: CGFloat, _ dy: CGFloat) -> CGRect {
        return with(x: x + dx, y: y + dy)
    }
    /// Returns a copy with the x value values offset.
    public func rectByOffsetting(dx: CGFloat) -> CGRect {
        return with(x: x + dx)
    }
    /// Returns a copy with the y value values offset.
    public func rectByOffsetting(dy: CGFloat) -> CGRect {
        return with(y: y + dy)
    }
    /// Returns a copy with the x and y values offset.
    public func rectByOffsetting(by: CGSize) -> CGRect {
        return with(x: x + by.width, y: y + by.height)
    }

    /// Modifies the x and y values by offsetting.
    public mutating func offset(dx: CGFloat, _ dy: CGFloat) {
        offsetInPlace(dx: dx, dy: dy)
    }
    /// Modifies the x value values by offsetting.
    public mutating func offset(dx: CGFloat = 0) {
        x += dx
    }
    /// Modifies the y value values by offsetting.
    public mutating func offset(dy: CGFloat = 0) {
        y += dy
    }
    /// Modifies the x and y values by offsetting.
    public mutating func offset(by: CGSize) {
        offsetInPlace(dx: by.width, dy: by.height)
    }

    // MARK: sizes

    /// Returns a rect of the specified size centered in this rect.
    public func rectByCentering(_ size: CGSize) -> CGRect {
        let dx = width - size.width
        let dy = height - size.height
        return CGRect(x: x + dx * 0.5, y: y + dy * 0.5, width: size.width, height: size.height)
    }

    /// Returns a rect of the specified size centered in this rect touching the specified edge.
    public func rectByCentering(_ size: CGSize, alignTo edge: CGRectEdge) -> CGRect {
        return CGRect(origin: alignedOrigin(size, edge: edge), size: size)
    }

    private func alignedOrigin(_ size: CGSize, edge: CGRectEdge) -> CGPoint {
        let dx = width - size.width
        let dy = height - size.height
        switch edge {
        case .minXEdge:
            return CGPoint(x: x, y: y + dy * 0.5)
        case .minYEdge:
            return CGPoint(x: x + dx * 0.5, y: y)
        case .maxXEdge:
            return CGPoint(x: x + dx, y: y + dy * 0.5)
        case .maxYEdge:
            return CGPoint(x: x + dx * 0.5, y: y + dy)
        }
    }

    /// Returns a rect of the specified size centered in this rect touching the specified corner.
    public func rectByAligning(_ size: CGSize, corner e1: CGRectEdge, _ e2: CGRectEdge) -> CGRect {
        return CGRect(origin: alignedOrigin(size, corner: e1, e2), size: size)
    }

    private func alignedOrigin(_ size: CGSize, corner e1: CGRectEdge, _ e2: CGRectEdge) -> CGPoint {
        let dx = width - size.width
        let dy = height - size.height
        switch (e1, e2) {
        case (.minXEdge, .minYEdge), (.minYEdge, .minXEdge):
            return CGPoint(x: x, y: y)
        case (.maxXEdge, .minYEdge), (.minYEdge, .maxXEdge):
            return CGPoint(x: x + dx, y: y)
        case (.minXEdge, .maxYEdge), (.maxYEdge, .minXEdge):
            return CGPoint(x: x, y: y + dy)
        case (.maxXEdge, .maxYEdge), (.maxYEdge, .maxXEdge):
            return CGPoint(x: x + dx, y: y + dy)
        default:
            preconditionFailure("Cannot align to this combination of edges")
        }
    }

    /// Modifies all values by setting the size while centering the rect.
    public mutating func setSizeCentered(size: CGSize) {
        self = rectByCentering(size)
    }

    /// Modifies all values by setting the size while centering the rect touching the specified edge.
    public mutating func setSizeCentered(size: CGSize, alignTo edge: CGRectEdge) {
        self = rectByCentering(size, alignTo: edge)
    }

    /// Modifies all values by setting the size while centering the rect touching the specified corner.
    public mutating func setSizeAligned(size: CGSize, corner e1: CGRectEdge, _ e2: CGRectEdge) {
        self = rectByAligning(size, corner: e1, e2)
    }
}

// MARK: transform

extension CGAffineTransform: Equatable {
}

public func == (t1: CGAffineTransform, t2: CGAffineTransform) -> Bool {
    return t1.equalTo(t2)
}

extension CGAffineTransform: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "(\(a),\(b),\(c),\(d),\(tx),\(ty))"
    }
}

// MARK: operators

/// Returns a point by adding the coordinates of another point.
public func + (p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
}
/// Modifies the x and y values by adding the coordinates of another point.
public func += (p1: CGPoint, p2: CGPoint) {
    var p1 = p1
    p1.x += p2.x
    p1.y += p2.y
}
/// Returns a point by subtracting the coordinates of another point.
public func - (p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
}
/// Modifies the x and y values by subtracting the coordinates of another points.
public func -= (p1: CGPoint, p2: CGPoint) {
    var p1 = p1
    p1.x -= p2.x
    p1.y -= p2.y
}

/// Returns a point by adding a size to the coordinates.
public func + (point: CGPoint, size: CGSize) -> CGPoint {
    return CGPoint(x: point.x + size.width, y: point.y + size.height)
}
/// Modifies the x and y values by adding a size to the coordinates.
public func += (point: CGPoint, size: CGSize) {
    var point = point
    point.x += size.width
    point.y += size.height
}
/// Returns a point by subtracting a size from the coordinates.
public func - (point: CGPoint, size: CGSize) -> CGPoint {
    return CGPoint(x: point.x - size.width, y: point.y - size.height)
}
/// Modifies the x and y values by subtracting a size from the coordinates.
public func -= (point: CGPoint, size: CGSize) {
    var point = point
    point.x -= size.width
    point.y -= size.height
}

/// Returns a point by adding a tuple to the coordinates.
public func + (point: CGPoint, tuple: (CGFloat, CGFloat)) -> CGPoint {
    return CGPoint(x: point.x + tuple.0, y: point.y + tuple.1)
}
/// Modifies the x and y values by adding a tuple to the coordinates.
public func += (point: CGPoint, tuple: (CGFloat, CGFloat)) {
    var point = point
    point.x += tuple.0
    point.y += tuple.1
}
/// Returns a point by subtracting a tuple from the coordinates.
public func - (point: CGPoint, tuple: (CGFloat, CGFloat)) -> CGPoint {
    return CGPoint(x: point.x - tuple.0, y: point.y - tuple.1)
}
/// Modifies the x and y values by subtracting a tuple from the coordinates.
public func -= (point: CGPoint, tuple: (CGFloat, CGFloat)) {
    var point = point
    point.x -= tuple.0
    point.y -= tuple.1
}
/// Returns a point by multiplying the coordinates with a value.
public func * (point: CGPoint, factor: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * factor, y: point.y * factor)
}
/// Modifies the x and y values by multiplying the coordinates with a value.
public func *= (point: CGPoint, factor: CGFloat) {
    var point = point
    point.x *= factor
    point.y *= factor
}
/// Returns a point by multiplying the coordinates with a tuple.
public func * (point: CGPoint, tuple: (CGFloat, CGFloat)) -> CGPoint {
    return CGPoint(x: point.x * tuple.0, y: point.y * tuple.1)
}
/// Modifies the x and y values by multiplying the coordinates with a tuple.
public func *= (point: CGPoint, tuple: (CGFloat, CGFloat)) {
    var point = point
    point.x *= tuple.0
    point.y *= tuple.1
}
/// Returns a point by dividing the coordinates by a tuple.
public func / (point: CGPoint, tuple: (CGFloat, CGFloat)) -> CGPoint {
    return CGPoint(x: point.x / tuple.0, y: point.y / tuple.1)
}
/// Modifies the x and y values by dividing the coordinates by a tuple.
public func /= (point: CGPoint, tuple: (CGFloat, CGFloat)) {
    var point = point
    point.x /= tuple.0
    point.y /= tuple.1
}
/// Returns a point by dividing the coordinates by a factor.
public func / (point: CGPoint, factor: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / factor, y: point.y / factor)
}
/// Modifies the x and y values by dividing the coordinates by a factor.
public func /= (point: CGPoint, factor: CGFloat) {
    var point = point
    point.x /= factor
    point.y /= factor
}

/// Returns a point by adding another size.
public func + (s1: CGSize, s2: CGSize) -> CGSize {
    return CGSize(width: s1.width + s2.width, height: s1.height + s2.height)
}
/// Modifies the width and height values by adding another size.
public func += (s1: CGSize, s2: CGSize) {
    var s1 = s1
    s1.width += s2.width
    s1.height += s2.height
}
/// Returns a point by subtracting another size.
public func - (s1: CGSize, s2: CGSize) -> CGSize {
    return CGSize(width: s1.width - s2.width, height: s1.height - s2.height)
}
/// Modifies the width and height values by subtracting another size.
public func -= (s1: CGSize, s2: CGSize) {
    var s1 = s1
    s1.width -= s2.width
    s1.height -= s2.height
}

/// Returns a point by adding a tuple.
public func + (size: CGSize, tuple: (CGFloat, CGFloat)) -> CGSize {
    return CGSize(width: size.width + tuple.0, height: size.height + tuple.1)
}
/// Modifies the width and height values by adding a tuple.
public func += (size: CGSize, tuple: (CGFloat, CGFloat)) {
    var size = size
    size.width += tuple.0
    size.height += tuple.1
}
/// Returns a point by subtracting a tuple.
public func - (size: CGSize, tuple: (CGFloat, CGFloat)) -> CGSize {
    return CGSize(width: size.width - tuple.0, height: size.height - tuple.1)
}
/// Modifies the width and height values by subtracting a tuple.
public func -= (size: CGSize, tuple: (CGFloat, CGFloat)) {
    var size = size
    size.width -= tuple.0
    size.height -= tuple.1
}
/// Returns a point by multiplying the size with a factor.
public func * (size: CGSize, factor: CGFloat) -> CGSize {
    return CGSize(width: size.width * factor, height: size.height * factor)
}
/// Modifies the width and height values by multiplying them with a factor.
public func *= (size: CGSize, factor: CGFloat) {
    var size = size
    size.width *= factor
    size.height *= factor
}
/// Returns a point by multiplying the size with a tuple.
public func * (size: CGSize, tuple: (CGFloat, CGFloat)) -> CGSize {
    return CGSize(width: size.width * tuple.0, height: size.height * tuple.1)
}
/// Modifies the width and height values by multiplying them with a tuple.
public func *= (size: CGSize, tuple: (CGFloat, CGFloat)) {
    var size = size
    size.width *= tuple.0
    size.height *= tuple.1
}
/// Returns a point by dividing the size by a factor.
public func / (size: CGSize, factor: CGFloat) -> CGSize {
    return CGSize(width: size.width / factor, height: size.height / factor)
}
/// Modifies the width and height values by dividing them by a factor.
public func /= (size: CGSize, factor: CGFloat) {
    var size = size
    size.width /= factor
    size.height /= factor
}
/// Returns a point by dividing the size by a tuple.
public func / (size: CGSize, tuple: (CGFloat, CGFloat)) -> CGSize {
    return CGSize(width: size.width / tuple.0, height: size.height / tuple.1)
}
/// Modifies the width and height values by dividing them by a tuple.
public func /= (size: CGSize, tuple: (CGFloat, CGFloat)) {
    var size = size
    size.width /= tuple.0
    size.height /= tuple.1
}

/// Returns a rect by adding the coordinates of a point to the origin.
public func + (rect: CGRect, point: CGPoint) -> CGRect {
    return CGRect(origin: rect.origin + point, size: rect.size)
}
/// Modifies the x and y values by adding the coordinates of a point.
public func += (rect: CGRect, point: CGPoint) {
    let rect = rect
    rect.origin += point
}
/// Returns a rect by subtracting the coordinates of a point from the origin.
public func - (rect: CGRect, point: CGPoint) -> CGRect {
    return CGRect(origin: rect.origin - point, size: rect.size)
}
/// Modifies the x and y values by subtracting the coordinates from a point.
public func -= (rect: CGRect, point: CGPoint) {
    let rect = rect
    rect.origin -= point
}

/// Returns a rect by adding a size to the size.
public func + (rect: CGRect, size: CGSize) -> CGRect {
    return CGRect(origin: rect.origin, size: rect.size + size)
}
/// Modifies the width and height values by adding a size.
public func += (rect: CGRect, size: CGSize) {
    let rect = rect
    rect.size += size
}
/// Returns a rect by subtracting a size from the size.
public func - (rect: CGRect, size: CGSize) -> CGRect {
    return CGRect(origin: rect.origin, size: rect.size - size)
}
/// Modifies the width and height values by subtracting a size.
public func -= (rect: CGRect, size: CGSize) {
    let rect = rect
    rect.size -= size
}

/// Returns a point by applying a transform.
public func * (point: CGPoint, transform: CGAffineTransform) -> CGPoint {
    return point.apply(transform: transform)
}
/// Modifies all values by applying a transform.
public func *= (point: CGPoint, transform: CGAffineTransform) {
    var point = point
    point = point.apply(transform: transform)
}
/// Returns a size by applying a transform.
public func * (size: CGSize, transform: CGAffineTransform) -> CGSize {
    return size.apply(transform: transform)
}
/// Modifies all values by applying a transform.
public func *= (size: CGSize, transform: CGAffineTransform) {
    var size = size
    size = size.apply(transform: transform)
}
/// Returns a rect by applying a transform.
public func * (rect: CGRect, transform: CGAffineTransform) -> CGRect {
    return rect.apply(transform: transform)
}
/// Modifies all values by applying a transform.
public func *= (rect: CGRect, transform: CGAffineTransform) {
    var rect = rect
    rect = rect.apply(transform: transform)
}

/// Returns a transform by concatenating two transforms.
public func * (t1: CGAffineTransform, t2: CGAffineTransform) -> CGAffineTransform {
    return t1.concat(t2)
}
/// Modifies all values by concatenating another transform.
public func *= (t1: CGAffineTransform, t2: CGAffineTransform) {
    var t1 = t1
    t1 = t1.concat(t2)
}
