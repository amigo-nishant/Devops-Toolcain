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
   # token is read from VAULT_TOKEN env
   # token              = ""   //vault token can be set here but taking it from ENV variable is preffered.
   disable_renewal    = "false"

   // Key configuration
   key_name           = "unseal_key"     // name of transit key
   mount_path         = "transit/"       // path
}

api_addr = "http://34.28.134.111:8200"
cluster_addr = "http://34.28.134.111:8201"
