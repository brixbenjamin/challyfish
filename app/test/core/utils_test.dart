import 'package:feral/src/core/utils.dart';
import 'package:test/test.dart';

void main() {
  group("isValidUrl", () {
    test("accepts valid HTTP and HTTPS URLs", () {
      const validUrls = [
        "http://example.com",
        "https://google.at",
        "HTTPS://EXAMPLE.COM",
        "https://sub.example.co.uk/path/to/image.png",
        "https://example.com:8080/search?q=dart&sort=asc#results",
        "https://user:password@example.com/private",
      ];

      for (final url in validUrls) {
        expect(isValidUrl(url), isTrue, reason: url);
      }
    });

    test("rejects non-HTTP schemes and local paths", () {
      const invalidUrls = [
        "/path/to/image.png",
        "ftp://google.at",
        "file:///tmp/image.png",
        "mailto:user@example.com",
        "www.example.com",
      ];

      for (final url in invalidUrls) {
        expect(isValidUrl(url), isFalse, reason: url);
      }
    });

    test("rejects malformed or incomplete URLs", () {
      const invalidUrls = [
        "",
        "http://",
        "https://example",
        "https://.example.com",
        "https://example..com",
        "https//example.com",
        "https:// example.com",
        "https://example.com with spaces",
      ];

      for (final url in invalidUrls) {
        expect(isValidUrl(url), isFalse, reason: url);
      }
    });

    test("does not accept a valid URL embedded in another value", () {
      const embeddedUrls = [
        "prefix https://example.com",
        "https://example.com suffix",
        "not-a-urlhttps://example.com",
      ];

      for (final url in embeddedUrls) {
        expect(isValidUrl(url), isFalse, reason: url);
      }
    });
  });
}
