# How to setup basic 3 nodes hybrid cluster

## Overview
This article shows quick setup of a basic 3 nodes hybrid cluster, which has floating IP address feature (fip) and data mirroring feature.
In hybrid cluster configuration, Primary Server and Secondary Servers at DC site should have Shared Disk and data on the disk is mirrored to DR Server at DR site.

## Cluster System Configuration
```bat
<Public LAN>
 |
 | <Private LAN>
 |  |
 |  |  +--------------------------------+           +-------------+
 +-----| Primary Server                 |           |             |
 |  |  |  OS: Windows Server            +===========+             |
 |  +--|  EXPRESSCLUSTER X 4.1/4.2      |           |             |
 |  |  +--------------------------------+           |   Shared    |
 |  |                                               |   Disk      |
 |  |  +--------------------------------+           |             |
 +-----| Secondary Server               |           |             |
 |  |  |  OS: Windows Server            +===========+             |
 |  +--|  EXPRESSCLUSTER X 4.1/4.2      |           |             |
 |  |  +--------------------------------+           +-------------
 |  |
 |  |  +--------------------------------+
 |  +--| Client machine                 |
 |  |  +--------------------------------+
 |  |
 |  |
 |  |
 |  |
 |  |
 |  |  +--------------------------------+
 +-----| DR Server                      |
 |  |  |  OS: Windows Server            |
 |  +--|  EXPRESSCLUSTER X 4.1/4.2      |
 |  |  +--------------------------------+


[Gateway]
 :
```
### Requirements
- All Primary Server, Secondary Server, DR Server and Client machine sould be belongs a same network and reachable with IP address.
	- **Note** If DC site and DR site are different network, Dynamic DNS Server and ddns resource are required instead of fip resource.
- Ports which EXPRESSCLUSTER requires should be opend.
	- You can open ports by executing OpenPort.bat([X4.1](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts.bat)/[X4.2](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts_X42.bat)) on all servers
- 3 partitions are required for Primary Server and Secondary Servers
	- Disk NP Partition: 20MB, RAW (do not format this partition)
	- Cluster Partition: 1GB, RAW (do not format this partition)
	- Data Partition: Depends on mirrored data size (NTFS)
		- **Note**
			- It is not supported to mirror C: drive and please do NOT sprecify C: for Data Partition.
- 2 partitions are required for PDR Server
	- Data Partition: Depends on mirrored data size (NTFS)
	- Cluster Partition: 1GB, RAW (do not format this partition)
		- **Note**
			- Data on DR Server Data Partition will be removed for initial Mirror Disk synchroniation (Initial Recovery).

### Sample configuration
- Primary/Secondary Servers
	- OS: Windows Server 2016/2019
	- EXPRESSCLUSTER X: 4.1 or 4.2
	- CPU: 2
	- Memory: 8MB
	- Disk
		- Disk0: System Drive (Local disk of each Primary and Secondary Server)
			- C:
		- Disk1: Hybrid Disk (Shared Disk)
			- Z:
				- Size: 20MB
				- File system: RAW (do NOT format)
			- X:
				- Size: 1GB
				- File system: RAW (do NOT format)
			- E:
				- Size: Depending on data size
				- File system: NTFS
			- **Note**
				- Dynamic Disk is not supported and only Basic disk is supported for Hybrid Disk.
				- GPT is better than MBR to keep drive letter.
- DR Server
	- OS: Windows Server 2016/2019
	- EXPRESSCLUSTER X: 4.1 or 4.2
	- CPU: 2
	- Memory: 8MB
	- Disk
		- Disk0: System Drive (Local disk of DR Server)
			- C:
		- Disk1: Hybrid Disk (Local disk of DR Server)
			- X:
				- Size: 1GB
				- File system: RAW (do NOT format)
			- E:
				- Size: Depending on data size
				- File system: NTFS
			- **Note**
				- Dynamic Disk is not supported and only Basic disk is supported for Hybrid Disk.
				- GPT is better than MBR to keep drive letter.
- Required Licenses
	- Core license: Total 6CPUs for 3 nodes
	- Replicator DR Option license: For 3 nodes
	- (Optional) Other Option licenses: For 3 nodes

- IP address  

| |Public IP |Private IP |
|-----------------|-----------------|-----------------|
|Primary Server |10.1.1.11 |192.168.1.11 |
|Secondary Server |10.1.1.12 |192.168.1.12 |
|DR Server |10.1.1.13 |192.168.1.13 |
|fip |10.1.1.21 |- |
|Client |10.1.1.51 |- |
|Gateway |10.1.1.1 |- |

## System setup
### Preparation
1. Confirm that there are no data on Shared Disk
	- If there are any data, backup it
1. Stop all Primary, Secondary and DR Servers
1. Connect Shared Disk to Primary Server

