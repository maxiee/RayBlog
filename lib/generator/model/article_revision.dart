class ArticleRevision {
  String title;
  String timeString;
  int timestamp; // 时间戳用于排序
  String comment;

  ArticleRevision(this.title, this.timeString, this.timestamp, this.comment);
}
