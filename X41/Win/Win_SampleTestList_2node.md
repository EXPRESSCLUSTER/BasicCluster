# EXPRESSCLUSTER X Test List Sample
## About this article
It is recommended to test a cluster behaviour after the cluster is created and this is a sample of test list for a cluster.

## Target version
- EXPRESSCLUSTER X 4 for Windows

## Assumption
- This sample is assuming a cluster which consists of 2 nodes (Primary Server and Secondary Server).
- This sample is assuming that the cluster has 1 failover group.

## Notification
- This is a just sample and it is required to add and/or customize items in the list depending on the customer's environment and requirements.

## Test sample
### Normal status
In order to confirm cluster normal status, start a failover group and confirm all resources status.
It is recommended that start the group and check cluster status on each server.

1. Start all servers and start a failover group on Primary Server in the case that the group Startup Attribute is *Manual Startup*.
	- Expected result:
		- Heartbeat resource
			- All heartbeat resources are Online on all servers.
		- Network partition resource
			- All network partition resources are Normal on all servers.
		- Group resource
			- All group resources are Online on Active Server.
		- Monitor resource
			- In the case that the monitor resource Monitor Timing is "Active":
				- The monitor resource is Online on Active Server.
			- In the case that the monitor resource Monitor Timing is "Always":
				- The monitor resource is Online on all servers.
1. Execute *Move group* to Secondary Server.
	- Expected result:
		- Heartbeat resource
			- All heartbeat resources are Online on all servers.
		- Network partition resource
			- All network partition resources are Normal on all servers.
		- Group resource
			- All group resources are Online on Active Server.
		- Monitor resource
			- In the case that the monitor resource Monitor Timing is "Active":
				- The monitor resource is Online on Active Server.
			- In the case that the monitor resource Monitor Timing is "Always":
				- The monitor resource is Online on all servers.
1. Execute *Move group* to Primary Server.
	- Expected result:
		- Heartbeat resource
			- All heartbeat resources are Online on all servers.
		- Network partition resource
			- All network partition resources are Normal on all servers.
		- Group resource
			- All group resources are Online on Active Server.
		- Monitor resource
			- In the case that the monitor resource Monitor Timing is "Active":
				- The monitor resource is Online on Active Server.
			- In the case that the monitor resource Monitor Timing is "Always":
				- The monitor resource is Online on all servers.

##### Additional check
In order to confirm each group resource works properly, check the following for each resource.

- Fip resource
	- Execute ipconfig command and confirm fip address exists on Active Server.
- Mirror disk resource
	- Confirm that Data Partition is accessible on Active Server.
- Service resource
	- Confirm that the target service is running on Active Server.
- Virtual computer name resource
	- Execute ping command to the virtual computer name and confirm that you receive a reply from the assigned ip address.
- Dynamic DNS resource
	- Confirm that the virtual hostname exists on the target DNS Server.
- Virtual IP resource
	- Execute ipconfig command and confirm vip address exists on Active Server.
- CIFS resource
	- Confirm that the target shared folder is accessible.

### State transition
In order to confirm cluster state transition, execute cluster operation and confirm a result of the operation.
It is expected that all operations are executed by Cluster WebUI or cluster commands.

1. Start all servers and start a failover group on Primary Server in the case that the group Startup Attribute is *Manual Startup*.
	- Expected result:
		- All servers become *Online*.
		- The group becomes *Online* on Primary Server.
1. Execute *Shutdown cluster*.
	- Expected result:
		- The group becomes *Offline*.
		- All servers become *Offline*.
1. Start all servers and start a failover group on Primary Server in the case that the group Startup Attribute is *Manual Startup*.
	- Expected result:
		- All servers become *Online*.
		- The group becomes *Online* on Primary Server.
1. Execute *Shutdown server* on Primary Server.
	- Expected result:
		- Primary Server becomes *Offline*.
		- Failover occurs and the group becomes *Online* on Secondary Server.
1. Start Primary Server.
	- Expected result:
		- Primary Server becomes *Online*.
		- In the case that md resources exists:
			- *Fast Recovery* to Primary Server occurs.
1. Execute *Move group* to Primary Server.
	- Expected result:
		- The group becomes *Online* on Primary Server.
1. Execute *Move group* to Secondary Server.
	- Expected result:
		- The group becomes *Online* on Secondary Server.
1. Execute *Move group* to Primary Server.
	- Expected result:
		- The group becomes *Online* on Primary Server.
1. Execute *Move group* to Secondary Server.
	- Expected result:
		- The group becomes *Online* on Secondary Server.
1. Execute *Shutdown cluster*.
	- Expected result:
		- The group becomes *Offline*.
		- All servers become *Offline*.
1. Start all servers and start a failover group on Primary Server in the case that the group Startup Attribute is *Manual Startup*.
	- Expected result:
		- All servers become *Online*.
		- The group becomes *Online* on Primary Server.