### Install EXPRESSCLUSTER X
#### On Primary Server
1. Connect Shared Disk to Primary Server
1. Start only Primary Server
	- **Note** To avoid multi access form Primary and Secondary Server to Shared Disk, start ONLY Primary Server.  
		If connectiong Sahred Disk to both Primary and Secodnary Servers and starting them before setting access filtering by ECX, data on Shared Disk may corrupt.
1. Start Windows Computer Management window and make Shared Disk online
	- If you initialize the disk at this time, GPT type is recommended
1. Create 3 partitions on Shared Disk
	- Z:
		- Size: 20MB
		- File system: RAW (do NOT format)
	- X:
		- Size: 1GB
		- File system: RAW (do NOT format)
	- E:
		- Size: Depending on data size
		- File system: NTFS
1. Open ports for EXPRESSCLUSTER
	- You can open ports by executing [OpenPort.bat](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts.bat) on both servers
1. Start ECX Installer
	- Choose Destination Location: Default
	- Ready to install Program: Install
	- Port Number: Default
	- Filter Settings of Shared Disk
		- Right click HBA port (Green icon) under which Shared Disk is shown and select "Filtering" to set access filtering
		- Confirm that the partitions on Shared Disk are checked
			- **Note** If C: partition is checked, OS may not rebooted. In such a case, right click C: and select "Cancel Filtering".
	- License Manager: Register licenses
		- Core license
		- Replicator DR Option license
		- (Optional) Other Option licenses
1. Reboot
1. Confirm that the partitions, Z:, X: and E:  are not accessible
	- **Note** If you can access the partitions, access filter setting is not set properly.
1. Confirm that the detail size of Data Partition E: with the following command:
	```bat
	clpvolsz E:
	```
1. Create a folder for history file
	- In the case that you have any other partition than C: on Local Disk (such as N:)
		- Create a folder on the partition
			- e.g. N:\ECX_history
	- In the case that you have only C: partition on Local Disk
		- Create a folder on C: partition
			- e.g. C:\ECX_history

#### On Secondary Server
1. Connect Shared Disk to Primary Server
1. Start Secondary Server
1. Start Windows Computer Management window and make Shared Disk online
1. Confirm that you can see the partitions which you created on Primary Server
	- Z:
		- Size: 20MB
		- File system: RAW (do NOT format)
	- X:
		- Size: 1GB
		- File system: RAW (do NOT format)
	- E:
		- Size: Depending on data size
		- File system: NTFS
	- **Note** If driver letter was different from Primary Server, change them as same as Primary Server 
1. Open ports for EXPRESSCLUSTER
	- You can open ports by executing [OpenPort.bat](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts.bat) on both servers
1. Start ECX Installer
	- Choose Destination Location: Default
	- Ready to install Program: Install
	- Port Number: Default
	- Filter Settings of Shared Disk
		- Right click HBA port (Green icon) under which Shared Disk is shown and select "Filtering" to set access filtering
		- Confirm that the partitions on Shared Disk are checked
			- **Note** If C: partition is checked, OS may not rebooted. In such a case, right click C: and select "Cancel Filtering".
	- License Manager: Register licenses
		- Core license
		- Replicator DR Option license
		- (Optional) Other Option licenses
1. Reboot
1. Confirm that the partitions, Z:, X: and E: are not accessible
1. Create a folder for history file
	- In the case that you have any other partition than C: on Local Disk (such as N:)
		- Create a folder on the partition
			- e.g. N:\ECX_history
	- In the case that you have only C: partition on Local Disk
		- Create a folder on C: partition
			- e.g. C:\ECX_history

#### On DR Server
1. Start DR Server
1. Start Windows Computer Management window and make Shared Disk online
1. Confirm that you can see the partitions which you created on Primary Server
	- X:
		- Size: 1GB
		- File system: RAW (do NOT format)
	- E:
		- Size: Depending on data size
		- File system: NTFS
