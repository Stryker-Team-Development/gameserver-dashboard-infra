# Create the bucket with website configuration
module "website" {
  source = "git@github.com:aleochoam/terraform-base-infra.git//aws/cloudfront_s3"

  # Bucket variables
  is_website     = true
  bucket_name    = "stryker-minecraft-dashboard"
  index_document = "index.html"

  cf_certificate_domain     = "combo-aguacatala.space"
  cf_enabled                = true
  cf_allowed_methods        = ["GET", "HEAD"]
  cf_cached_methods         = ["GET", "HEAD"]
  cf_forward_query_string   = true
  cf_forward_cookies        = "none"
  cf_viewer_protocol_policy = "redirect-to-https"
  cf_compress               = true
  cf_aliases                = [
    "combo-aguacatala.space",
    "www.combo-aguacatala.space"
  ]
}

module "backend" {
  source = "./backend"
  tags   = local.tags
}