1. Execute *Shutdown server* on Primary Server.
	- Expected result:
		- Primary Server becomes *Offline*.
		- Failover occurs and the group becomes *Online* on Secondary Server.
1. Execute *Shutdown cluster*.
	- Expected result:
		- The group becomes *Offline*.
		- All servers become *Offline*.
	- Note:
		- Execute *Shutdown cluster*, not *Shutdown server* on Primary Server.
1. Start all servers and start a failover group on Primary Server in the case that the group Startup Attribute is *Manual Startup*.
	- Expected result:
		- All servers become *Online*.
		- In the case that md resources does not exist:
			- The group becomes *Online* on Primary Server.
		- In the case that md resources exists:
			- The group becomes *Online pending* but md resource becomes *Online failure* on Primary Server because Primary Server does not have the latest data.  
				After that, failover to Secondary Server occurs, the group becomes *Online* on Secondary Server and *Fast Recovery* to Primary Server occurs.
1. In the case that md resource exists, execute *Move group* to Secondary Server.
	- Expected result:
		- The group becomes *Online* on Secondary Server.
1. Execute *Shutdown server* on Secondary Server.
	- Expected result:
		- Secondary Server becomes *Offline*.
		- Failover occurs and the group becomes *Online* on Primary Server.
1. Start Secondary Server.
	- Expected result:
		- Secondary Server becomes *Online*.
		- In the case that md resources exists:
			- *Fast Recovery* to Secondary Server occurs.
1. Execute *Shutdown cluster*.
	- Expected result:
		- The group becomes *Offline*.
		- All servers become *Offline*.
1. Start all servers and start a failover group on Primary Server in the case that the group Startup Attribute is *Manual Startup*.
	- Expected result:
		- All servers become *Online*.
		- The group becomes *Online* on Primary Server.
1. Execute *Shutdown server* on Primary Server.
	- Expected result:
		- Primary Server becomes *Offline*.
		- Failover occurs and the group becomes *Online* on Secondary Server.
1. Execute *Shutdown server* on Secondary Server.
	- Expected result:
		- The group becomes *Offline*.
		- All servers become *Offline*.
	- Note:
		- Execute *Shutdown server* on Secondary Server, not *Shutdown cluster*.
1. Start all servers and start a failover group on Primary Server in the case that the group Startup Attribute is *Manual Startup*.
	- Expected result:
		- All servers become *Online*.
		- In the case that md resources does not exist:
			- The group becomes *Online* on Primary Server.
		- In the case that md resources exists:
			- The group becomes *Online pending* but md resource becomes *Online failure* on Primary Server because Primary Server does not have the latest data.  
				After that, failover to Secondary Server occurs, the group becomes *Online* on Secondary Server and *Fast Recovery* to Primary Serv1. In the case that md resource exists, execute *Move group* to Primary Server.
	- Expected result:
		- The group becomes *Online* on Primary Server.

### Monitor error and recovery action
In order to confirm monitor error and its recovery action, start a failover group and try the following for each monitor resource.
In the case that you want to detect monitor error but disable its recovery action, change cluster configuration before the test.

- Floating IP monitor resource
	- Disable a NIC on which fip address is assigned on Active Server.
	- Note:
		- In the case that the NIC is used for another resources (*), they will also detect an error.  
			\* Heartbeat resource, fip resource, Dynamic DNS resource, Virtual IP resource, IP monitor resource, mirror connect monitor resource, Mirror disk monitor resource, NIC link up/down monitor resource, Dynamic DNS monitor resource and/or Virtual IP monitor resource
- IP monitor resource
	- Disconnect network between Active Server and IP monitor target.
	- Note:
		- In the case that the network is used for another resources (*), they will also detect an error.  
			\* Heartbeat resource, mirror connect monitor resource, Mirror disk monitor resource, Dynamic DNS monitor resource.
 - Mirror connect monitor resource
	- Disconnect all networks which is used for mirror disk connection (mdc).
	- Note:
		- In the case that the network is used for another resources (*), they will also detect an error.  
			\* Heartbeat resource, mirror connect monitor resource, Mirror disk monitor resource, Dynamic DNS monitor resource.
- Mirror disk monitor resource
	- Disconnect all networks which is used for mirror disk connection (mdc).
	- Note:
		- In the case that the network is used for another resources (*), they will also detect an error.  
			\* Heartbeat resource, mirror connect monitor resource, Mirror disk monitor resource, Dynamic DNS monitor resource.
- NIC link up/down monitor resource
	- Disable the target NIC on Active Server.
	- Note:
		- In the case that the NIC is used for a heartbeat resource, the heartbeat resource will also become error.
- Service monitor resource
	- Stop the target service manually with Windows Service Manager or command on Active Server.
- Dynamic DNS monitor resource
	- Remove the target virtual hostname record from DNS Server or disconnect network between Active Server and DNS Server.
	- Note:
		- In the case that the network is used for another resources (*), they will also detect an error.  
			\* Heartbeat resource, mirror connect monitor resource, Mirror disk monitor resource, Dynamic DNS monitor resource.
