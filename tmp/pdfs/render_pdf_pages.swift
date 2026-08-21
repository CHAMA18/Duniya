import AppKit
import CoreGraphics
import ImageIO
import PDFKit

let input = URL(fileURLWithPath: "/Users/chunguchama/Duniya/output/pdf/duniya_rbac_guide.pdf")
let outputDir = URL(fileURLWithPath: "/Users/chunguchama/Duniya/tmp/pdfs/pages", isDirectory: true)
try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
guard let document = PDFDocument(url: input) else { exit(1) }

for index in 0..<document.pageCount {
    guard let page = document.page(at: index) else { continue }
    let bounds = page.bounds(for: .mediaBox)
    let scale: CGFloat = 1.5
    let width = Int(bounds.width * scale)
    let height = Int(bounds.height * scale)
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
          let context = CGContext(data: nil, width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: 0,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
          let destination = CGImageDestinationCreateWithURL(
              outputDir.appendingPathComponent(String(format: "page-%02d.png", index + 1)) as CFURL,
              "public.png" as CFString, 1, nil) else { continue }
    context.setFillColor(NSColor.white.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    context.saveGState()
    context.scaleBy(x: scale, y: scale)
    page.draw(with: .mediaBox, to: context)
    context.restoreGState()
    if let image = context.makeImage() {
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }
}
