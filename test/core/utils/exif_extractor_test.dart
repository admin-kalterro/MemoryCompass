import 'package:exif/exif.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_compass/core/utils/exif_extractor.dart';

IfdTag _ratiosTag(List<Ratio> ratios) {
  return IfdTag(
    tag: 0,
    tagType: 'Ratio',
    printable: ratios.join(', '),
    values: IfdRatios(ratios),
  );
}

IfdTag _stringTag(String value) {
  return IfdTag(tag: 0, tagType: 'ASCII', printable: value, values: const IfdNone());
}

void main() {
  const extractor = ExifExtractor();

  test('parses a northern/eastern GPS coordinate into positive decimal degrees', () {
    final tags = {
      'GPS GPSLatitude': _ratiosTag([Ratio(51, 1), Ratio(30, 1), Ratio(12, 1)]),
      'GPS GPSLatitudeRef': _stringTag('N'),
      'GPS GPSLongitude': _ratiosTag([Ratio(0, 1), Ratio(7, 1), Ratio(39, 1)]),
      'GPS GPSLongitudeRef': _stringTag('E'),
    };

    final result = extractor.extractFromTags(tags);

    expect(result.hasLocation, isTrue);
    expect(result.latitude, closeTo(51.5033, 0.001));
    expect(result.longitude, closeTo(0.1275, 0.001));
  });

  test('negates coordinates for southern/western hemisphere refs', () {
    final tags = {
      'GPS GPSLatitude': _ratiosTag([Ratio(33, 1), Ratio(52, 1), Ratio(4, 1)]),
      'GPS GPSLatitudeRef': _stringTag('S'),
      'GPS GPSLongitude': _ratiosTag([Ratio(151, 1), Ratio(12, 1), Ratio(36, 1)]),
      'GPS GPSLongitudeRef': _stringTag('W'),
    };

    final result = extractor.extractFromTags(tags);

    expect(result.latitude, lessThan(0));
    expect(result.longitude, lessThan(0));
  });

  test('reports no location when GPS tags are missing', () {
    final result = extractor.extractFromTags(const {});

    expect(result.hasLocation, isFalse);
    expect(result.latitude, isNull);
    expect(result.longitude, isNull);
  });

  test('reports no location when a GPS ratio has a zero denominator', () {
    final tags = {
      'GPS GPSLatitude': _ratiosTag([Ratio(51, 1), Ratio(30, 1), Ratio(1, 0)]),
      'GPS GPSLatitudeRef': _stringTag('N'),
      'GPS GPSLongitude': _ratiosTag([Ratio(0, 1), Ratio(7, 1), Ratio(39, 1)]),
      'GPS GPSLongitudeRef': _stringTag('E'),
    };

    final result = extractor.extractFromTags(tags);

    expect(result.hasLocation, isFalse);
    expect(result.latitude, isNull);
  });

  test('parses EXIF DateTimeOriginal into a DateTime', () {
    final tags = {'EXIF DateTimeOriginal': _stringTag('2024:06:21 14:03:11')};

    final result = extractor.extractFromTags(tags);

    expect(result.takenAt, DateTime(2024, 6, 21, 14, 3, 11));
  });
}
