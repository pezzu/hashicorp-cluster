# nomad-cluster

- packer init aws-ami.pkr.hcl
- packer build aws-ami.pkr.hcl
- terraform apply --auto-approve
- export NOMAD_ADDR=
- export CONSUL_HTTP_ADDR=
- nomad server members
- nomad node status
- nomad namespace apply -description "LIVE environment" live
- nomad namespace list
- nomad job run app.nomad
- nomad job status --namespace=live
- nomad job run fabio.nomad
- nomad job status
- curl /
- curl /server-info
- curl /params
- consul kv put param1 value1
- consul kv put param2 value2
