//
//  FetchResponseProxy.swift
//  ServiceWorker
//
//  Created by alastair.coote on 21/07/2017.
//  Copyright © 2017 Guardian Mobile Innovation Lab. All rights reserved.
//

import Foundation
import JavaScriptCore
import PromiseKit

@objc class FetchResponseProxy: NSObject, FetchResponseProtocol, FetchResponseJSExports {

    var url: URL {
        return self._internal.url
    }

    var responseType: ResponseType {
        return .Internal
    }

    func getReader() throws -> ReadableStream {
        return try self._internal.getReader()
    }

    let _internal: FetchResponse

    init(from response: FetchResponse) throws {
        self._internal = response
    }

    var internalResponse: FetchResponse {
        return self._internal
    }

    func data() -> Promise<Data> {
        return self._internal.data()
    }

    func json() -> Promise<Any?> {
        return self._internal.json()
    }

    func json() -> JSValue? {
        return self._internal.json()
    }

    func text() -> JSValue? {
        return self._internal.text()
    }

    func text() -> Promise<String> {
        return self._internal.text()
    }

    func arrayBuffer() -> JSValue? {
        return self._internal.arrayBuffer()
    }

    func cloneInternalResponse() throws -> FetchResponse {
        return try FetchResponse(headers: self._internal.headers, status: self._internal.status, url: self._internal.url, redirected: self._internal.redirected, fetchOperation: self._internal.fetchOperation)
    }

    func clone() throws -> FetchResponseProtocol {

        if self.bodyUsed {
            throw ErrorMessage("Cannot clone response: body already used")
        }

        let clonedInternalResponse = try cloneInternalResponse()

        if self.responseType == .Basic {
            return try BasicResponse(from: clonedInternalResponse)
        } else if self.responseType == .Opaque {
            return try OpaqueResponse(from: clonedInternalResponse)
        } else {
            // CORS overrides this, so that we can handle allowed headers
            throw ErrorMessage("Do not know how to clone this type of response")
        }
    }

    func cloneResponseExports() -> FetchResponseJSExports? {
        // Really dumb but I can't figure out a better way to export both
        // clone() for Swift and clone() for JS

        var clone: FetchResponseJSExports?

        do {
            clone = try self.clone()
        } catch {

            var errmsg = String(describing: error)
            if let err = error as? ErrorMessage {
                errmsg = err.message
            }

            JSContext.current().exception = JSValue(newErrorFromMessage: errmsg, in: JSContext.current())
        }

        return clone
    }

    var headers: FetchHeaders {
        return self._internal.headers
    }

    var statusText: String {
        return self._internal.statusText
    }

    var ok: Bool {
        return self._internal.ok
    }

    var redirected: Bool {
        return self._internal.redirected
    }

    var bodyUsed: Bool {
        return self._internal.bodyUsed
    }

    var status: Int {
        return self._internal.status
    }

    var responseTypeString: String {
        return self.responseType.rawValue
    }

    var urlString: String {
        return self.url.absoluteString
    }
}
