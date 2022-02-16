# mutating webhook server
动态准入控制, 参考官网:  
https://kubernetes.io/zh/docs/reference/access-authn-authz/extensible-admission-controllers/

- 生成证书:  
```bash
./gencsr.sh
```

- 修改 build.sh 上传的仓库: 
```
docker tag mutating:${1} <harbor>/mutating:v${1}
```

- 构建
```bash
./build.sh v1.0
```

- 将生成证书时候打印出来的 ca 修改至 mutating_webhook_configuration.yaml 中并创建 MutatingWebhookConfiguration
```bash
k apply -f mutating_webhook_configuration.yaml
```

- 创建 kube-ops namespace
```bash
k create ns kube-ops
```

- 创建 mutating webhook server 到集群
```bash
k apply -f mutating_webhook_deploy.yaml
```

- 创建 pod 或 deployment 进行验证
```
k apply -f inject-deploy.yaml -f inject-pod.yaml
```