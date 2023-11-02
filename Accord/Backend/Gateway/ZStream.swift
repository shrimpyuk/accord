//
//  ZStream.swift
//  Accord
//
//  Created by evelyn on 2022-04-13.
//

import Compression
import Foundation

final class ZStream {
    let streamPtr = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
    var stream: compression_stream
    var status: compression_status
    let decompressionQueue = DispatchQueue(label: "red.evelyn.accord.DecompressionQueue")
    private static let ZLIB_SUFFIX = Data([0x00, 0x00, 0xff, 0xff]), BUFFER_SIZE = 32_768
    private var lock: Bool = false

    init() {
        stream = streamPtr.pointee
        status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
    }

    func decompress(data: Data, large: Bool = false) throws -> Data {
        guard lock == false else {
            decompressionQueue.async {
                _ = try? self.decompress(data: data)
            }
            throw "Already decompressing"
        }
        lock = true
        var data = data.prefix(2) == Data([0x78, 0x9C]) || data.prefix(2) == Data([0x78, 0xDA]) ? data.dropFirst(2) : data

        // Configure stream source and destinations (will be changed in loop)
        stream.src_size = 0
        let bufferSize = ZStream.BUFFER_SIZE
        let destinationBufferPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        stream.dst_ptr = destinationBufferPointer
        stream.dst_size = bufferSize

        // Buffer for decompressed chunks
        var decompressed = Data(), srcChunk: Data?

        defer {
            lock = false
            destinationBufferPointer.deallocate()
        }

        // Loop over this until there's nothing left to decompress or an error occurred
        repeat {
            var flags = Int32(0)

            // If this iteration has consumed all of the source data,
            // read a new tempData buffer from the input file.
            if stream.src_size == 0 {
                srcChunk = data.prefix(bufferSize)
                data = data.dropFirst(srcChunk!.count)

                stream.src_size = srcChunk!.count
                if stream.src_size < bufferSize {
                    // This technically shouldn't be used this way...
                    flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
                }
            }

            // Perform compression or decompression.
            if let srcChunk = srcChunk {
                srcChunk.withUnsafeBytes {
                    let baseAddress = $0.bindMemory(to: UInt8.self).baseAddress!

                    stream.src_ptr = baseAddress.advanced(by: $0.count - stream.src_size)
                    status = compression_stream_process(&stream, flags)
                }
            }

            switch status {
            case COMPRESSION_STATUS_OK, COMPRESSION_STATUS_END:
                // Get the number of bytes put in the destination buffer. This is the difference between
                // stream.dst_size before the call (here bufferSize), and stream.dst_size after the call.
                let count = bufferSize - stream.dst_size

                let outputData = Data(bytesNoCopy: destinationBufferPointer, count: count, deallocator: .none)
                decompressed.append(contentsOf: outputData)

                // Reset the stream to receive the next batch of output.
                stream.dst_ptr = destinationBufferPointer
                stream.dst_size = bufferSize
            case COMPRESSION_STATUS_ERROR: break // This "error" occurs when decompression is done, what a hack
            default: break
            }
        } while status == COMPRESSION_STATUS_OK

        return decompressed
    }

    enum ZlibErrors: Error {
        case noData
        case threadError
    }

    deinit {
        free(self.streamPtr)
        compression_stream_destroy(&stream)
    }
}
