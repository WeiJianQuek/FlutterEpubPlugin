class FileUtility {
  /// Get the directory path based on file path
  static String getDirectoryPath(String filePath) {
    final lastSlashIndex = filePath.lastIndexOf('/');
    if (lastSlashIndex == -1) {
      return '';
    } else {
      return filePath.substring(0, lastSlashIndex);
    }
  }

  const FileUtility._();
}