1. Open ports for EXPRESSCLUSTER
	- You can open ports by executing [OpenPort.bat](https://github.com/EXPRESSCLUSTER/Tools/blob/master/OpenPorts.bat) on both servers
1. Start ECX Installer
	- Choose Destination Location: Default
	- Ready to install Program: Install
	- Port Number: Default
	- Filter Settings of Shared Disk: Default
		- **Note** For DR Server, Filter Settings are NOT required
	- License Manager: Register licenses
		- Core license
		- Replicator DR Option license
		- (Optional) Other Option licenses
1. Reboot
1. Confirm that the detail size of Data Partition E: with the following command:
	```bat
	clpvolsz E:
	```
	- If the result of Primary Server and DR server are the same:
		- Nothing to do
	- If the result of Primary Server is bigger than DR server:
		- e.g.
			- Primary Server: 2,107,637,760
			- DR Server: 2,107,637,248
		- On Primary Server, shrink the partition with the following command to make its size as same as DR Server:
			```bat
			clpvolsz E: 2,107,637,248
			```
	- If the result of Primary Server is less than DR server:
		- e.g.
			- Primary Server: 2,107,637,248
			- DR Server: 2,107,637,760
		- On DR Server, shrink the partition with the following command to make its size as same as Primary Server:
			```bat
			clpvolsz E: 2,107,637,248
			```
1. Create a folder for history file
	- In the case that you have any other partition than C: on Local Disk (such as N:)
		- Create a folder on the partition
			- e.g. N:\ECX_history
	- In the case that you have only C: partition on Local Disk
		- Create a folder on C: partition
			- e.g. C:\ECX_history

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
		- Click Add and set Secondary Server IP address, 10.1.1.12 or 192.168.1.12
		- Click Add and set DR Server IP address, 10.1.1.13 or 192.168.1.13
		- Server Group Definition: Setting
			- Click Add and crate DC site group
				- Name: dc
				- Add Primary Server and Secondary Server
			- Click Add and crate DR site group
				- Name: dr
				- Add DR Server
	- Interconnects
		- Set as follows
    
		|Priority |Type |MDC |Primary Server |Secondary Server |DR Server |
		|---------|------------|-----|-----------------|-----------------|-----------------|
		|1 |Kernel Mode |mdc2 |10.1.1.11 |10.1.1.12 |10.1.1.13 |
		|1 |Kernel Mode |mdc1 |192.168.1.11 |192.168.1.12 |192.168.1.13 |
	- NP Resolution
		- Add
		- Set as follows
    
		|Type |Target |Primary Server |Secondary Server |DR Server |
		|-----|---------|-----------------|-----------------|-----------------|
		|Ping |10.1.1.1 |Use |Use |Don't use |
		|DISK |- |Z: |Z: |- |
	- Group
		- Add
		- Basic Settings
			- Type: failover
			- Use Server Group Settings: Check
			- Name: As you like
		- Startup Servers
			- dc: Add
			- dr: Add
		- Group Attributes
			- Failover Attribute: Prioritize server group failover policy
			- Enable only manual failover among the server groups: Check
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
					- Type: Hybrid disk resource
					- Name: As you like
				- Dependency
					- Default
				- Recovery Operation
					- Default
				- Details
					- Data Partition: E
					- Cluster Partition: X
					- Tuning
						- In the case of Sync mode
							- Compress Data When Recovering: Check
						- In the case of Async mode
							- Mirror Connect Timeout: 80
							- Mode: Asynchronous
							- History Files Store Directory:
								- Specify a folder you have created on each Servers (N:\ECX_history or C:\ECX_history)
							- Limit size of History File: Set maximum size of history file depending on free space of History Files Store Directory
								- **Note** Un-mirrored data is recorded in history file. If un-mirrored data gets huge, history file also gets huge. Therefore, set this size not to use all free space.
							- Compress Data: Check
							- Compress Data When Recovering: Check
	- Monitor
		- Default
	- Finish
1. **For Async mode**, click cluster Properties
	- Timeout
		Timeout: 90
1. Apply the Configuration

### Check cluster
#### On Primary Server
1. Move to Cluster WebUI Operation Mode
1. Confirm that failover group is Online on Primary Server and there are no Errors/Cautions
	- **Note**
		- While Initial Recovery, hdw monitor resource shows Caution.  
		If Data Partition size are huge, it may take some time to complete Initial Recovery and change from Caution status to Normal.
1. Execute "ipconfig" command and check fip address 10.1.1.21 exists to confirm that fip feature works.
1. Make test file on E:
	- e.g. E:\test.txt
1. On Cluster WebUI, move failover group from Primary Server to Secondary Server

#### On Secondart Server
1. Start Cluster WebUI Operation Mode
1. Confirm that failover group is Online on Secondary Server and there are no Errors/Cautions
1. Execute "ipconfig" command and check fip address 10.1.1.21 exists to confirm that fip feature works.
1. Confirm that the test file "E:\test.txt" exists
1. On Cluster WebUI, move failover group from Secondary Server to DR Server

#### On DR Server
1. Start Cluster WebUI Operation Mode
1. Confirm that failover group is Online on DR Server and there are no Errors/Cautions
1. Execute "ipconfig" command and check fip address 10.1.1.21 exists to confirm that fip feature works.
1. Confirm that the test file "E:\test.txt" exists

## Reference for more details
- [EXPRESSCLUSTER X 4.1 for Windows System Requirements](https://www.nec.com/en/global/prod/expresscluster/en/overview/sysrep_wx.html?)
- [EXPRESSCLUSTER X 4.1 Installation Guide for Windows](https://www.nec.com/en/global/prod/expresscluster/en/support/manuals.html)
