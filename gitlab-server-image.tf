module "gitlab_container_config" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm"

  container = {
    name = "gitlab"
    image   = "gitlab/gitlab-ee:latest"
    #command = ["mlflow"]
    #args    = ["server", "--host", "0.0.0.0", "--backend-store-uri", "/gce/mlruns/"]
    env = [
      {
        name  = "env"
        value = "dev"
      }
    ],
    volumeMounts = [
      {
        name      = "gitlab-persistent-disk"
        readOnly  = false
        mountPath = "/var/opt/gitlab/"
      },
    ]
  }
  volumes = [
    {
      name = "gitlab-persistent-disk"
      gcePersistentDisk = {
        pdName = var.compute_disk
        fsType = "ext4"
      }
    }
  ]
}