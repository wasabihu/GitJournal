import 'package:dart_git/blob_ctime_builder.dart';
import 'package:dart_git/file_mtime_builder.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

void main() {
  test('loadLoose builds a file for untracked external notes', () async {
    final tempDir = await io.Directory.systemTemp.createTemp(
      '__file_storage_untracked__',
    );
    addTearDown(() async {
      await tempDir.delete(recursive: true);
    });

    final repoPath = tempDir.path + p.separator;
    final storage = FileStorage(
      repoPath: repoPath,
      blobCTimeBuilder: BlobCTimeBuilder(),
      fileMTimeBuilder: FileMTimeBuilder(),
    );
    const filePath = 'docs/test_untracked.md';
    final fullPath = p.join(repoPath, filePath);

    await io.Directory(p.dirname(fullPath)).create(recursive: true);
    await io.File(fullPath).writeAsString('# test\n');

    final file = await storage.loadLoose(filePath);

    expect(file.filePath, filePath);
    expect(file.oid.isNotEmpty, isTrue);
    expect(file.fullFilePath, fullPath);
  });
}
