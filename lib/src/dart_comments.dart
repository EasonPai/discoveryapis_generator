// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.dart_comments;

import 'utils.dart';

/**
 * Represents a comment of a dart element (e.g. class, method, ...)
 */
class Comment {
  static final Comment Empty = new Comment('');
  final String rawComment;

  Comment(String raw)
      : rawComment = (raw != null && raw.length > 0) ? raw.trimRight() : '';

  /**
   * Returns a block string which has [indentationLevel] spaces in front of it.
   *
   * If the rawComment is empty, an empty string will be returned. Otherwise,
   * the block will start with spaces and ends with a new line.
   */
  String asDartDoc(int indentationLevel) {
    if (rawComment.isEmpty) return '';

    var commentString = escapeComment(rawComment);
    var spaces = ' ' * indentationLevel;

    String multilineComment() {
      var result = new StringBuffer();

      var maxCommentLine = 80 - (indentationLevel + ' * '.length);
      var expandedLines = commentString.split('\n').expand((String s) {
        if (s.length < maxCommentLine) {
          return [s];
        }

        // Try to break the line into several lines.
        var splitted = [];
        var sb = new StringBuffer();

        for (var part in s.split(' ')) {
          if ((sb.length + part.length + 1) > maxCommentLine) {
            // If we have already data, we'll write a new line.
            if (sb.length > 0) {
              splitted.add('$sb');
              sb.clear();
            }
          }
          if (!sb.isEmpty) sb.write(' ');
          sb.write(part);
        }
        if (!sb.isEmpty) splitted.add('$sb');
        return splitted;
      });

      result.writeln('$spaces/**');
      for (var line in expandedLines) {
        line = line.trimRight();
        result.write('$spaces *');
        if (line.length > 0) {
          result.writeln(' $line');
        } else {
          result.writeln('');
        }
      }
      result.writeln('$spaces */');

      return '$result';
    }

    if (!commentString.contains('\n')) {
      var onelineComment = spaces + '/** ${escapeComment(commentString)} */\n';
      if (onelineComment.length <= 80) {
        return onelineComment;
      }
      return multilineComment();
    } else {
      return multilineComment();
    }
  }
}
