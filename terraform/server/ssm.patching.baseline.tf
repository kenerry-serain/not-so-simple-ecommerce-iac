resource "aws_ssm_patch_baseline" "this" {
  name                                 = var.debian_patch_baseline.name
  description                          = var.debian_patch_baseline.description
  approved_patches_enable_non_security = var.debian_patch_baseline.approved_patches_enable_non_security
  operating_system                     = var.debian_patch_baseline.operating_system

  dynamic "approval_rule" {
    for_each = var.debian_patch_baseline.approval_rules
    content {
      approve_after_days = approval_rule.value.approve_after_days
      compliance_level   = approval_rule.value.compliance_level

      dynamic "patch_filter" {
        for_each = approval_rule.value.patch_filter
        content {
          key    = upper(tostring(patch_filter.key))
          values = patch_filter.value
        }
      }
    }
  }
}
