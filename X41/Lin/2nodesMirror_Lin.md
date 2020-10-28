# How to setup basic 2 nodes mirror cluster on Linux

## Overview
This article shows quick setup of a basic 2 nodes mirror cluster on Linux, which has floating IP address feature (fip) and data mirroring feature.

## Cluster System Configuration
```bat
<Public LAN>
 |
 | <Private LAN>
 |  |
 |  |  +--------------------------------+
 +-----| Primary Server                 |
 |  |  |  OS: Linux OS                  |
 |  +--|  EXPRESSCLUSTER X 4.1          |
 |  |  +--------------------------------+
 |  |
 |  |  +--------------------------------+
 +-----| Secondary Server               |
 |  |  |  OS: Linux OS                  |
 |  +--|  EXPRESSCLUSTER X 4.1          |
 |  |  +--------------------------------+
 |  |
 |  |  +--------------------------------+
 |  +--| Client machine                 |
 |     |  OS: Windows Server            |
 |     +--------------------------------+
 |
[Gateway]
 :
```
### Requirements
- All Primary Server, Secondary Server and Client machine sould be reachable with IP address.
- Ports which EXPRESSCLUSTER requires should be opend.
	- [EXPRESSCLUSTER X 4.1 for Linux Getting Started Guide](https://www.nec.com/en/global/prod/expresscluster/en/support/Windows/W41_SG_EN_04.pdf)
		- Communication port number (p.95)
- Linux OS should be supported distribution and kernel version.
	- [Supported distribution and kernel](https://www.nec.com/en/global/prod/expresscluster/en/overview/kernel.html?)
		- If driver update is required for your kernel, you can download from [driver update page](https://www.support.nec.co.jp/en/View.aspx?NoClear=on&id=4140100112)
- 2 partitions are required for Mirror Disk Data Partition and Cluster Partition.
	- Data Partition: Depends on mirrored data size and file system
	- Cluster Partition: 1GB, RAW (do not format this partition)
	- **Note**
		- It is not supported to mirror system partition (/dev/sda1). Do NOT sprecify system (/dev/sda1) for Data Partition.
		- Data on Secondary Server Data Partition will be removed for initial Mirror Disk synchroniation (Initial Recovery).
- Data Partition should be formatted by supported file system:
	- ext3
	- ext4
		- **Note**
			- Enabling 64bit option is not supported. Please disable it if you use ext4 for Data Partition.
	- xfs
	- reiserfs
	- jfs
	- vxfs
	- none(RAW)

Please refer EXPRESSCLUSTER Guides for more detailed requirements or notifications:
- [EXPRESSCLUSTER X 4.1 for Linux Getting Started Guide](https://www.nec.com/en/global/prod/expresscluster/en/support/Windows/W41_SG_EN_04.pdf)
- [EXPRESSCLUSTER X 4.1 for Linux Installation and Configuration Guide](https://www.nec.com/en/global/prod/expresscluster/en/support/Linux/L41_IG_EN_01.pdf)

### Sample configuration
- Primary/Secondary Server
	- OS: Red Hat Enterprise Linux 7.7/7.8/8.1
	- EXPRESSCLUSTER X: 4.1
	- CPU: 2
	- Memory: 8MB
	- Disk
		- /dev/sda (System Disk)
		- /dev/sdb (Mirror Disk)
			- /dev/sdb1 (Cluster Partition)
				- Size: 1GB
				- File system: RAW (do NOT format)
			- /dev/sdb2 (Data Partition)
				- Size: Depending on data size
				- File system: ext4
- Required Licenses
	- In the case of physical servers
		- Core license: 4CPUs
		- Replicator Option license: 2 nodes
		- (Optional) Other Option licenses: 2 nodes
	- In the case of virtual machines or Cloud instances
		- Core license for VM: 2 nodes
		- Replicator Option license: 2 nodes
		- (Optional) Other Option licenses: 2 nodes

- IP address  

| |Public IP |Private IP |
|-----------------|-----------------|-----------------|
|Primary Server |10.1.1.11 |192.168.1.11 |
|Secondary Server |10.1.1.12 |192.168.1.12 |
|fip |10.1.1.21 |- |
|Client |10.1.1.51 |- |
|Gateway |10.1.1.1 |- |

## System setup
### Create Mirror Disk partitions
#### On both Primary and Secondary Server
1. Create partitions on /dev/sdb
	```bat
	# fdisk /dev/sdb
	```
	- /dev/sdb1 (Cluster Partition)
		- Size: 1GB
	- /dev/sdb2 (Data Partition)
		- Size: Depending on data size
1. Format Data Partition
	```bat
	# mkfs -t ext4 /dev/sdb2
	```
1. Make Mirror Disk Mount Point
	```bat
	# mkdir /mnt/md
	```

### Install EXPRESSCLUSTER X
#### On both Primary and Secondary Server
1. Install EXPRESSCLUSTER X
	```bat
	# rpm -i <EXPRESSCLUSTER rpm file>
	```
1. Register lisences as follows:
	- Primary Server
		- Core licenses for 4CPUs
		- Replicator Option for 1 node
	- Secondary Server
		- Replicator Option for 1 node
	```bat
	# clplcnsc -i <EXPRESSCLUSTER license files>
	```
1. Reboot the server

### Cluster Setup
#### On Client Machine
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
				- Info
					- Type: Floating IP resource
					- Name: As you like
				- Dependency
					- Default
				- Recovery Operation
					- Default
				- Details
					- IP Address: 10.1.1.21
			- Add
				- Info
					- Type: Mirror disk resource
					- Name: As you like
				- Dependency
					- Default
				- Recovery Operation
					- Default
				- Details
					- Mirror Partition Device Name: /dev/NMP1
					- Mount Point: /mnt/md
					- Data Partition Device Name: /dev/sdb2
					- Cluster Partition Device Name: /dev/sdb1
					- File System: ext4
					- Tuning
						- Mirror tab
							- Execute the initial mirror construction: Check
							- Execute the initial mkfs: **UNCHECK**
							- Perform Data Synchronization: Check
	- Monitor
		- Default
1. Apply the Configuration
1. Start failover group on Primary Server

### Check cluster
#### On Client Machine
1. Start Cluster WebUI Operation Mode
1. Confirm that failover group is Online on Primary Server and there are no Errors/Cautions
	- **Note**
		- While Initial Recovery, mdw monitor resource shows Caution.  
		If Data Partition size are huge, it may take some time to complete Initial Recovery and change from Caution status to Normal.
1. Confirm that Initial Copy from Primary Server to Secondary Server runs and completes
#### On Primary Server
1. Confirm fip address 10.1.1.21 exists
	```bat
	# ip addr
	```
1. Make test directory on Mirror Disk
	```bat
	# mkdir /mnt/md/test
	```
#### On Client Machine
1. Start Cluster WebUI Operation Mode
1. Move failover group from Primary Server to Secondary Server
1. Confirm that failover group is Online on Secondary Server and there are no Errors/Cautions

#### On Secondart Server
1. Confirm fip address 10.1.1.21 exists
	```bat
	# ip addr
	```
1. Confirm that the test directory exists
	```bat
	# ls /mnt/md
	```
1. Remove the test directory
	```bat
	# rmdir /mnt/md
	```

## Reference
- [EXPRESSCLUSTER X 4.1 for Linux Reference Guide](https://www.nec.com/en/global/prod/expresscluster/en/support/Linux/L41_RG_EN_01.pdf)

