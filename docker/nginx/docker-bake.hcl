group "default" {
    targets = ["nginx-multiarch"]
}

target "nginx-multiarch" {
    context = "."
    dockerfile = "Dockerfile"
    platforms = [
        "linux/amd64",
        "linux/arm64"
    ]
    tags = [
        "xcommagento/nginx:latest",
        "xcommagento/nginx:1.26.2"
    ]
}
