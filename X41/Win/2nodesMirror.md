# How to setup basic 2 nodes mirror cluster

## Overview
This article shows quick setup of a basic 2 nodes mirror cluster, which has floating IP address feature (fip) and data mirroring feature.

## Cluster System Configuration
```bat
<Public LAN>
 |
 | <Private LAN>
 |  |
 |  |  +--------------------------------+
 +-----| Primary Server                 |
 |  |  |  OS: Windows Server            |
 |  +--|  EXPRESSCLUSTER X 4.1          |
 |  |  +--------------------------------+
 |  |
 |  |  +--------------------------------+
 +-----| Secondary Server               |
 |  |  |  OS: Windows Server            |
 |  +--|  EXPRESSCLUSTER X 4.1          |
 |  |  +--------------------------------+
 |  |
 |  |  +--------------------------------+
 |  +--| Client machine                 |
 |     +--------------------------------+
 |
[Gateway]
 :
```
### Requirements
- All Primary Server, Secondary Server and Client machine sould be reachable with IP address.
- Ports which EXPRESSCLUSTER requires should be opend.
	- You can open ports by executing [OpenPort.bat](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts.bat) on both servers
- 2 partitions are required for Mirror Disk Data Partition and Cluster Partition.
	- Data Partition: Depends on mirrored data size (NTFS)
	- Cluster Partition: 1GB, RAW (do not format this partition)
	- **Note**
		- It is not supported to mirror C: drive and please do NOT sprecify C: for Data Partition.
		- Data on Secondary Server Data Partition will be removed for initial Mirror Disk synchroniation (Initial Recovery).

### Sample configuration
- Primary/Secondary Server
	- OS: Windows Server 2016/2019
	- EXPRESSCLUSTER X: 4.1
	- CPU: 2
	- Memory: 8MB
	- Disk
		- Disk0: System Drive
			- C:
		- Disk1: Mirror Disk
			- X:
				- Size: 1GB
				- File system: RAW (do NOT format)
			- E:
				- Size: Depending on data size
				- File system: NTFS
- Required Licenses
	- Core: For 4CPUs
	- Replicator Option: For 2 nodes
	- (Optional) Other Option licenses: For 2 nodes

- IP address  

| |Public IP |Private IP |
|-----------------|-----------------|-----------------|
|Primary Server |10.1.1.11 |192.168.1.11 |
|Secondary Server |10.1.1.12 |192.168.1.12 |
|fip |10.1.1.21 |- |
|Client |10.1.1.51 |- |
|Gateway |10.1.1.1 |- |

## System setup
### Install EXPRESSCLUSTER X
#### On both Primary and Secondary Server
1. Install EXPRESSCLUSTER X
1. Register lisences as follows:
	- Primary Server
		- Core licenses for 4CPUs
		- Replicator Option for 1 node
	- Secondary Server
		- Replicator Option for 1 node

1. Reboot the server

### Setup basic cluster
#### On Primary Server
1. Start Cluster WebUI
	- Desktop shortcut icon or http://localhost:29003
	- Move to Config Mode
	- Cluster generation wizard
1. Create a new cluster configuration with cluster generation wizard
	- Cluster
		- Cluster name: As you like
		- Language: As you like
	- Basic Settings
		- Cliack Add and set Secondary Server IP address, 10.1.1.12 or 192.168.1.12
	- Interconnects
		- Set as follows
    
		|Priority |Type |MDC |Primary Server |Secondary Server |
		|---------|------------|-----|-----------------|-----------------|
		|1 |Kernel Mode |mdc2 |10.1.1.11 |10.1.1.12 |
		|1 |Kernel Mode |mdc1 |192.168.1.11 |192.168.1.12 |
	- NP Resolution
		- Add
		- Set as follows
    
		|Type |Target |Primary Server |Secondary Server |
		|-----|---------|-----------------|-----------------|
		|Ping |10.1.1.1 |Use |Use |
	- Group
		- Add
		- Basic Settings
			- Type: failover
			- Name: As you like
		- Startup Servers
			- Default
		- Group Attributes
			- Default
		- Group Resources
			- Add
				-Info
					- Type: Floating IP resource
					- Name: As you like
				- Dependency
					- Default
				- Recovery Operation
					- Default
				- Details
					- IP Address: 10.1.1.21
			- Add
				-Info
					- Type: Mirror disk resource
					- Name: As you like
				- Dependency
					- Default
				- Recovery Operation
					- Default
				- Details
					- Data Partition: E
					- Cluster Partition: X
					- Servers that can run the group
						- Primary Server
							- Add
							- Data Partition: E
							- Cluster Partition: X
						- Secondary Server
							- Add
							- Data Partition: E
							- Cluster Partition: X
	- Monitor
		- Default
1. Apply the Configuration

### Check cluster
#### On Primary Server
1. Move to Cluster WebUI Operation Mode
1. Confirm that failover group is Online on Primary Server and there are no Errors/Cautions
	- **Note**
		- While Initial Recovery, mdw monitor resource shows Caution.  
		If Data Partition size are huge, it may take some time to complete Initial Recovery and change from Caution status to Normal.
1. Execute "ipconfig" command and check fip address 10.1.1.21 exists to confirm that fip feature works.
1. Make test file on E:
	- e.g. E:\test.txt
1. On Cluster WebUI, move failover group from Primary Server to Secondary Server

#### On Secondart Server
1. Start Cluster WebUI Operation Mode
1. Confirm that failover group is Online on Secondary Server and there are no Errors/Cautions
1. Execute "ipconfig" command and check fip address 10.1.1.21 exists to confirm that fip feature works.
1. Confirm that the test file "E:\test.txt" exists to confirm that mirroring feature works.

## Reference for more details
- [EXPRESSCLUSTER X 4.1 for Windows System Requirements](https://www.nec.com/en/global/prod/expresscluster/en/overview/sysrep_wx.html?)
- [EXPRESSCLUSTER X 4.1 Installation Guide for Windows](https://www.nec.com/en/global/prod/expresscluster/en/support/manuals.html)