- Virtual IP monitor resource
	- Disable a NIC on which vip address is assigned on Active Server.
	- Note:
		- In the case that the NIC is used for another resources (*), they will also detect an error.  
			\* Heartbeat resource, fip resource, Dynamic DNS resource, Virtual IP resource, IP monitor resource, mirror connect monitor resource, Mirror
- Process name monitor resource
	- Kill the target process manually with Windows Task Manager.

##### Supplement
You can disable a recovery actions for monitor error by one of the following settings.
Please note that you need to change the settings again when you enable the recovery action.

- Change monitor resource properties
	- By changing the following settings, you can disable recovery action:
		- Monitor resource Properties
			- Recovery Action
				- Recovery Action: *Execute only the final action*
				- Final Action: *No operation*
- Disable cluster operation
	- By changing the following settings, you can disable recovery action:
		- In the case of X 4.2 or later
			- Cluster Properties
				- Extension
					- Disable Cluster Operation
						- Recovery Action when Monitor Resource Failure Detected: *Check*
		- In the case of X 4.1 or earlier
			- Cluster Properties
				- Recovery
					- Disable Recovery Action Caused by Monitor Resource Failure: *Check*
	- Note
		- By setting it, recovery actions for all monitor resources are disabled.

### Heartbeat and network partition resource error
In order to confirm heartbeat and network partition resource error, try the following.
It is recommended to disable monitor error for network disconnection by suspending monitor resources.

##### Case1
This case is assuming as follows:
	- 2 LAN heartbeat networks exist (lankhb1, lankhb2).
	- 1 Ping network partition resource exists and its target exists on a one of LAN heartbeat networks.
	- Failover group is Online on Primary Server.
```bat
               +--------------------+
               |    Ping network    |
               | partition resource |
               |       target       |
               +----------+---------+
                          |
+-----------+            <d>            +-----------+
|           |             |             |           |
|           +---<a>-------+-------<b>---+           |
|  Primary  |          lankhb1          | Secondary |
|  Server   |                           |  Server   |
| (Active)  +------------<c>------------+           |
|           |          lankhb2          |           |
+-----------+                           +-----------+
```
- Disconnects \<a\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
			- Pingnp1 becomes *Error*
		- On Secondary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
- Disconnects \<b\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
		- On Secondary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
			- Pingnp1 becomes *Error*
- Disconnects \<c\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Lankhb2 becomes *Caution*
		- On Secondary Server
			- Server status becomes *Warning*
			- Lankhb2 becomes *Caution*
- Disconnects \<d\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Pingnp1 becomes *Error*
		- On Secondary Server
			- Server status becomes *Warning*
			- Pingnp1 becomes *Error*
- Disconnects \<a\> and \<b\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
			- Pingnp1 becomes *Error*
		- On Secondary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
			- Pingnp1 becomes *Error*
- Disconnects \<c\> and \<d\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Lankhb2 becomes *Caution*
			- Pingnp1 becomes *Error*
		- On Secondary Server
			- Server status becomes *Warning*
			- Lankhb2 becomes *Caution*
			- Pingnp1 becomes *Error*
- Disconnects \<a\> and \<c\>
	- Expected result:
		- On Primary Server
			- Action at NP Occurrence is executed because the server becomes network partition
		- On Secondary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
			- Lankhb2 becomes *Caution*
			- Failover occurs and the group becomes *Online*
- Disconnects \<b\> and \<c\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
			- Lankhb2 becomes *Caution*
		- On Secondary Server
			- Action at NP Occurrence is executed because the server becomes network partition

##### Case2
This case is assuming as follows:
	- 2 LAN heartbeat networks exist (lankhb1, lankhb2).
	- Failover group is Online on Primary Server.
```bat
+-----------+                           +-----------+
|           |                           |           |
|           +------------<a>------------+           |
|  Primary  |          lankhb1          | Secondary |
|  Server   |                           |  Server   |
|           +------------<b>------------+           |
|           |          lankhb2          |           |
+-----------+                           +-----------+
```

- Disconnects \<a\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
		- On Secondary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
- Disconnects \<b\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Lankhb2 becomes *Caution*
		- On Secondary Server
			- Server status becomes *Warning*
			- Lankhb2 becomes *Caution*
- Disconnects \<a\> and \<b\>
	- Expected result:
		- On Primary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
			- Lankhb12 becomes *Caution*
		- On Secondary Server
			- Server status becomes *Warning*
			- Lankhb1 becomes *Caution*
			- Lankhb2 becomes *Caution*
			- Failover occurs and the group becomes *Online* (both servers activation)
- Reconnect \<a\> and \<b\> after disconnecting \<a\> and \<b\>
	- Expected result:
		- On Primary Server
			- Emergency shutdown occurs because cluster detects both servers activation
		- On Secondary Server
			- Emergency shutdown occurs because cluster detects both servers activation
