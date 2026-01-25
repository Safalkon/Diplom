# Daily Snapshot Schedule for all VMs
resource "yandex_compute_snapshot_schedule" "daily" {
  name        = "${local.project_prefix}-daily-snapshots"
  description = "Daily snapshots with 7-day retention"
  
  schedule_policy {
    expression = "0 1 * * *"
  }
  
  snapshot_count   = 7
  retention_period = "168h"
  
  # Список дисков всех ВМ
  disk_ids = concat(
    [for vm in yandex_compute_instance.web : vm.boot_disk[0].disk_id],
    [
      yandex_compute_instance.bastion.boot_disk[0].disk_id,
      yandex_compute_instance.zabbix.boot_disk[0].disk_id,
      yandex_compute_instance.elasticsearch.boot_disk[0].disk_id,
      yandex_compute_instance.kibana.boot_disk[0].disk_id
    ]
  )
  
  labels = local.common_tags
}