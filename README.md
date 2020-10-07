# Instructions

1. Run ./setup.sh . This creates:
    (1) vault node that is used for auto unseal of the vault cluster
    (2) a vault cluster (3 vault nodes) using a consul backend (1 consul node), the vault cluster has a userpass auth and transit mount.  The userpass is setup to return batch tokens

    Finally it logs in as the user (so subsequent steps use batch tokens)

2. In 3 seperate terminal windows, run ./client1.sh , ./client2.sh , ./client3.sh .  Each client hits a particular vault node in the cluster to do encryption operation using batch token

3. In a seperate terminal window, run "vault operator step-down" or kill the leader by
   vault status -address=http://localhost:8200  <-- note the active node address
   docker-compose restart vault_X    <--- where X is 1,2,3 from the above step

4. Notice when that happens, the client terminal windows (./client1.sh, ./client2.sh ./client3.sh) might get this error -- it doesn't correspond to the leader node.

Error writing data to transit/encrypt/test: Error making API request.

URL: PUT http://127.0.0.1:8198/v1/transit/encrypt/test
Code: 500. Errors:

* local node not active but active cluster node not found
Error writing data to transit/encrypt/test: Put "http://vault_1:8200/v1/transit/encrypt/test": dial tcp: lookup vault_1 on 127.0.0.1:53: read udp 127.0.0.1:60914->127.0.0.1:53: i/o timeout

Or other windows may get "stuck"