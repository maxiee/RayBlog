import 'dart:io';

class EnvironmentVariableStore {
  String? rayBlogMediaWikiHost;

  String? rayBlogReplaceHost;

  String? rayBlogParsoidHost;

  String? rayBlogSiteOutput;

  String? rayBlogChromePath;

  String? rayBlogSingleFilePath;

  String? rayBlogS3Bucket;

  String? rayBlogCloudFrontDistributionID;

  EnvironmentVariableStore() {
    Map<String, String> env = Platform.environment;
    rayBlogMediaWikiHost = env['RAYBLOG_MEDIAWIKI_HOST'];
    rayBlogReplaceHost = env['RAYBLOG_REPLACE_HOST'];
    rayBlogParsoidHost = env['RAYBLOG_PARSOID_HOST'];
    rayBlogSiteOutput = env['RAYBLOG_SITE_OUTPUT'];
    rayBlogChromePath = env['RAYBLOG_CHROME_PATH'];
    rayBlogSingleFilePath = env['RAYBLOG_SINGLEFILE_PATH'];
    rayBlogS3Bucket = env['RAYBLOG_S3_Bucket'];
    rayBlogCloudFrontDistributionID = env['RAYBLOG_CLOUDFRONT_DISTRIBUTION_ID'];
  }

  void printEnvironmentVariables() {
    print('rayBlogMediaWikiHost $rayBlogMediaWikiHost');
    print('rayBlogReplaceHost $rayBlogReplaceHost');
    print('rayBlogParsoidHost $rayBlogParsoidHost');
    print('rayBlogSiteOutput $rayBlogSiteOutput');
    print('rayBlogChromePath $rayBlogChromePath');
    print('rayBlogSingleFilePath $rayBlogSingleFilePath');
    print('rayBlogS3Bucket $rayBlogS3Bucket');
    print('rayBlogCloudFrontDistributionID $rayBlogCloudFrontDistributionID');
  }
}
