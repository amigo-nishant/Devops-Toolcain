Vault commands:


vault operator raft list-peers
vault operator raft join vault-cluster-a1e80280
vault status
vault token create -policy="autounseal"
vAULT_ADDR=http://34.136.26.208:8200 vault status
vault operator step-down
vault operator init


Vault installation:


wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault


/etc/systemd/system/vault.service

[Unit]
Description=vault service
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/home/acharyaakash25/configure.hcl
[Service]
Type=simple
User=root
ExecStart=/usr/bin/vault server -config=/home/acharyaakash25/configure.hcl
[Install]
WantedBy=multi-user.target

configure.hcl
configured the integrated backend storage (RAFT) with allowing connection on vault sever listen port(8200) from anywhere.

ui = true   // enable vault UI
disable_mlock = true   //lock the memory swapping between instances
storage "raft" {
path    = "/home/acharyaakash25/vault/data"
node_id = "node1"
}
listener "tcp" {
address     = "0.0.0.0:8200"   // inbound connection from any ip to port 8200
tls_disable = "true"
}
api_addr = "http://34.28.134.111:8200"
cluster_addr = "http://34.28.134.111:8201"

configure.hcl -- allowing vault instance to join the cluster automatically

ui = true   // enable vault UI
disable_mlock = true   //lock the memory swapping between instances
storage "raft" {
path    = "/home/acharyaakash25/vault/data"
node_id = "node1"
retry_join {
leader_api_addr = "http://46.26.78.24:8200"   // other vault server in the raft cluster
}
retry_join {
leader_api_addr = "http://171.56.28.38:8200"  // other vault server in the raft cluster
}
}
listener "tcp" {
address     = "0.0.0.0:8200"   // inbound connection from any ip to port 8200
tls_disable = "true"
}
api_addr = "http://34.28.134.111:8200"
cluster_addr = "http://34.28.134.111:8201"


If you want to use the transit key to unseal all the instances in the raft cluster automatically then follow these steps:
i)  Make sure to have an seperate vault server which has the transit key created so that it can be used to unlock the vault server in raft cluster. This vault instance will be out of cluster.


vault secrets enable transit


vault write -f transit/keys/autounseal


tee autounseal.hcl <<EOF
path "transit/encrypt/autounseal" {
capabilities = [ "update" ]
}
path "transit/decrypt/autounseal" {
capabilities = [ "update" ]
}
EOF


vault policy write autounseal autounseal.hcl


vault token create -orphan -policy="autounseal" -wrap-ttl=120 -period=24h




ii) put the following code to the vault instances in the cluster to automatically unseal it using transit key.
ui = true   // enable vault UI
disable_mlock = true   //lock the memory swapping between instances
storage "raft" {
path    = "/home/acharyaakash25/vault/data"
node_id = "node1"
retry_join {
leader_api_addr = "http://46.26.78.24:8200"   // other vault server in the raft cluster
}
retry_join {
leader_api_addr = "http://171.56.28.38:8200"  // other vault server in the raft cluster
}
}
listener "tcp" {
address     = "0.0.0.0:8200"   // inbound connection from any ip to port 8200
tls_disable = "true"
}
seal "transit" {
address            = "http://125.6.78.32:8200" //vault server address which has created the transit key
//token is read from VAULT_TOKEN env
//token              = ""   //vault token can be set here but taking it from ENV variable is preffered.
disable_renewal    = "false"
// Key configuration
key_name           = "unseal_key"     // name of transit key
mount_path         = "transit/"       // path
}
api_addr = "http://34.28.134.111:8200"
cluster_addr = "http://34.28.134.111:8201"
document reference link:  https://developer.hashicorp.com/vault/docs/what-is-vault