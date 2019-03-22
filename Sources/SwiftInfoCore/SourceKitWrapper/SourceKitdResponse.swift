////===--------------------- SourceKitdResponse.swift -----------------------===//
////
//// This source file is part of the Swift.org open source project
////
//// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
//// Licensed under Apache License v2.0 with Runtime Library Exception
////
//// See https://swift.org/LICENSE.txt for license information
//// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
////
////===----------------------------------------------------------------------===//
//// This file provides convenient APIs to interpret a SourceKitd response.
////===----------------------------------------------------------------------===//
//
//import sourcekitd
//
//public class SourceKitdResponse: CustomStringConvertible {
//
//    public struct Dictionary: CustomStringConvertible, CustomReflectable {
//        // The lifetime of this sourcekitd_variant_t is tied to the response it came
//        // from, so keep a reference to the response too.
//        private let dict: sourcekitd_variant_t
//        private let context: SourceKitdResponse
//
//
//        public init(dict: sourcekitd_variant_t, context: SourceKitdResponse) {
//            assert(SourceKit.api.variant_get_type(dict).rawValue ==
//                SOURCEKITD_VARIANT_TYPE_DICTIONARY.rawValue)
//            self.dict = dict
//            self.context = context
//        }
//
//        public func getString(_ key: SourceKitdUID) -> String? {
//            guard let value = SourceKit.api.variant_dictionary_get_string(dict, key.uid) else {
//                return nil
//            }
//            return String(cString: value)
//        }
//
//        public func getInt(_ key: SourceKitdUID) -> Int {
//            let value = SourceKit.api.variant_dictionary_get_int64(dict, key.uid)
//            return Int(value)
//        }
//
//        public func getBool(_ key: SourceKitdUID) -> Bool {
//            let value = SourceKit.api.variant_dictionary_get_bool(dict, key.uid)
//            return value
//        }
//
//        public func getUID(_ key: SourceKitdUID) -> SourceKitdUID {
//            let value = SourceKit.api.variant_dictionary_get_uid(dict, key.uid)!
//            return SourceKitdUID(uid: value)
//        }
//
//        public func getArray(_ key: SourceKitdUID) -> Array {
//            let value = SourceKit.api.variant_dictionary_get_value(dict, key.uid)
//            return Array(arr: value, context: context)
//        }
//
//        public func getDictionary(_ key: SourceKitdUID) -> Dictionary {
//            let value = SourceKit.api.variant_dictionary_get_value(dict, key.uid)
//            return Dictionary(dict: value, context: context)
//        }
//
//        public func getOptional(_ key: SourceKitdUID) -> Variant? {
//            let value = SourceKit.api.variant_dictionary_get_value(dict, key.uid)
//            if SourceKit.api.variant_get_type(value).rawValue ==
//                SOURCEKITD_VARIANT_TYPE_NULL.rawValue {
//                return nil
//            }
//            return Variant(val: value, context: context)
//        }
//
//        public var description: String {
//            return dict.description
//        }
//
//        public var customMirror: Mirror {
//            return Mirror(self, children: [:])
//        }
//    }
//
//    public struct Array: CustomStringConvertible {
//        // The lifetime of this sourcekitd_variant_t is tied to the response it came
//        // from, so keep a reference to the response too.
//        private let arr: sourcekitd_variant_t
//        private let context: SourceKitdResponse
//
//        public var count: Int {
//            let count = SourceKit.api.variant_array_get_count(arr)
//            return Int(count)
//        }
//
//        public init(arr: sourcekitd_variant_t, context: SourceKitdResponse) {
//            assert(SourceKit.api.variant_get_type(arr).rawValue ==
//                SOURCEKITD_VARIANT_TYPE_ARRAY.rawValue)
//            self.arr = arr
//            self.context = context
//        }
//
//        public func getString(_ index: Int) -> String {
//            let value = SourceKit.api.variant_array_get_string(arr, index)!
//            return String(cString: value)
//        }
//
//        public func getInt(_ index: Int) -> Int {
//            let value = SourceKit.api.variant_array_get_int64(arr, index)
//            return Int(value)
//        }
//
//        public func getBool(_ index: Int) -> Bool {
//            let value = SourceKit.api.variant_array_get_bool(arr, index)
//            return value
//        }
//
//        public func getArray(_ index: Int) -> Array {
//            let value = SourceKit.api.variant_array_get_value(arr, index)
//            return Array(arr: value, context: context)
//        }
//
//        public func getDictionary(_ index: Int) -> Dictionary {
//            let value = SourceKit.api.variant_array_get_value(arr, index)
//            return Dictionary(dict: value, context: context)
//        }
//
//        public func enumerate(_ applier: (_ index: Int, _ value: Variant) -> Bool) {
////            // The block passed to sourcekit_variant_array_apply() does not actually
////            // escape, it's synchronous and not called after returning.
////            let context = self.context
////            withoutActuallyEscaping(applier) { escapingApplier in
////                _ = SourceKit.api.variant_array_apply(arr) { (index, elem) -> Bool in
////                    return escapingApplier(Int(index), Variant(val: elem, context: context))
////                }
////            }
//        }
//
//        public var description: String {
//            return arr.description
//        }
//
//    }
//
//    public struct Variant: CustomStringConvertible {
//        // The lifetime of this sourcekitd_variant_t is tied to the response it came
//        // from, so keep a reference to the response too.
//        let val: sourcekitd_variant_t
//        fileprivate let context: SourceKitdResponse
//
//        fileprivate init(val: sourcekitd_variant_t, context: SourceKitdResponse) {
//            self.val = val
//            self.context = context
//        }
//
//        public func getString() -> String {
//            let value = SourceKit.api.variant_string_get_ptr(val)!
//            let length = SourceKit.api.variant_string_get_length(val)
//            return fromCStringLen(value, length: length)!
//        }
//
//        public func getStringBuffer() -> UnsafeBufferPointer<Int8> {
//            return UnsafeBufferPointer(start: SourceKit.api.variant_string_get_ptr(val),
//                                       count: SourceKit.api.variant_string_get_length(val))
//        }
//
//        public func getInt() -> Int {
//            let value = SourceKit.api.variant_int64_get_value(val)
//            return Int(value)
//        }
//
//        public func getBool() -> Bool {
//            let value = SourceKit.api.variant_bool_get_value(val)
//            return value
//        }
//
//        public func getArray() -> Array {
//            return Array(arr: val, context: context)
//        }
//
//        public func getDictionary() -> Dictionary {
//            return Dictionary(dict: val, context: context)
//        }
//
//        public var description: String {
//            return val.description
//        }
//
//        public func recurseOver(uid: SourceKitdUID, block: @escaping (Variant) -> ()) {
////            let children = SourceKit.api.variant_dictionary_get_value(val, uid.uid)
////            guard SourceKit.api.variant_get_type(children) == SOURCEKITD_VARIANT_TYPE_ARRAY else {
////                return
////            }
////            _ = SourceKit.api.variant_array_apply(children) { (_, val) in
////                let variant = Variant(val: val, context: self.context)
////                block(variant)
////                variant.recurseOver(uid: uid, block: block)
////                return true
////            }
//        }
//    }
//
//    let resp: sourcekitd_response_t
//
//    public var value: Dictionary {
//        return Dictionary(dict: SourceKit.api.response_get_value(resp), context: self)
//    }
//
//    public var variant: Variant {
//        let val = SourceKit.api.response_get_value(resp)
//        return Variant(val: val, context: self)
//    }
//
//    public var error: String? {
//        if SourceKit.api.response_is_error(resp) {
//            return String(cString: SourceKit.api.response_error_get_description(resp)!)
//        }
//        return nil
//    }
//
//    /// Whether or not this response represents a connection interruption error.
//    public var isConnectionInterruptionError: Bool {
//        return SourceKit.api.response_is_error(resp) &&
//            SourceKit.api.response_error_get_kind(resp) ==
//        SOURCEKITD_ERROR_CONNECTION_INTERRUPTED
//    }
//
//    public init(resp: sourcekitd_response_t) {
//        self.resp = resp
//    }
//
//    deinit {
//        SourceKit.api.response_dispose(resp)
//    }
//
//    public var description: String {
//        let utf8Str = SourceKit.api.response_description_copy(resp)!
//        let result = String(cString: utf8Str)
//        free(utf8Str)
//        return result
//    }
//
//    func recurseOver(uid: SourceKitdUID, block: @escaping (Variant) -> ()) {
//        variant.recurseOver(uid: uid, block: block)
//    }
//}
//
//private func fromCStringLen(_ ptr: UnsafePointer<Int8>, length: Int) -> String? {
//    return String(decoding: Array(UnsafeBufferPointer(start: ptr, count: length)).map {
//        UInt8(bitPattern: $0) }, as: UTF8.self)
//}
//
//extension sourcekitd_variant_t: CustomStringConvertible {
//    public var description: String {
//        let utf8Str = SourceKit.api.variant_description_copy(self)!
//        let result = String(cString: utf8Str)
//        free(utf8Str)
//        return result
//    }
//}
