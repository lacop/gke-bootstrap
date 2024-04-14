provider "helm" {
    kubernetes {
        host = google_container_cluster.default.endpoint
        token = data.google_client_config.provider.access_token
        cluster_ca_certificate = base64decode(
            google_container_cluster.default.master_auth.0.cluster_ca_certificate
        )
    }
}

resource "helm_release" "gloo" {
    name = "gloo"
    namespace = "gloo-system"
    create_namespace = true

    # TODO: Two problems here:
    #   1. Ideally we would use something like this, matching the helm CLI install
    #      instructions in the Gloo repo:
    #      # repository = "oci://ghcr.io/solo-io/helm-charts/gloo-gateway"
    #      # chart = "default"
    #      # version = "2.0.0-beta1"
    #      However, helm plugin v2.13.0 seems broken, oci://ghcr.io/... with a public
    #      package gives 403 error.
    #   2. We could download the chart manually with a fixed new version of helm CLI:
    #        $ helm pull oci://ghcr.io/solo-io/helm-charts/gloo-gateway --version 2.0.0-beta1
    #      and store it in the repo, referencing it here:
    #      # chart = "./gloo-gateway-2.0.0-beta1.tgz"
    #      However that also fails with an install error:
    #        resource mapping not found for name: "gloo-gateway" namespace: "" from "":
    #        no matches for kind "GatewayClass" in version "gateway.networking.k8s.io/v1"
    #
    #   So we use the following repo on GCS which seems to work via CLI, but who knows
    #   what it contains, it is not versioned and not mentioned in the official Gloo docs.
    repository = "https://storage.googleapis.com/solo-public-helm"
    chart = "gloo"
    
    values = [
        file("${path.module}/values/gloo.yaml")
    ]
}