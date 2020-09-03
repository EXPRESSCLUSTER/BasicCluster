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
 |  +--|  EXPRESSCLUSTER X 4.1/4.2      |
 |  |  +--------------------------------+
 |  |
 |  |  +--------------------------------+
 +-----| Secondary Server               |
 |  |  |  OS: Windows Server            |
 |  +--|  EXPRESSCLUSTER X 4.1/4.2      |
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
	- EXPRESSCLUSTER X: 4.1 or 4.2
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

### A) Manulal Setup
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

### B) Auto Setup
#### On Primary Server
1. Download [tempalte configuration file](https://github.com/EXPRESSCLUSTER/BasicCluster/blob/master/X41/Win/conf/2nodesMirror/clp.conf)
	- e.g.) C:\tmp\clp.conf
1. Download [tuning script](https://github.com/EXPRESSCLUSTER/BasicCluster/blob/master/X41/Win/scripts/2nodesMirror.ps1)
	- e.g.) C:\tmp\2nodesMirror.ps1
1. Set parameters on 2nodesMirror.ps1 file.
	- e.g.) If you want to edit parameters as follow:

	| |hostname |
	|-----------------|---------|
	|Primary Server |Host1 |
	|Secondary Server |Host2 |

	| |Public IP |Private IP |
	|-----------------|-----------------|-----------------|
	|Primary Server |10.15.15.11 |192.168.101.11 |
	|Secondary Server |10.15.15.12 |192.168.101.12 |
	|fip |10.15.15.21 |- |
	|Client |10.15.15.51 |- |
	|Gateway |10.15.15.1 |- |

	| |Drive Letter |
	|------------------|-------------|
	|Cluster Partition |M: |
	|Data Partition |G: |
	- Set as follow:
	```bat
	##### Set the following parameters #####
	$originalConfPath = "C:\tmp"

	$primary_serverName = "Host1"
	$secondary_serverName = "Host2"

	$primary_PublicIp = "10.15.15.11"
	$primary_PrivateIp = "192.168.101.11"

	$secondary_PublicIp = "10.15.15.12"
	$secondary_PrivateIp = "192.168.101.12"

	$gatewayIp = "10.15.15.1"

	$fip = "10.15.15.21"

	$clusterPartition = "M"
	$dataPartition = "G"
	#######################################
	```
1. Execute 2nodesMirror.ps1 as Powershell Script.  
	Then, clp.conf is changed and zipped as "C:\tmp\clpconf_2nodeMirror_update.zip"

1. Start Cluster WebUI
	- Desktop shortcut icon or http://localhost:29003
	- Move to Config Mode
1.Click Import and select clpconf_2nodeMirror_update.zip.
1. Apply the coniguration

- **Note**
	- This clp.conf and 2nodesMirror.ps1 are applicable same cluster configuration just to edit parameters but NOT to change cluster configuration such as adding/removing resources, NWs, detailed properties...

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
