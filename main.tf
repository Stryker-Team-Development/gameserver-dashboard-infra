# Create the bucket with website configuration
module "website" {
  source = "git@github.com:aleochoam/terraform-base-infra.git//aws/cloudfront_website"

  # Bucket variables
  bucket_name               = "stryker-valheim-dashboard"
  bucket_index_document     = "index.html"
  bucket_error_document     = "index.html"

  cf_certificate_domain     = var.domain_name
  cf_enabled                = true
  cf_aliases                = ["www.${var.domain_name}"]
  cf_allowed_methods        = ["GET", "HEAD"]
  cf_cached_methods         = ["GET", "HEAD"]
  cf_forward_query_string   = true
  cf_forward_cookies        = "none"
  cf_viewer_protocol_policy = "redirect-to-https"
  cf_min_ttl                = 0
  cf_default_ttl            = 86400
  cf_max_ttl                = 31536000
  cf_compress               = true
}

module "backend" {
  source = "./backend"
}
